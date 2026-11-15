<?php

declare(strict_types=1);

require __DIR__ . '/../init.php';

header('Content-Type: application/json; charset=utf-8');

function dhVpsJson(array $data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode(
        $data,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
    exit;
}

/*
 * Only authenticated WHMCS clients may use this endpoint.
 */
$clientId = (int) ($_SESSION['uid'] ?? 0);

if ($clientId <= 0) {
    dhVpsJson([
        'success' => false,
        'error' => 'Authentication required.'
    ], 401);
}

/*
 * Simple same-session CSRF token.
 */
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (empty($_SESSION['dh_vps_order_token'])) {
        $_SESSION['dh_vps_order_token'] = bin2hex(random_bytes(32));
    }

    dhVpsJson([
        'success' => true,
        'token' => $_SESSION['dh_vps_order_token']
    ]);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    dhVpsJson([
        'success' => false,
        'error' => 'Method not allowed.'
    ], 405);
}

$token = (string) ($_POST['token'] ?? '');

if (
    empty($_SESSION['dh_vps_order_token']) ||
    !hash_equals($_SESSION['dh_vps_order_token'], $token)
) {
    dhVpsJson([
        'success' => false,
        'error' => 'Invalid security token.'
    ], 403);
}

$cpu = filter_input(INPUT_POST, 'cpu', FILTER_VALIDATE_INT);
$ram = filter_input(INPUT_POST, 'ram', FILTER_VALIDATE_INT);
$storage = filter_input(INPUT_POST, 'storage', FILTER_VALIDATE_INT);
$hostname = trim((string) ($_POST['hostname'] ?? ''));
$username = trim((string) ($_POST['username'] ?? ''));
$password = (string) ($_POST['password'] ?? '');

if ($cpu === false || $cpu === null || $cpu < 1 || $cpu > 16) {
    dhVpsJson([
        'success' => false,
        'error' => 'CPU must be between 1 and 16 cores.'
    ], 422);
}

if ($ram === false || $ram === null || $ram < 1 || $ram > 64) {
    dhVpsJson([
        'success' => false,
        'error' => 'RAM must be between 1 and 64 GB.'
    ], 422);
}

if (
    $storage === false ||
    $storage === null ||
    $storage < 20 ||
    $storage > 500
) {
    dhVpsJson([
        'success' => false,
        'error' => 'Storage must be between 20 and 500 GB.'
    ], 422);
}

if ($hostname === '') {
    $hostname = 'vps-' . date('Ymd-His');
}

if (!preg_match('/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/', $hostname)) {
    dhVpsJson([
        'success' => false,
        'error' => 'Hostname may contain only lowercase letters, numbers and hyphens.'
    ], 422);
}

if (!preg_match('/^[a-zA-Z0-9_-]{3,32}$/', $username)) {
    dhVpsJson([
        'success' => false,
        'error' => 'Username must be 3 to 32 characters and contain only letters, numbers, underscore or hyphen.'
    ], 422);
}

if (strlen($password) < 8 || strlen($password) > 128) {
    dhVpsJson([
        'success' => false,
        'error' => 'Password must be between 8 and 128 characters.'
    ], 422);
}

/*
 * Product 9 is intentionally Free.
 */
$productId = 9;

/*
 * AddOrder expects configurable option data in serialized/base64 form.
 * Quantity options are corrected immediately after the order is created
 * using UpdateClientProduct.
 */
$initialConfig = base64_encode(
    serialize([
        1 => 0,
        2 => 0,
        3 => 0,
    ])
);

$addOrder = localAPI('AddOrder', [
    'clientid' => $clientId,
    'pid' => [$productId],
    'qty' => [1],
    'billingcycle' => ['free'],
    'configoptions' => [$initialConfig],
    'paymentmethod' => 'banktransfer',
    'hostname' => [$hostname],
    'username' => [$username],
    'password' => [$password],
    'noinvoice' => true,
    'noinvoiceemail' => true,
    'noemail' => true,
]);

if (($addOrder['result'] ?? '') !== 'success') {
    logActivity(
        'DataHoteling VPS order failed: ' .
        ($addOrder['message'] ?? 'Unknown AddOrder error')
    );

    dhVpsJson([
        'success' => false,
        'stage' => 'AddOrder',
        'error' => $addOrder['message'] ?? 'Unable to create order.'
    ], 500);
}

$orderId = (int) ($addOrder['orderid'] ?? 0);

$serviceIds = $addOrder['serviceids'] ?? [];

if (is_string($serviceIds)) {
    $serviceIds = array_filter(
        array_map('intval', preg_split('/[,\s]+/', $serviceIds))
    );
}

$serviceId = (int) reset($serviceIds);

if ($orderId <= 0 || $serviceId <= 0) {
    dhVpsJson([
        'success' => false,
        'stage' => 'AddOrder',
        'error' => 'Order was created but service ID could not be determined.'
    ], 500);
}

/*
 * Correct Quantity-type configurable options.
 */
$correctConfig = base64_encode(
    serialize([
        1 => [
            'optionid' => 0,
            'qty' => $cpu,
        ],
        2 => [
            'optionid' => 0,
            'qty' => $ram,
        ],
        3 => [
            'optionid' => 0,
            'qty' => $storage,
        ],
    ])
);

$updateService = localAPI('UpdateClientProduct', [
    'serviceid' => $serviceId,
    'configoptions' => $correctConfig,
    'autorecalc' => false,
]);

if (($updateService['result'] ?? '') !== 'success') {
    logActivity(
        'DataHoteling VPS configuration failed for service ' .
        $serviceId . ': ' .
        ($updateService['message'] ?? 'Unknown UpdateClientProduct error')
    );

    dhVpsJson([
        'success' => false,
        'stage' => 'UpdateClientProduct',
        'orderid' => $orderId,
        'serviceid' => $serviceId,
        'error' => $updateService['message'] ?? 'Unable to save VPS configuration.'
    ], 500);
}

/*
 * Accept + automatic module provisioning.
 */
$acceptOrder = localAPI('AcceptOrder', [
    'orderid' => $orderId,
    'autosetup' => true,
    'sendemail' => false,
]);

if (($acceptOrder['result'] ?? '') !== 'success') {
    logActivity(
        'DataHoteling VPS provisioning failed for order ' .
        $orderId . ': ' .
        ($acceptOrder['message'] ?? 'Unknown AcceptOrder error')
    );

    dhVpsJson([
        'success' => false,
        'stage' => 'AcceptOrder',
        'orderid' => $orderId,
        'serviceid' => $serviceId,
        'error' => $acceptOrder['message'] ?? 'Unable to provision VPS.'
    ], 500);
}

dhVpsJson([
    'success' => true,
    'orderid' => $orderId,
    'serviceid' => $serviceId,
    'productid' => $productId,
    'hostname' => $hostname,
    'username' => $username,
    'configuration' => [
        'cpu' => $cpu,
        'ram' => $ram,
        'storage' => $storage,
    ],
    'message' => 'VPS order accepted and provisioning started.'
]);
