<?php

use WHMCS\Database\Capsule;

require_once __DIR__ . '/../../../init.php';
require_once __DIR__ . '/../../../includes/gatewayfunctions.php';
require_once __DIR__ . '/../../../includes/invoicefunctions.php';

$gatewayModuleName = 'sep';

$gatewayParams = getGatewayVariables($gatewayModuleName);

if (!$gatewayParams || empty($gatewayParams['type'])) {
    http_response_code(500);
    exit('SEP gateway is not active.');
}

/*
 * SEP callback can arrive via POST.
 * For testing / compatibility we also accept GET.
 */
$data = array_merge($_GET, $_POST);

$invoiceId = 0;
$resNum    = trim((string) ($data['ResNum'] ?? ''));

if (preg_match('/^DH-(\d+)$/', $resNum, $matches)) {
    $invoiceId = (int) $matches[1];
}

/*
 * Some SEP responses may return ResNum in another casing.
 */
if (!$invoiceId) {
    foreach (['resnum', 'ResNum', 'InvoiceId', 'invoiceid'] as $key) {
        if (!empty($data[$key]) && preg_match('/(\d+)/', (string) $data[$key], $m)) {
            $invoiceId = (int) $m[1];
            break;
        }
    }
}

if (!$invoiceId) {
    logTransaction(
        'Saman SEP',
        [
            'callback' => $data,
        ],
        'INVALID CALLBACK'
    );

    http_response_code(400);
    exit('Invalid SEP callback.');
}

/*
 * Load WHMCS invoice.
 */
try {
    $invoice = Capsule::table('tblinvoices')
        ->where('id', $invoiceId)
        ->first();
} catch (\Throwable $e) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'error'     => $e->getMessage(),
        ],
        'DATABASE ERROR'
    );

    http_response_code(500);
    exit('Database error.');
}

if (!$invoice) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'callback'  => $data,
        ],
        'INVOICE NOT FOUND'
    );

    http_response_code(404);
    exit('Invoice not found.');
}

/*
 * If already paid, do not process it again.
 */
if ($invoice->status === 'Paid') {
    echo 'Invoice already paid.';
    exit;
}

/*
 * Check transaction status returned by SEP.
 */
$state = strtoupper(trim((string) (
    $data['State']
    ?? $data['Status']
    ?? ''
)));

if ($state !== '' && !in_array($state, ['OK', '1', 'SUCCESS'], true)) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'callback'  => $data,
        ],
        'PAYMENT FAILED'
    );

    echo 'Payment was not successful.';
    exit;
}

$refNum = trim((string) (
    $data['RefNum']
    ?? $data['RefNumber']
    ?? ''
));

$callbackAmount = isset($data['Amount'])
    ? (int) $data['Amount']
    : 0;

/*
 * WHMCS invoice amount.
 */
$invoiceAmount = (int) round((float) $invoice->total);

/*
 * Amount mismatch is never accepted.
 */
if ($callbackAmount > 0 && $callbackAmount !== $invoiceAmount) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid'       => $invoiceId,
            'invoice_amount'  => $invoiceAmount,
            'callback_amount' => $callbackAmount,
            'callback'        => $data,
        ],
        'AMOUNT MISMATCH'
    );

    http_response_code(400);
    exit('Payment amount mismatch.');
}

/*
 * VerifyTransaction
 */
$terminalId = trim((string) ($gatewayParams['TerminalId'] ?? ''));

if ($terminalId === '') {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
        ],
        'TERMINAL NOT CONFIGURED'
    );

    http_response_code(500);
    exit('SEP Terminal ID is not configured.');
}

if ($refNum === '') {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'callback'  => $data,
        ],
        'REFNUM MISSING'
    );

    http_response_code(400);
    exit('SEP RefNum is missing.');
}

$verifyRequest = [
    'RefNum'         => $refNum,
    'TerminalNumber' => is_numeric($terminalId)
        ? (int) $terminalId
        : $terminalId,
];

$ch = curl_init(
    'https://sep.shaparak.ir/verifyTxnRandomSessionkey/ipg/VerifyTransaction'
);

curl_setopt_array($ch, [
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => json_encode(
        $verifyRequest,
        JSON_UNESCAPED_SLASHES
    ),
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => [
        'Content-Type: application/json',
        'Accept: application/json',
    ],
    CURLOPT_CONNECTTIMEOUT => 10,
    CURLOPT_TIMEOUT        => 30,
    CURLOPT_SSL_VERIFYPEER => true,
    CURLOPT_SSL_VERIFYHOST => 2,
]);

$verifyBody = curl_exec($ch);

if ($verifyBody === false) {
    $curlError = curl_error($ch);
    curl_close($ch);

    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'refnum'    => $refNum,
            'error'     => $curlError,
        ],
        'VERIFY CURL ERROR'
    );

    http_response_code(502);
    exit('Unable to verify SEP transaction.');
}

$verifyHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

$verifyResponse = json_decode($verifyBody, true);

if (!is_array($verifyResponse)) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'refnum'    => $refNum,
            'http_code' => $verifyHttpCode,
            'response'  => $verifyBody,
        ],
        'INVALID VERIFY RESPONSE'
    );

    http_response_code(502);
    exit('Invalid SEP verification response.');
}

/*
 * Log the raw verification response for the first real test.
 */
logTransaction(
    'Saman SEP',
    [
        'invoiceid' => $invoiceId,
        'refnum'    => $refNum,
        'response'  => $verifyResponse,
    ],
    'VERIFY RESPONSE'
);

/*
 * SEP documentation:
 * ResultCode = 0 means successful verification.
 *
 * We intentionally do NOT accept a missing ResultCode.
 */
$resultCode = $verifyResponse['ResultCode']
    ?? $verifyResponse['resultCode']
    ?? null;

if ((string) $resultCode !== '0') {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'refnum'    => $refNum,
            'verify'    => $verifyResponse,
        ],
        'VERIFY FAILED'
    );

    echo 'Payment verification failed.';
    exit;
}

/*
 * Try to obtain verified amount from the response.
 */
$verifiedAmount = 0;

foreach ([
    'Amount',
    'amount',
    'TransactionAmount',
    'transactionAmount',
] as $key) {
    if (isset($verifyResponse[$key]) && is_numeric($verifyResponse[$key])) {
        $verifiedAmount = (int) $verifyResponse[$key];
        break;
    }
}

/*
 * If SEP returned a verified amount, it MUST match the invoice.
 */
if ($verifiedAmount > 0 && $verifiedAmount !== $invoiceAmount) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid'       => $invoiceId,
            'invoice_amount'  => $invoiceAmount,
            'verified_amount' => $verifiedAmount,
            'verify'          => $verifyResponse,
        ],
        'VERIFY AMOUNT MISMATCH'
    );

    http_response_code(400);
    exit('Verified payment amount mismatch.');
}

/*
 * Protect against processing the same RefNum twice.
 */
$existingTransaction = Capsule::table('tblaccounts')
    ->where('gateway', $gatewayParams['name'] ?? 'sep')
    ->where('transid', $refNum)
    ->first();

if ($existingTransaction) {
    echo 'Transaction already processed.';
    exit;
}

/*
 * Register the payment in WHMCS.
 */
addInvoicePayment(
    $invoiceId,
    $refNum,
    $invoiceAmount,
    0,
    $gatewayModuleName
);

logTransaction(
    'Saman SEP',
    [
        'invoiceid' => $invoiceId,
        'refnum'    => $refNum,
        'amount'    => $invoiceAmount,
        'verify'    => $verifyResponse,
    ],
    'PAYMENT SUCCESS'
);

/*
 * Accept pending WHMCS orders belonging to this paid invoice.
 *
 * The hosting service may already have been provisioned because the
 * product currently uses Auto Setup = Order. Therefore we explicitly
 * use autosetup=false here to avoid provisioning the same service again.
 */
try {
    $orders = Capsule::table('tblorders')
        ->where('invoiceid', $invoiceId)
        ->where('status', 'Pending')
        ->get();

    foreach ($orders as $order) {
        $acceptResult = localAPI(
            'AcceptOrder',
            [
                'orderid'  => (int) $order->id,
                'autosetup' => false,
                'sendemail' => false,
            ],
            'aynaz'
        );

        if (($acceptResult['result'] ?? '') !== 'success') {
            logTransaction(
                'Saman SEP',
                [
                    'invoiceid' => $invoiceId,
                    'orderid'   => (int) $order->id,
                    'result'    => $acceptResult,
                ],
                'ORDER ACCEPT FAILED'
            );
        } else {
            logTransaction(
                'Saman SEP',
                [
                    'invoiceid' => $invoiceId,
                    'orderid'   => (int) $order->id,
                ],
                'ORDER ACCEPTED'
            );
        }
    }
} catch (\Throwable $e) {
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $invoiceId,
            'error'     => $e->getMessage(),
        ],
        'ORDER ACCEPT EXCEPTION'
    );
}

header(
    'Location: ' . rtrim($gatewayParams['systemurl'] ?? 'https://datahoteling.com/', '/') .
    '/viewinvoice.php?id=' . $invoiceId
);
exit;
