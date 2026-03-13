# Start_anything_nginx_php_mysql 🚀

Готовый Docker-шаблон для быстрого развёртывания PHP-проектов с нуля. Включает Nginx, PHP 8.4-FPM, MariaDB/MySQL, phpMyAdmin и автоматическую настройку окружения через интерактивный скрипт.

---

## 📋 Требования

- Установленные **Docker** и **Docker Compose**
- **Bash** (Linux/macOS/WSL2)
- Опционально: **Composer** (для установки зависимостей)

---

## ⚡ Быстрый старт

```bash
# 1. Клонируйте или скачайте проект
# 2. Запустите скрипт настройки:
bash bash.bash

# 3. Ответьте на вопросы скрипта:
#    • Имя проекта (например: myapp)
#    • Порты: NGINX (8080), MySQL (3306), phpMyAdmin (8081)
#    • Продакшен-домен (опционально)
#    • Composer package (vendor/project)

# 4. Запустите контейнеры:
docker-compose up -d

# 5. Готово! Откройте в браузере:
#    🌐 Приложение: http://localhost:8080
#    🗄️ phpMyAdmin: http://localhost:8081
```

---

## 🔧 Что делает скрипт `bash.bash`

| Шаг | Действие |
|-----|----------|
| ✅ 1 | Проверяет уникальность имени проекта и доступность портов |
| ✅ 2 | Создаёт общую Docker-сеть `my_shared_network` (если нет) |
| ✅ 3 | Заменяет плейсхолдеры в `docker-compose.yml` и конфигах Nginx |
| ✅ 4 | Генерирует PSR-4 namespace из Composer-пакета и обновляет все PHP-файлы |
| ✅ 5 | Настраивает подключение к БД: динамические имена сервисов и баз данных |
| ✅ 6 | Создаёт/обновляет `composer.json` и запускает `composer install` |
| ✅ 7 | Выводит итоговую сводку с доступами и следующими шагами |

---

## ⚙️ Конфигурация окружений

Проект автоматически определяет среду через `Config::getBaseServerInfo()`:

### 🐳 Docker / Local
```php
// Авто-определение:
$base_url = "http://localhost:8080/";
$host = "db_service_myapp"; // динамическое имя контейнера БД
$database = "myapp";
$user = "root"; $pass = "root";
```

## 📁 Структура проекта

```
📦 Start_anything_nginx_php_mysql
├── 📄 bash.bash                 # 🎯 Главный скрипт настройки
├── 📄 docker-compose.yml        # Конфиг с динамическими портами
├── 📄 single_network_docker-compose.yml  # Альтернатива без внешней сети
├── 📄 composer.json             # Генерируется скриптом
├── 📄 index.php, head.php       # Точка входа и общий шаблон
│
├── 📂 src/
│   ├── 📂 Config/Config.php     # Логика переключения сред
│   ├── 📂 DB/DB.php             # PDO-подключение + helper getOrCreateRecord()
│   └── 📂 Tools/Tools.php       # Место для ваших утилит
│
├── 📂 _docker/
│   ├── 📂 nginx_service/nginx/conf.d/  # Конфиги Nginx с CORS и кэшем
│   ├── 📂 php_service/
│   │   ├── 📄 Dockerfile        # PHP 8.4 + расширения (pdo_mysql, gd, zip...)
│   │   ├── 📄 php.ini           # Настройки: memory_limit=4G, upload=500M
│   │   └── 📄 uploads.ini       # Профиль для загрузки файлов
│   └── 📂 db_service/           # Томы MySQL/MariaDB и init-скрипты
│
├── 📂 js/, css/, img/           # Статика проекта
└── 📄 .gitignore                # Исключения для Docker-томов
```

---


## 🚀 Деплой на продакшен

Cкопируйте все кроме _docker на сервер, предпологается что на проде у вас готов apache, php, mysql/mariadb.


## 🛠️ Кастомизация

- **Добавить PHP-расширение**: отредактируйте `_docker/php_service/Dockerfile` и пересоберите образ.
- **Изменить конфиг Nginx**: правьте файлы в `_docker/nginx_service/nginx/conf.d/`.
- **Добавить свои скрипты инициализации БД**: поместите `.sql`-файлы в `_docker/db_service/file_setting/`.
- **Расширить класс Tools**: редактируйте `src/Tools/Tools.php` — namespace подставится автоматически.

---

> 🎯 **Идея проекта**: один скрипт → готовое окружение → начинайте кодить, а не настраивать сервер.

Happy coding! 🐘🐳✨