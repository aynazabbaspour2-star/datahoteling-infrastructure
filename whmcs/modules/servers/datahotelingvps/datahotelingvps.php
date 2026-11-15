<?php

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

/*
 * DataHoteling VPS Provisioning Module
 *
 * WHMCS
 *   -> Provisioning API
 *   -> Queue Worker
 *   -> Terraform
 *   -> vCenter
 */

function datahotelingvps_MetaData()
{
    return [
        'DisplayName' => 'DataHoteling VPS',
        'APIVersion' => '1.1',
        'RequiresServer' => true,
        'DefaultNonAdminClientAreaOutput' => 'Service is being provisioned.',
    ];
}

function datahotelingvps_ConfigOptions()
{
    /*
     * VPS resources are configured through WHMCS Product
     * Configurable Options (CPU, RAM, Storage).
     *
     * The operating system is fixed to Ubuntu 24.04.
     */
    return [];
}

function datahotelingvps_CreateAccount(array $params)
{
    $serviceId = (int) ($params['serviceid'] ?? 0);

    if ($serviceId <= 0) {
        return 'Invalid WHMCS service ID.';
    }

    $hostname = trim((string) ($params['domain'] ?? ''));

    if ($hostname === '') {
        $hostname = 'vps-' . $serviceId;
    }

    $customerUsername = trim(
        (string) ($params['username'] ?? '')
    );

    if ($customerUsername === '') {
        $customerUsername = 'customer' . $serviceId;
    }

    $customerPassword = (string) (
        $params['password'] ?? ''
    );

    if ($customerPassword === '') {
        return 'Customer password is required.';
    }

    /*
     * WHMCS Product Configurable Options.
     *
     * Product 9 uses Quantity-type configurable options:
     *
     *   configoption[1] => CPU cores
     *   configoption[2] => RAM GB
     *   configoption[3] => Storage GB
     *
     * Values are therefore passed directly to provisioning.
     */
    $serviceId = (int) ($params['serviceid'] ?? 0);

    $storedOptions = \Illuminate\Database\Capsule\Manager::table('tblhostingconfigoptions')
        ->where('relid', $serviceId)
        ->get();

    $cpu = 0;
    $ram = 0;
    $storage = 0;

    foreach ($storedOptions as $option) {
        $configId = (int) $option->configid;
        $qty = (int) $option->qty;

        if ($configId === 1) {
            $cpu = $qty;
        } elseif ($configId === 2) {
            $ram = $qty;
        } elseif ($configId === 3) {
            $storage = $qty;
        }
    }

    if ($cpu < 1 || $cpu > 16) {
        return 'Invalid CPU configuration. CPU must be between 1 and 16 cores.';
    }

    if ($ram < 1 || $ram > 64) {
        return 'Invalid RAM configuration. RAM must be between 1 and 64 GB.';
    }

    if ($storage < 20 || $storage > 500) {
        return 'Invalid storage configuration. Storage must be between 20 and 500 GB.';
    }

    $package = trim((string) ($params['configoption1'] ?? ''));

    if (!preg_match('/^vps-(basic|standard|pro)$/', $package)) {
        return 'Invalid VPS package configuration.';
    }

    $payload = [
        'service_id' => $serviceId,
        'package' => $package,
        'os_type' => 'ubuntu-24.04',
        'num_cpus' => $cpu,
        'memory_mb' => $ram * 1024,
        'disk_size_gb' => $storage,
        'hostname' => $hostname,
        'customer_username' => $customerUsername,
        'customer_password' => $customerPassword,
    ];

    $result = datahotelingvps_apiRequest(
        $params,
        'POST',
        '/v1/provision',
        $payload
    );

    if (!$result['success']) {
        return $result['error'];
    }

    if (!empty($result['data']['job_id'])) {
        datahotelingvps_saveJobId(
            $serviceId,
            $result['data']['job_id'],
            $params['model'] ?? null
        );
    }

    /*
     * WHMCS CreateAccount succeeds once the provisioning job
     * has been accepted. Final activation is handled by
     * reconciliation against the provisioning API.
     */
    return 'success';
}

function datahotelingvps_SuspendAccount(array $params)
{
    return 'VPS suspension is not supported yet.';
}

function datahotelingvps_UnsuspendAccount(array $params)
{
    return 'VPS unsuspension is not supported yet.';
}

function datahotelingvps_TerminateAccount(array $params)
{
    return 'VPS termination is not supported yet.';
}

function datahotelingvps_ChangePackage(array $params)
{
    return 'VPS package changes are not supported yet.';
}

function datahotelingvps_ChangePassword(array $params)
{
    $serviceId = (int) ($params['serviceid'] ?? 0);

    if ($serviceId <= 0) {
        return 'Invalid WHMCS service ID.';
    }

    $newPassword = isset($_POST['datahoteling_new_password'])
        ? (string) $_POST['datahoteling_new_password']
        : '';

    $confirmPassword = isset($_POST['datahoteling_confirm_password'])
        ? (string) $_POST['datahoteling_confirm_password']
        : '';

    if ($newPassword === '') {
        return 'رمز عبور جدید را وارد کنید.';
    }

    if (strlen($newPassword) < 8) {
        return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
    }

    if (strlen($newPassword) > 128) {
        return 'رمز عبور نمی‌تواند بیشتر از ۱۲۸ کاراکتر باشد.';
    }

    if ($newPassword !== $confirmPassword) {
        return 'رمز عبور جدید و تکرار آن یکسان نیستند.';
    }

    $result = datahotelingvps_apiRequest(
        $params,
        'POST',
        '/v1/vps/' . $serviceId . '/password',
        [
            'new_password' => $newPassword,
        ]
    );

    if (!$result['success']) {
        logModuleCall(
            'datahotelingvps',
            'ChangePassword',
            [
                'service_id' => $serviceId,
            ],
            $result['error']
        );

        return $result['error'];
    }

    $data = $result['data'];

    $operationId = trim(
        (string) ($data['operation_id'] ?? '')
    );

    if ($operationId === '') {
        logModuleCall(
            'datahotelingvps',
            'ChangePassword',
            [
                'service_id' => $serviceId,
            ],
            $data
        );

        return 'VPS password change was accepted without an operation ID.';
    }

    try {
        $service = null;

        if (
            isset($params['model'])
            && $params['model'] instanceof \WHMCS\Service\Service
        ) {
            $service = $params['model'];
        } else {
            $service = \WHMCS\Service\Service::find(
                $serviceId
            );
        }

        if ($service) {
            $service->serviceProperties->save([
                'datahoteling_management_operation_id' => $operationId,
                'datahoteling_management_operation' => 'change_password',
                'datahoteling_management_status' => 'queued',
            ]);
        }
    } catch (\Throwable $e) {
        logModuleCall(
            'datahotelingvps',
            'ChangePasswordTracking',
            [
                'service_id' => $serviceId,
                'operation_id' => $operationId,
            ],
            $e->getMessage()
        );

        return 'Management operation was accepted, but WHMCS could not save its tracking information.';
    }

    logModuleCall(
        'datahotelingvps',
        'ChangePassword',
        [
            'service_id' => $serviceId,
            'operation_id' => $operationId,
        ],
        $data
    );

    return 'success';
}


function datahotelingvps_ReinstallVPS(array $params)
{
    $serviceId = (int) ($params['serviceid'] ?? 0);

    if ($serviceId <= 0) {
        return 'Invalid WHMCS service ID.';
    }

    $newPassword = isset($_POST['datahoteling_reinstall_password'])
        ? (string) $_POST['datahoteling_reinstall_password']
        : '';

    $confirmPassword = isset($_POST['datahoteling_reinstall_confirm_password'])
        ? (string) $_POST['datahoteling_reinstall_confirm_password']
        : '';

    if ($newPassword === '') {
        return 'رمز عبور جدید را وارد کنید.';
    }

    if (strlen($newPassword) < 8) {
        return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
    }

    if (strlen($newPassword) > 128) {
        return 'رمز عبور نمی‌تواند بیشتر از ۱۲۸ کاراکتر باشد.';
    }

    if ($newPassword !== $confirmPassword) {
        return 'رمز عبور جدید و تکرار آن یکسان نیستند.';
    }

    $result = datahotelingvps_apiRequest(
        $params,
        'POST',
        '/v1/vps/' . $serviceId . '/reinstall',
        [
            'new_password' => $newPassword,
        ]
    );

    if (!$result['success']) {
        logModuleCall(
            'datahotelingvps',
            'ReinstallVPS',
            [
                'service_id' => $serviceId,
            ],
            $result['error']
        );

        return $result['error'];
    }

    $data = $result['data'];

    $operationId = trim(
        (string) ($data['operation_id'] ?? '')
    );

    if ($operationId === '') {
        logModuleCall(
            'datahotelingvps',
            'ReinstallVPS',
            [
                'service_id' => $serviceId,
            ],
            $data
        );

        return 'VPS reinstall was accepted without an operation ID.';
    }

    try {
        $service = null;

        if (
            isset($params['model'])
            && $params['model'] instanceof \WHMCS\Service\Service
        ) {
            $service = $params['model'];
        } else {
            $service = \WHMCS\Service\Service::find($serviceId);
        }

        if ($service) {
            $service->serviceProperties->save([
                'datahoteling_management_operation_id' => $operationId,
                'datahoteling_management_operation' => 'reinstall',
                'datahoteling_management_status' => 'queued',
            ]);
        }
    } catch (\Throwable $e) {
        logModuleCall(
            'datahotelingvps',
            'ReinstallTracking',
            [
                'service_id' => $serviceId,
                'operation_id' => $operationId,
            ],
            $e->getMessage()
        );

        return 'Management operation was accepted, but WHMCS could not save its tracking information.';
    }

    logModuleCall(
        'datahotelingvps',
        'ReinstallVPS',
        [
            'service_id' => $serviceId,
            'operation_id' => $operationId,
        ],
        $data
    );

    return 'success';
}

function datahotelingvps_TestConnection(array $params)
{
    $result = datahotelingvps_apiRequest(
        $params,
        'GET',
        '/health',
        null
    );

    if (!$result['success']) {
        return [
            'success' => false,
            'error' => $result['error'],
        ];
    }

    return [
        'success' => true,
        'error' => '',
    ];
}



function datahotelingvps_powerAction(
    array $params,
    string $operation,
    string $label
) {
    $serviceId = (int) ($params['serviceid'] ?? 0);

    if ($serviceId <= 0) {
        return 'Invalid WHMCS service ID.';
    }

    $paths = [
        'on' => '/v1/vps/' . $serviceId . '/power/on',
        'shutdown' => '/v1/vps/' . $serviceId . '/power/shutdown',
        'restart' => '/v1/vps/' . $serviceId . '/power/restart',
    ];

    if (!isset($paths[$operation])) {
        return 'Unsupported VPS power operation.';
    }

    $result = datahotelingvps_apiRequest(
        $params,
        'POST',
        $paths[$operation],
        null
    );

    if (!$result['success']) {
        logModuleCall(
            'datahotelingvps',
            'PowerAction',
            [
                'service_id' => $serviceId,
                'operation' => $operation,
            ],
            $result['error']
        );

        return $result['error'];
    }

    $data = $result['data'];

    $operationId = trim(
        (string) ($data['operation_id'] ?? '')
    );

    if ($operationId === '') {
        logModuleCall(
            'datahotelingvps',
            'PowerAction',
            [
                'service_id' => $serviceId,
                'operation' => $operation,
            ],
            $data
        );

        return 'VPS management operation was accepted without an operation ID.';
    }

    try {
        $service = null;

        if (
            isset($params['model'])
            && $params['model'] instanceof \WHMCS\Service\Service
        ) {
            $service = $params['model'];
        } else {
            $service = \WHMCS\Service\Service::find(
                $serviceId
            );
        }

        if ($service) {
            $service->serviceProperties->save([
                'datahoteling_management_operation_id' => $operationId,
                'datahoteling_management_operation' => 'power_' . $operation,
                'datahoteling_management_status' => 'queued',
            ]);
        }
    } catch (\Throwable $e) {
        logModuleCall(
            'datahotelingvps',
            'PowerActionTracking',
            [
                'service_id' => $serviceId,
                'operation' => $operation,
                'operation_id' => $operationId,
            ],
            $e->getMessage()
        );

        return 'Management operation was accepted, but WHMCS could not save its tracking information.';
    }

    logModuleCall(
        'datahotelingvps',
        'PowerAction',
        [
            'service_id' => $serviceId,
            'operation' => $operation,
            'operation_id' => $operationId,
        ],
        $data
    );

    return 'success';
}

function datahotelingvps_PowerOn(array $params)
{
    return datahotelingvps_powerAction(
        $params,
        'on',
        'Power On'
    );
}

function datahotelingvps_Shutdown(array $params)
{
    return datahotelingvps_powerAction(
        $params,
        'shutdown',
        'Shutdown'
    );
}

function datahotelingvps_Restart(array $params)
{
    return datahotelingvps_powerAction(
        $params,
        'restart',
        'Restart'
    );
}

function datahotelingvps_ClientAreaCustomButtonArray()
{
    return [
        'روشن کردن VPS' => 'PowerOn',
        'خاموش کردن VPS' => 'Shutdown',
        'راه‌اندازی مجدد VPS' => 'Restart',
        'تغییر رمز عبور VPS' => 'ChangePassword',
        'نصب مجدد VPS' => 'ReinstallVPS',
    ];
}

function datahotelingvps_ClientArea(array $params)
{
    $serviceId = (int) ($params['serviceid'] ?? 0);

    $hostname = trim((string) ($params['domain'] ?? ''));
    $username = trim((string) ($params['username'] ?? ''));

    $dedicatedIp = trim((string) ($params['dedicatedip'] ?? ''));

    if ($dedicatedIp === '') {
        try {
            $service = \WHMCS\Service\Service::find($serviceId);

            if ($service) {
                $dedicatedIp = trim(
                    (string) ($service->dedicatedip ?? '')
                );

                if (
                    $dedicatedIp === ''
                    && isset($service->assignedips)
                ) {
                    $assigned = trim(
                        (string) $service->assignedips
                    );

                    if ($assigned !== '') {
                        $dedicatedIp = trim(
                            preg_split(
                                '/\s*,\s*/',
                                $assigned
                            )[0]
                        );
                    }
                }
            }
        } catch (\Throwable $e) {
            $dedicatedIp = '';
        }
    }

    $status = trim((string) ($params['status'] ?? ''));

    if ($status === '') {
        $status = 'Active';
    }

    $package = trim((string) ($params['configoption1'] ?? ''));

    if ($package === '') {
        $package = 'vps-basic';
    }

    $profiles = [
        'vps-basic' => [
            'name' => 'VPS Basic',
            'cpu' => 1,
            'ram' => 2048,
            'disk' => 20,
        ],
        'vps-standard' => [
            'name' => 'VPS Standard',
            'cpu' => 2,
            'ram' => 4096,
            'disk' => 40,
        ],
        'vps-pro' => [
            'name' => 'VPS Pro',
            'cpu' => 4,
            'ram' => 8192,
            'disk' => 80,
        ],
    ];

    $profile = $profiles[$package] ?? $profiles['vps-basic'];

    $managementOperationId = '';
    $managementOperation = '';
    $managementStatus = '';
    $managementError = '';

    try {
        $serviceModel = null;

        if (
            isset($params['model'])
            && $params['model'] instanceof \WHMCS\Service\Service
        ) {
            $serviceModel = $params['model'];
        } else {
            $serviceModel = \WHMCS\Service\Service::find(
                $serviceId
            );
        }

        if ($serviceModel) {
            $properties = $serviceModel->serviceProperties;

            $managementOperationId = trim(
                (string) $properties->get(
                    'datahoteling_management_operation_id'
                )
            );

            $managementOperation = trim(
                (string) $properties->get(
                    'datahoteling_management_operation'
                )
            );

            $managementStatus = trim(
                (string) $properties->get(
                    'datahoteling_management_status'
                )
            );
        }

        if ($managementOperationId !== '') {
            $result = datahotelingvps_apiRequest(
                $params,
                'GET',
                '/v1/vps/' . $serviceId
                . '/operations/' . rawurlencode($managementOperationId),
                null
            );

            if ($result['success']) {
                $operationData = is_array($result['data'])
                    ? $result['data']
                    : [];

                $apiStatus = trim(
                    (string) ($operationData['status'] ?? '')
                );

                if ($apiStatus !== '') {
                    $managementStatus = $apiStatus;
                }

                $apiOperation = trim(
                    (string) ($operationData['operation'] ?? '')
                );

                if ($apiOperation !== '') {
                    $managementOperation = $apiOperation;
                }

                $managementError = trim(
                    (string) ($operationData['error'] ?? '')
                );

                if ($serviceModel && $apiStatus !== '') {
                    $serviceModel->serviceProperties->save([
                        'datahoteling_management_status' => $apiStatus,
                    ]);
                }
            }
        }
    } catch (\Throwable $e) {
        logModuleCall(
            'datahotelingvps',
            'ClientAreaOperationStatus',
            [
                'service_id' => $serviceId,
                'operation_id' => $managementOperationId,
            ],
            $e->getMessage()
        );
    }

    $viewData = [
        'serviceId' => $serviceId,
        'hostname' => $hostname !== '' ? $hostname : '-',
        'username' => $username !== '' ? $username : '-',
        'dedicatedIp' => $dedicatedIp !== '' ? $dedicatedIp : '-',
        'status' => $status,
        'package' => $profile['name'],
        'cpu' => $profile['cpu'],
        'ram' => $profile['ram'],
        'ramGb' => $profile['ram'] / 1024,
        'disk' => $profile['disk'],
        'monitoringAvailable' => false,
        'managementOperationId' => $managementOperationId,
        'managementOperation' => $managementOperation,
        'managementStatus' => $managementStatus,
        'managementError' => $managementError,
    ];

    return [
        'templatefile' => 'clientarea',
        'vars' => $viewData,
    ];
}

function datahotelingvps_apiRequest(
    array $params,
    string $method,
    string $path,
    ?array $payload = null
) {
    $hostname = trim(
        (string) ($params['serverhostname'] ?? '')
    );

    if ($hostname === '') {
        return [
            'success' => false,
            'error' => 'Provisioning API hostname is not configured.',
        ];
    }

    /*
     * The provisioning API intentionally listens only on localhost.
     * WHMCS does not expose a usable Port field on this server form,
     * so the API port is defined here explicitly.
     */
    $apiPort = 8099;

    /*
     * WHMCS Hostname must normally contain only a hostname/IP.
     * Strip an accidentally supplied scheme or trailing slash.
     */
    $hostname = preg_replace(
        '#^https?://#i',
        '',
        $hostname
    );

    $hostname = rtrim($hostname, '/');

    /*
     * If somebody supplied hostname:port, remove the port so that
     * the canonical API URL below remains controlled by this module.
     */
    if (preg_match('/^(.*):([0-9]+)$/', $hostname, $matches)) {
        $hostname = $matches[1];
    }

    $scheme = !empty($params['serversecure'])
        ? 'https'
        : 'http';

    $baseUrl = $scheme . '://' . $hostname . ':' . $apiPort;

    $token = trim(
        (string) ($params['serverpassword'] ?? '')
    );

    if ($token === '') {
        return [
            'success' => false,
            'error' => 'Provisioning API token is not configured.',
        ];
    }

    $url = $baseUrl . '/' . ltrim($path, '/');

    $headers = [
        'Authorization: Bearer ' . $token,
        'Accept: application/json',
        'Content-Type: application/json',
    ];

    $ch = curl_init($url);

    if ($ch === false) {
        return [
            'success' => false,
            'error' => 'Unable to initialize cURL.',
        ];
    }

    $curlOptions = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_CONNECTTIMEOUT => 5,
        CURLOPT_TIMEOUT => 30,
    ];

    if (strtoupper($method) === 'POST') {
        $curlOptions[CURLOPT_POST] = true;
    } else {
        $curlOptions[CURLOPT_CUSTOMREQUEST] = strtoupper($method);
    }

    curl_setopt_array($ch, $curlOptions);

    if ($payload !== null) {
        $json = json_encode(
            $payload,
            JSON_UNESCAPED_SLASHES
        );

        if ($json === false) {
            curl_close($ch);

            return [
                'success' => false,
                'error' => 'Failed to encode API request.',
            ];
        }

        curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
    }


    $response = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = (int) curl_getinfo(
        $ch,
        CURLINFO_HTTP_CODE
    );


    curl_close($ch);

    if ($response === false) {
        return [
            'success' => false,
            'error' => 'Provisioning API connection failed: '
                . $curlError,
        ];
    }

    $data = json_decode($response, true);

    if ($httpCode < 200 || $httpCode >= 300) {
        $detail = 'HTTP ' . $httpCode;

        if (is_array($data) && isset($data['detail'])) {
            if (is_array($data['detail'])) {
                $detail .= ': ' . json_encode(
                    $data['detail'],
                    JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
                );
            } else {
                $detail .= ': ' . (string) $data['detail'];
            }
        } elseif (is_array($data)) {
            $detail .= ': ' . json_encode(
                $data,
                JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
            );
        }

        return [
            'success' => false,
            'error' => $detail,
        ];
    }

    if (!is_array($data)) {
        return [
            'success' => false,
            'error' => 'Provisioning API returned invalid JSON.',
        ];
    }

    return [
        'success' => true,
        'data' => $data,
    ];
}

function datahotelingvps_saveJobId(
    int $serviceId,
    string $jobId,
    $serviceModel = null
) {
    if ($serviceId <= 0) {
        throw new RuntimeException(
            'Invalid WHMCS service ID.'
        );
    }

    if ($jobId === '') {
        throw new RuntimeException(
            'Provisioning job ID is empty.'
        );
    }

    if (
        $serviceModel === null
        || !isset($serviceModel->serviceProperties)
    ) {
        throw new RuntimeException(
            'WHMCS service properties are unavailable.'
        );
    }

    $serviceModel->serviceProperties->save([
        'datahoteling_job_id' => $jobId,
    ]);

    logModuleCall(
        'datahotelingvps',
        'ProvisionJob',
        [
            'service_id' => $serviceId,
            'job_id' => $jobId,
        ],
        'job accepted'
    );
}
