<?php
require_once __DIR__ . '/vendor/autoload.php';

use {{Name}}\{{App}}\Tools\Tools;
use {{Name}}\{{App}}\DB\DB;
use {{Name}}\{{App}}\Config\Config;

$base_url = Config::getBaseUrl();

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Новый проект</title>



    <!-- #!! bootstrap -->
    <link rel="stylesheet" href="<?= $base_url ?>css/bootstrap.min.css">
    <script src="<?= $base_url ?>js/bootstrap.bundle.min.js"></script>


    <!-- #!! papa parse js -->
    <!-- <script src="<?= $base_url ?>js/papaparse.min.js"></script> -->

    <!-- #!! axios -->
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>


    <!-- #!! htmx -->
    <script src="<?= $base_url ?>js/htmx.min.js"></script>

    <!-- #!! main -->
    <link rel="stylesheet" href="<?= $base_url ?>css/main.css">
    <script src="<?= $base_url ?>js/main.js" type="module"></script>

    <!-- #!! jq -->
    <script src="<?= $base_url ?>js/jq.js"></script>

    <!-- #!! jqui -->
    <link rel="stylesheet" href="<?= $base_url ?>css/jquery-ui.min.css">
    <script src="<?= $base_url ?>js/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

    <!-- #!! butterup библиотека уведомлений -->
    <link rel="stylesheet" href="<?= $base_url ?>css/butterup.min.css">
    <script src="<?= $base_url ?>js/butterup.min.js"></script>

    <!-- #!!  ico -->
    <link rel="icon" type="image/x-icon" href="<?= $base_url ?>ok.ico">

</head>

<body class=''>