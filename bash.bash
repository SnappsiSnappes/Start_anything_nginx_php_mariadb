#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Project Setup Script ===${NC}"

# === 1. Project Name ===
echo -e "${YELLOW}Enter the project name (lowercase, letters/numbers/underscores/hyphens):${NC}"
read PROJECT_NAME

if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9_-]+$ ]]; then
    echo -e "${RED}Error: Project name can only contain lowercase letters, numbers, underscores, and hyphens.${NC}"
    exit 1
fi

if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^${PROJECT_NAME}"; then
    echo -e "${RED}Error: Container with name '$PROJECT_NAME' already exists.${NC}"
    exit 1
fi

# === 2. Ports ===
echo -e "${YELLOW}Enter NGINX_PORT (e.g., 8080):${NC}"
read NGINX_PORT
echo -e "${YELLOW}Enter MYSQL_PORT (e.g., 3306):${NC}"
read MYSQL_PORT
echo -e "${YELLOW}Enter PHPMYADMIN_PORT (e.g., 8081):${NC}"
read PHPMYADMIN_PORT

check_port() {
    local port=$1
    if command -v lsof >/dev/null 2>&1; then
        if lsof -i :$port > /dev/null 2>&1; then
            echo -e "${RED}Error: Port $port is already in use.${NC}"
            exit 1
        fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -tuln | grep -q ":$port "; then
            echo -e "${RED}Error: Port $port is already in use.${NC}"
            exit 1
        fi
    fi
}

check_port $NGINX_PORT
check_port $MYSQL_PORT
check_port $PHPMYADMIN_PORT

# === 2.5. Production Settings ===
echo -e "${YELLOW}=== Production Server Settings ===${NC}"
echo -e "${YELLOW}Enter your PRODUCTION domain (e.g., example.com, leave empty if not needed):${NC}"
read PROD_DOMAIN
PROD_DOMAIN=${PROD_DOMAIN:-"your-domain.com"}  # Дефолт, если пусто

echo -e "${YELLOW}Enter PRODUCTION base URL (e.g., https://example.com/myproject):${NC}"
read PROD_BASE_URL
PROD_BASE_URL=${PROD_BASE_URL:-"https://${PROD_DOMAIN}/${PROJECT_NAME}"}  # Умный дефолт

# Валидация: базовая проверка URL
if [[ ! "$PROD_BASE_URL" =~ ^https?:// ]]; then
    echo -e "${RED}Warning: PROD_BASE_URL should start with http:// or https://${NC}"
    echo -e "${YELLOW}Proceeding anyway...${NC}"
fi

# === 3. Composer Package & Namespace ===
echo -e "${YELLOW}Enter Composer package name (format: vendor/package, e.g., mycompany/myproject):${NC}"
read COMPOSER_PACKAGE

if [[ ! "$COMPOSER_PACKAGE" =~ ^[a-z0-9_-]+/[a-z0-9_-]+$ ]]; then
    echo -e "${RED}Error: Composer package must be in format vendor/package${NC}"
    exit 1
fi

# Parse namespace from package name (capitalize first letter of each word)
VENDOR_NAME=$(echo "$COMPOSER_PACKAGE" | cut -d'/' -f1)
PACKAGE_NAME=$(echo "$COMPOSER_PACKAGE" | cut -d'/' -f2)

# Convert to PSR-4: my-vendor → MyVendor
to_psr4() {
    echo "$1" | sed -r 's/(^|[_-])([a-z])/\U\2/g'
}

NAMESPACE_VENDOR=$(to_psr4 "$VENDOR_NAME")
NAMESPACE_APP=$(to_psr4 "$PACKAGE_NAME")
FULL_NAMESPACE="${NAMESPACE_VENDOR}\\${NAMESPACE_APP}"

echo -e "${GREEN}Using namespace: ${FULL_NAMESPACE}${NC}"

# === 4. Docker Network ===
if ! docker network inspect my_shared_network > /dev/null 2>&1; then
    echo -e "${YELLOW}Creating shared Docker network 'my_shared_network'...${NC}"
    docker network create my_shared_network
fi

# === 5. Update Docker Compose Files ===
echo -e "${YELLOW}Updating Docker Compose files...${NC}"

for FILE in docker-compose.yml single_network_docker-compose.yml; do
    if [[ -f "$FILE" ]]; then
        sed -i "s/<YOUR NAME>/${PROJECT_NAME}/g" "$FILE"
        sed -i "s/NGINX_PORT/${NGINX_PORT}/g" "$FILE"
        sed -i "s/PHPMYADMIN_PORT/${PHPMYADMIN_PORT}/g" "$FILE"
        sed -i "s/MYSQL_PORT/${MYSQL_PORT}/g" "$FILE"
        echo -e "${GREEN}✓ Updated $FILE${NC}"
    fi
done

# === 6. Update Nginx Configs ===
echo -e "${YELLOW}Updating Nginx configuration...${NC}"

NGINX_CONF_DIR="./_docker/nginx_service/nginx/conf.d/"
if [[ -d "$NGINX_CONF_DIR" ]]; then
    for conf_file in "$NGINX_CONF_DIR"*.conf; do
        [[ -f "$conf_file" ]] || continue
        sed -i "s/NGINX_PORT/${NGINX_PORT}/g" "$conf_file"
        sed -i "s|php:php_service|php_service_${PROJECT_NAME}:9000|g" "$conf_file"
        echo -e "${GREEN}✓ Updated $conf_file${NC}"
    done
fi

# === 7. Replace Namespaces in PHP Files ===
echo -e "${YELLOW}Replacing namespace placeholders: {{Name}}\\{{App}} → ${FULL_NAMESPACE}...${NC}"

update_namespace_in_file() {
    local file=$1
    [[ -f "$file" ]] || return
    
    # Экранируем значения для sed
    local escaped_ns=$(echo "$FULL_NAMESPACE" | sed 's/\\/\\\\/g')
    local escaped_prod_domain=$(echo "$PROD_DOMAIN" | sed 's/[\/&]/\\&/g')
    local escaped_prod_base_url=$(echo "$PROD_BASE_URL" | sed 's/[\/&]/\\&/g')
    
    # Замены
    sed -i "s/{{Name}}\\\\{{App}}/${escaped_ns}/g" "$file"
    sed -i "s/{{Name}}/${NAMESPACE_VENDOR}/g" "$file"
    sed -i "s/{{App}}/${NAMESPACE_APP}/g" "$file"
    sed -i "s/__PROD_DOMAIN__/${escaped_prod_domain}/g" "$file"
    sed -i "s/__PROD_BASE_URL__/${escaped_prod_base_url}/g" "$file"
    
    echo -e "${GREEN}✓ Updated $file${NC}"
}

# Update known files
for php_file in ./src/Config/Config.php ./src/DB/DB.php ./src/Tools/Tools.php ./head.php; do
    update_namespace_in_file "$php_file"
done

# Also scan for any other PHP files with placeholders
find . -name "*.php" -type f -exec grep -l "{{Name}}\\\\{{App}}" {} \; 2>/dev/null | while read -r file; do
    update_namespace_in_file "$file"
done

# === 8. Update DB.php with Dynamic Service/DB Name ===
echo -e "${YELLOW}Updating database configuration in DB.php...${NC}"

if [[ -f ./src/DB/DB.php ]]; then
    # DOCKER: host and db name
    sed -i "s/__DB_HOST_PLACEHOLDER__/db_service_${PROJECT_NAME}/g" ./src/DB/DB.php
    sed -i "s/__DB_NAME_PLACEHOLDER__/${PROJECT_NAME}/g" ./src/DB/DB.php
    
    # PROD: database name (если используете отдельный плейсхолдер)
    sed -i "s/__PROD_DB_NAME__/${PROJECT_NAME}/g" ./src/DB/DB.php
    
    
    echo -e "${GREEN}✓ Updated DB.php for project: $PROJECT_NAME${NC}"
fi

# === 9. Initialize Composer ===
echo -e "${YELLOW}Initializing Composer...${NC}"

# Escape backslashes for JSON: \ → \\
JSON_NAMESPACE="${FULL_NAMESPACE//\\/\\\\}"

if [[ ! -f "composer.json" ]] || grep -q "{{Name}}" composer.json 2>/dev/null; then
    cat > composer.json << EOF
{
    "name": "${COMPOSER_PACKAGE}",
    "description": "Auto-generated project",
    "type": "project",
    "autoload": {
        "psr-4": {
            "${JSON_NAMESPACE}\\\\": "src/"
        }
    },
    "require": {
        "php": ">=7.4"
    }
}
EOF
    echo -e "${GREEN}✓ Created composer.json${NC}"
fi

if command -v composer >/dev/null 2>&1; then
    echo -e "${YELLOW}Running composer install...${NC}"
    composer install --no-interaction --optimize-autoloader 2>&1 | grep -v "Deprecation Notice" || true
    echo -e "${GREEN}✓ Composer dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠ Composer not found. Please run 'composer install' manually.${NC}"
fi

# === 10. Fix Permissions ===
echo -e "${YELLOW}Fixing permissions for Docker volumes...${NC}"
mkdir -p _docker/db_service/tmp _docker/db_service/file_setting
chmod -R 777 _docker/db_service/tmp _docker/db_service/file_setting 2>/dev/null || true

# === DONE ===
echo -e "\n${GREEN}=== ✅ Setup Complete! ===${NC}"
echo -e "Project:        ${PROJECT_NAME}"
echo -e "Composer:       ${COMPOSER_PACKAGE}"
echo -e "Namespace:      ${FULL_NAMESPACE}"
echo -e "Ports:          NGINX=${NGINX_PORT}, MySQL=${MYSQL_PORT}, phpMyAdmin=${PHPMYADMIN_PORT}"
echo -e "\n${GREEN}Next steps:${NC}"
echo -e "  docker-compose up -d"
echo -e "\n${YELLOW}Access:${NC}"
echo -e "  App:        http://localhost:${NGINX_PORT}"
echo -e "  phpMyAdmin: http://localhost:${PHPMYADMIN_PORT}"
echo -e "  DB:         name='db_service_${PROJECT_NAME}', user='user', pass='password'"