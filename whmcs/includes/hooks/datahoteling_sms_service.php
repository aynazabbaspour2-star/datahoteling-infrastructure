<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

add_hook('AfterModuleCreate', 1, function ($vars) {

    $logFile = '/home/datahoteling/private-sms/service_sms_debug.log';

    $params = $vars['params'] ?? [];

    $serviceId = (int) ($params['serviceid'] ?? 0);
    $userid    = (int) ($params['userid'] ?? 0);
    $domain    = (string) ($params['domain'] ?? '');
    $username  = (string) ($params['username'] ?? '');
    $module    = (string) ($params['moduletype'] ?? '');

    file_put_contents(
        $logFile,
        date('Y-m-d H:i:s') .
        " | AFTER MODULE CREATE\n" .
        "serviceid=" . $serviceId . "\n" .
        "userid=" . $userid . "\n" .
        "domain=" . $domain . "\n" .
        "username=" . $username . "\n" .
        "module=" . $module . "\n" .
        "------------------------\n",
        FILE_APPEND | LOCK_EX
    );
});
