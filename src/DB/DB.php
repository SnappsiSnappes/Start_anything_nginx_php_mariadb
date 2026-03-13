<?php

namespace {{Name}}\{{App}}\DB;
use {{Name}}\{{App}}\Config\Config;

use PDO;
class DB
{
    private $pdo;
    public function __construct()
    {
        $pdo = null; // Инициализируем заранее

        switch (Config::getBaseServerInfo()) {
            case 'PROD':
                $user = getenv('DB_USER');
                $pass = getenv('DB_PASSWORD');
                $dsn = 'mysql:host=localhost;dbname=__PROD_DB_NAME__';
                $opt = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];
                $pdo = new PDO($dsn, $user, $pass, $opt);
                break;

            case 'DOCKER':
                $host = "__DB_HOST_PLACEHOLDER__";
                $db = "__DB_NAME_PLACEHOLDER__";                $user = 'root';
                $pass = 'root';
                $port = 3306;
                $dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8";
                $opt = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];
                $pdo = new PDO($dsn, $user, $pass, $opt);
                break;

            default:
                throw new \RuntimeException("Unknown environment: " . Config::getBaseServerInfo());
        }

        if (!$pdo) {
            throw new \RuntimeException("Failed to initialize database connection");
        }

        $this->pdo = $pdo;
    }


    public function getOrCreateRecord($table, $name_column, $name_value)
    {
        // Check if the record exists
        $stmt = $this->pdo->prepare("SELECT id FROM $table WHERE $name_column = :name_value");
        $stmt->bindParam(':name_value', $name_value);
        $stmt->execute();
        $record = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($record) {
            // Record exists, return the ID
            return $record['id'];
        } else {
            // Record does not exist, insert it
            $insert_stmt = $this->pdo->prepare("INSERT INTO $table ($name_column) VALUES (:name_value)");
            $insert_stmt->bindParam(':name_value', $name_value);
            $insert_stmt->execute();
            // Return the new record's ID
            return $this->pdo->lastInsertId();
        }
    }

}
