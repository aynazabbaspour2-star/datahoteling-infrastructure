<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

add_hook('AfterModuleCreate', 1, function ($vars) {
    $logFile = '/home/datahoteling/private-sms/wp_autoinstall_dryrun.log';
    $params = $vars['params'] ?? [];

    $serviceId = (int) ($params['serviceid'] ?? 0);

    // Only inspect the intended WHMCS product.
    if ($serviceId < 1) {
        return;
    }

    try {
        $service = \WHMCS\Database\Capsule::table('tblhosting')
            ->where('id', $serviceId)
            ->first();

        if (!$service) {
            return;
        }

        $productId = (int) ($service->packageid ?? 0);

        // Never process other products.
        if ($productId !== 4) {
            return;
        }

        // Existing test service: explicitly excluded.
        if ($serviceId === 53) {
            $result = 'SKIPPED_EXISTING_TEST_SERVICE';
        } elseif (($service->domainstatus ?? '') !== 'Active') {
            $result = 'SKIPPED_SERVICE_NOT_ACTIVE';
        } elseif (trim((string) ($service->domain ?? '')) === '') {
            $result = 'REVIEW_REQUIRED_EMPTY_DOMAIN';
        } elseif (!preg_match('/^[a-zA-Z0-9_-]{1,16}$/', (string) ($service->username ?? ''))) {
            $result = 'REVIEW_REQUIRED_INVALID_USERNAME';
        } else {
            // Dry run only. No installation is performed.
            $result = 'DRY_RUN_ELIGIBLE_FOR_REVIEW';
        }

        $entry = [
            'time' => date('c'),
            'event' => 'AfterModuleCreate',
            'service_id' => $serviceId,
            'product_id' => $productId,
            'status' => (string) ($service->domainstatus ?? ''),
            'result' => $result,
        ];

        $written = @file_put_contents(
            $logFile,
            json_encode($entry, JSON_UNESCAPED_SLASHES) . PHP_EOL,
            FILE_APPEND | LOCK_EX
        );

        if ($written === false) {
            error_log('DataHoteling WP dry-run hook: unable to write private log.');
        }
    } catch (\Throwable $e) {
        // Do not write credentials, domain details, or exception data to the log.
        error_log('DataHoteling WP dry-run hook: unexpected error.');
    }
});
