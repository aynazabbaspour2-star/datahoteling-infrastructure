<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

/**
 * Get Datahoteling SMS configuration
 */
function datahoteling_sms_get_config()
{
    $config = [];

    try {
        $configRows = \WHMCS\Database\Capsule::table('tbladdonmodules')
            ->where('module', 'datahoteling_sms')
            ->get();

        foreach ($configRows as $row) {
            $config[$row->setting] = $row->value;
        }
    } catch (\Throwable $e) {
        return [];
    }

    return $config;
}


/**
 * Normalize Iranian mobile number
 */
function datahoteling_sms_normalize_mobile($mobile)
{
    $mobile = trim((string) $mobile);

    $mobile = preg_replace('/[\s\.\-\(\)]/', '', $mobile);

    if (strpos($mobile, '+98') === 0) {
        $mobile = '0' . substr($mobile, 3);
    } elseif (strpos($mobile, '0098') === 0) {
        $mobile = '0' . substr($mobile, 4);
    }

    return $mobile;
}


/**
 * Send SMS through SMS.ir
 */
function datahoteling_sms_send_sms(
    $apiKey,
    $lineNumber,
    $mobile,
    $messageText
) {
    if (!function_exists('curl_init')) {
        return [
            'success' => false,
            'message' => 'PHP cURL extension is not available.',
            'http_code' => 0,
        ];
    }

    $mobile = datahoteling_sms_normalize_mobile($mobile);

    if (!preg_match('/^09[0-9]{9}$/', $mobile)) {
        return [
            'success' => false,
            'message' => 'Invalid Iranian mobile number.',
            'http_code' => 0,
        ];
    }

    if (empty($apiKey)) {
        return [
            'success' => false,
            'message' => 'SMS.ir API key is not configured.',
            'http_code' => 0,
        ];
    }

    if (empty($lineNumber)) {
        return [
            'success' => false,
            'message' => 'SMS.ir line number is not configured.',
            'http_code' => 0,
        ];
    }

    $url = 'https://api.sms.ir/v1/send/bulk';

    $payload = [
        'lineNumber' => (int) $lineNumber,
        'messageText' => $messageText,
        'mobiles' => [
            $mobile,
        ],
    ];

    $jsonPayload = json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );

    if ($jsonPayload === false) {
        return [
            'success' => false,
            'message' => 'Failed to encode JSON payload.',
            'http_code' => 0,
        ];
    }

    $ch = curl_init($url);

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $jsonPayload,

        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Accept: application/json',
            'X-API-KEY: ' . $apiKey,
        ],

        CURLOPT_RETURNTRANSFER => true,

        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_TIMEOUT => 30,

        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
    ]);

    $response = curl_exec($ch);

    $curlError = curl_error($ch);

    $httpCode = (int) curl_getinfo(
        $ch,
        CURLINFO_HTTP_CODE
    );

    curl_close($ch);

    if ($response === false || !empty($curlError)) {
        return [
            'success' => false,
            'message' => 'cURL error: ' . $curlError,
            'http_code' => $httpCode,
        ];
    }

    $data = json_decode($response, true);

    if (!is_array($data)) {
        return [
            'success' => false,
            'message' => 'Invalid response from SMS.ir.',
            'http_code' => $httpCode,
        ];
    }

    if (
        $httpCode >= 200 &&
        $httpCode < 300 &&
        isset($data['status']) &&
        (int) $data['status'] === 1
    ) {
        return [
            'success' => true,
            'message' => $data['message'] ?? 'موفق',
            'http_code' => $httpCode,
            'pack_id' => $data['data']['packId'] ?? null,
            'message_ids' => $data['data']['messageIds'] ?? [],
            'cost' => $data['data']['cost'] ?? null,
            'response' => $data,
        ];
    }

    return [
        'success' => false,
        'message' => $data['message'] ?? 'Unknown SMS.ir error.',
        'http_code' => $httpCode,
        'response' => $data,
    ];
}
