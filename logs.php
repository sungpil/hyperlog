<?php
    header('Access-Control-Allow-Origin: *');
    $reqMethod = $_SERVER['REQUEST_METHOD'];
    if ($reqMethod == 'OPTIONS') {
        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']) &&
            $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD'] == 'POST' &&
            isset($_SERVER['HTTP_ORIGIN'])) {
            header('Access-Control-Allow-Methods: POST, OPTIONS');
            header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
        }
        exit;
    } else if($reqMethod == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        if(!$data || empty($data) || !isset($data['logs']) || empty($data['logs'])) {
            http_response_code(400);
        }
        $logFile = join(DIRECTORY_SEPARATOR, ['/tmp', 'hyper_'.date('Y-m-d').'.log']);
        $logs = [];
        foreach($data['logs'] as $log) {
            $logs[] = json_encode($log);
        }
        if(!@file_put_contents($logFile, join(PHP_EOL, $logs).PHP_EOL, FILE_APPEND | LOCK_EX)) {
            http_response_code(500);
        }
    }
?>
