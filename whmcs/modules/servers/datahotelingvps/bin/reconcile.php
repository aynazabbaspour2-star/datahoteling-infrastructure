<?php

require '/home/datahoteling/public_html/client/init.php';

use Illuminate\Database\Capsule\Manager as Capsule;
use WHMCS\Service\Service;

const API_SERVER_ID = 2;
const API_PORT = 8099;

function logLine(string $message): void
{
    echo '[' . date('Y-m-d H:i:s') . '] ' . $message . PHP_EOL;
}

function getApiServer(): array
{
    $server = Capsule::table('tblservers')
        ->where('id', API_SERVER_ID)
        ->where('type', 'datahotelingvps')
        ->first();

    if (!$server) {
        throw new RuntimeException(
            'DataHoteling Provisioning API server not found.'
        );
    }

    $encryptedToken = (string) ($server->password ?? '');

    if ($encryptedToken === '') {
        throw new RuntimeException(
            'Provisioning API token is empty.'
        );
    }

    $token = decrypt($encryptedToken);

    if (!is_string($token)) {
        throw new RuntimeException(
            'Provisioning API token could not be decrypted.'
        );
    }

    $token = trim($token);

    if ($token === '') {
        throw new RuntimeException(
            'Provisioning API token is empty after decryption.'
        );
    }

    return [
        'token' => $token,
        'hostname' => trim((string) $server->hostname),
        'secure' => !empty($server->secure),
    ];
}

function apiGetJob(array $server, string $jobId): array
{
    $scheme = $server['secure'] ? 'https' : 'http';

    $url = $scheme
        . '://' . $server['hostname']
        . ':' . API_PORT
        . '/v1/jobs/' . rawurlencode($jobId);

    $ch = curl_init($url);

    if ($ch === false) {
        throw new RuntimeException(
            'Unable to initialize API cURL.'
        );
    }

    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $server['token'],
            'Accept: application/json',
        ],
        CURLOPT_CONNECTTIMEOUT => 5,
        CURLOPT_TIMEOUT => 15,
    ]);

    $response = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = (int) curl_getinfo(
        $ch,
        CURLINFO_HTTP_CODE
    );

    curl_close($ch);

    if ($response === false) {
        throw new RuntimeException(
            'API cURL error: ' . $curlError
        );
    }

    if ($httpCode !== 200) {
        throw new RuntimeException(
            'API returned HTTP ' . $httpCode . ': ' . $response
        );
    }

    $data = json_decode($response, true);

    if (!is_array($data)) {
        throw new RuntimeException(
            'API returned invalid JSON.'
        );
    }

    return $data;
}

function reconcileService(
    Service $service,
    array $apiServer
): void {
    $properties = $service->serviceProperties;

    $jobId = trim(
        (string) $properties->get('datahoteling_job_id')
    );

    if ($jobId === '') {
        return;
    }

    $serviceId = (int) $service->id;

    logLine(
        "Service {$serviceId}: checking job {$jobId}"
    );

    $job = apiGetJob($apiServer, $jobId);

    $status = (string) ($job['status'] ?? '');

    if (
        $status === 'queued'
        || $status === 'provisioning'
    ) {
        $properties->save([
            'datahoteling_provisioning_status' => $status,
        ]);

        logLine(
            "Service {$serviceId}: still {$status}"
        );

        return;
    }

    if ($status === 'ready') {
        $vmIp = trim(
            (string) ($job['vm_ip'] ?? '')
        );

        if ($vmIp === '') {
            throw new RuntimeException(
                "Service {$serviceId}: ready job has no VM IP."
            );
        }

        $service->dedicatedip = $vmIp;
        $service->assignedips = $vmIp;
        $service->save();

        $properties->save([
            'datahoteling_provisioning_status' => 'ready',
            'datahoteling_vm_ip' => $vmIp,
            'datahoteling_error' => '',
        ]);

        logLine(
            "Service {$serviceId}: READY, IP {$vmIp}"
        );

        return;
    }

    if ($status === 'failed') {
        $error = trim(
            (string) (
                $job['error'] ?? 'Provisioning failed.'
            )
        );

        $properties->save([
            'datahoteling_provisioning_status' => 'failed',
            'datahoteling_error' => $error,
        ]);

        logLine(
            "Service {$serviceId}: FAILED - {$error}"
        );

        return;
    }

    logLine(
        "Service {$serviceId}: unknown job status '{$status}'"
    );
}

try {
    logLine(
        '===== DATAHOTELING VPS RECONCILER ====='
    );

    $apiServer = getApiServer();

    $services = Capsule::table('tblhosting')
        ->where(function ($query) {
            $query
                ->whereNotNull('server')
                ->where('server', '>', 0);
        })
        ->get();

    $processed = 0;

    foreach ($services as $row) {
        try {
            $service = Service::find((int) $row->id);

            if (!$service) {
                continue;
            }

            $jobId = trim(
                (string) $service
                    ->serviceProperties
                    ->get('datahoteling_job_id')
            );

            if ($jobId === '') {
                continue;
            }

            $processed++;

            reconcileService(
                $service,
                $apiServer
            );
        } catch (Throwable $e) {
            logLine(
                "Service {$row->id}: ERROR - "
                . $e->getMessage()
            );
        }
    }

    logLine(
        "RECONCILER_OK processed={$processed}"
    );

    exit(0);
} catch (Throwable $e) {
    logLine(
        'RECONCILER_FATAL: ' . $e->getMessage()
    );

    exit(1);
}
