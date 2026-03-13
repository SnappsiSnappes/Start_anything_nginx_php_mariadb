<?php
namespace {{Name}}\{{App}}\Config;

class Config{
    public static function getBaseUrl(): string
    {
        // 👇 Плейсхолдеры заменятся скриптом при установке
        $prod_domain = '__PROD_DOMAIN__';
        $prod_base_url = '__PROD_BASE_URL__';

        if ($_SERVER['HTTP_HOST'] === $prod_domain || getenv('DOMAIN')) {
            return rtrim($prod_base_url, '/') . '/';
        } else {
            // Docker/localhost: определяем автоматически
            $scheme = $_SERVER['REQUEST_SCHEME'] ?? 'http';
            $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
            return "{$scheme}://{$host}/";
        }
    }

    public static function getBaseServerInfo(): string
    {
        $prod_domain = '__PROD_DOMAIN__';

        // PROD, если: хост совпадает с доменом из конфига ИЛИ задана переменная окружения DOMAIN
        if ($_SERVER['HTTP_HOST'] === $prod_domain || getenv('DOMAIN')) {
            return 'PROD';
        } else {
            return 'DOCKER';
        }
    }
}