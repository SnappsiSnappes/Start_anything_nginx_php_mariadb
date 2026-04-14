<?php
require_once __DIR__ . '/vendor/autoload.php';

use {{Name}}\{{App}}\Tools\Tools;
use {{Name}}\{{App}}\DB\DB;
use {{Name}}\{{App}}\Config\Config;

Tools::PerformAccessCheck();
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
    <script src="<?= $base_url ?>js/Libres/bootstrap.bundle.min.js"></script>

    <!-- #!! bx24 -->
    <!-- <script src="<?= $base_url ?>js/Libres/bx24.js"></script> -->

    <!-- #!! papa parse js -->
    <!-- <script src="<?= $base_url ?>js/Libres/papaparse.min.js"></script> -->

    <!-- #!! axios -->
    <script src="<?= $base_url ?>js/Libres/axios.min.js"></script>


    <!-- #!! htmx -->
    <script src="<?= $base_url ?>js/Libres/htmx.min.js"></script>

    <!-- #!! main -->
    <link rel="stylesheet" href="<?= $base_url ?>css/main.css">
    <script src="<?= $base_url ?>js/Libres/main.js" type="module"></script>

    <!-- #!! jq -->
    <script src="<?= $base_url ?>js/Libres/jq.js"></script>

    <!-- #!! jqui -->
    <link rel="stylesheet" href="<?= $base_url ?>css/jquery-ui.min.css">
    <script src="<?= $base_url ?>js/Libres/jquery-ui.min.js"></script>

    <!-- #!! butterup библиотека уведомлений -->
    <link rel="stylesheet" href="<?= $base_url ?>css/butterup.min.css">
    <script src="<?= $base_url ?>js/Libres/butterup.min.js"></script>

    <!-- #!!  ico -->
    <link rel="icon" type="image/x-icon" href="<?= $base_url ?>ok.ico">



    <!--  https://www.jqueryscript.net/form/drag-drop-image-uploader.html -->
    <!-- <script src="<?= $base_url ?>js/Libres/image-uploader.min.js"></script> -->
    <!-- <link rel="stylesheet" href="<?= $base_url ?>css/image-uploader.min.css"> -->
</head>

<body class=''>
