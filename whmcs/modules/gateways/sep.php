<?php

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

/**
 * Saman SEP OnlinePG Gateway for WHMCS
 *
 * Flow:
 * 1. Request token from SEP
 * 2. Receive token
 * 3. POST token to SEP OnlinePG
 * 4. SEP redirects customer back to callback/sep.php
 */

function sep_config()
{
    return [
        'FriendlyName' => [
            'Type' => 'System',
            'Value' => 'Saman SEP',
        ],

        'TerminalId' => [
            'FriendlyName' => 'Terminal ID',
            'Type' => 'text',
            'Size' => '20',
            'Default' => '',
            'Description' => 'SEP Terminal ID / MID',
        ],

        'TokenExpiryInMin' => [
            'FriendlyName' => 'Token Expiry',
            'Type' => 'text',
            'Size' => '10',
            'Default' => '20',
            'Description' => 'Token expiry in minutes.',
        ],
    ];
}

/**
 * Create SEP payment request.
 */
function sep_link($params)
{
    logTransaction(
        'Saman SEP',
        [
            'invoiceid' => $params['invoiceid'] ?? '',
            'amount' => $params['amount'] ?? '',
            'currency' => $params['currency'] ?? '',
            'systemurl' => $params['systemurl'] ?? '',
            'terminal_present' => !empty($params['TerminalId']) ? 'YES' : 'NO',
            'token_expiry_present' => isset($params['TokenExpiryInMin']) ? 'YES' : 'NO',
            'client_id' => $params['clientdetails']['userid'] ?? '',
        ],
        'SEP DEBUG PARAMS'
    );

    $terminalId = trim($params['TerminalId']);
    $invoiceId  = (int) $params['invoiceid'];

    if ($terminalId === '') {
        return '<div class="alert alert-danger">SEP Terminal ID is not configured.</div>';
    }

    /*
     * WHMCS gateway amount is normally in the currency configured
     * for the invoice. SEP expects integer Rials.
     *
     * DataHoteling should therefore use IRR for this gateway.
     */
    $amount = (int) round((float) $params['amount']);

    if ($amount < 2000) {
        return '<div class="alert alert-danger">SEP minimum transaction amount is 2000 IRR.</div>';
    }

    /*
     * Unique reservation number.
     *
     * Using the WHMCS invoice ID keeps the value deterministic
     * and allows callback validation.
     */
    $resNum = 'DH-' . $invoiceId;

    /*
     * The callback URL is the WHMCS gateway callback endpoint.
     */
    $redirectUrl = rtrim($params['systemurl'], '/')
        . '/modules/gateways/callback/sep.php';

    $tokenExpiry = (int) ($params['TokenExpiryInMin'] ?: 20);

    if ($tokenExpiry < 20) {
        $tokenExpiry = 20;
    }

    if ($tokenExpiry > 3600) {
        $tokenExpiry = 3600;
    }

    $request = [
        'action'           => 'token',
        'TerminalId'       => $terminalId,
        'Amount'           => $amount,
        'ResNum'           => $resNum,
        'RedirectUrl'      => $redirectUrl,
        'TokenExpiryInMin' => $tokenExpiry,
    ];

    $ch = curl_init('https://sep.shaparak.ir/onlinepg/onlinepg');

    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => json_encode($request, JSON_UNESCAPED_SLASHES),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HEADER         => true,
        CURLOPT_HTTPHEADER     => [
            'Content-Type: application/json',
            'Accept: application/json',
        ],
        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_TIMEOUT        => 30,
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
    ]);

    $response = curl_exec($ch);

    if ($response === false) {
        $error = curl_error($ch);
        curl_close($ch);

        logTransaction(
            'Saman SEP',
            [
                'invoiceid' => $invoiceId,
                'error'     => $error,
            ],
            'CURL ERROR'
        );

        return '<div class="alert alert-danger">'
            . 'Unable to connect to Saman SEP.'
            . '</div>';
    }

    $httpCode   = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);

    curl_close($ch);

    $rawHeaders = substr($response, 0, $headerSize);
    $body       = substr($response, $headerSize);

    $decoded = json_decode($body, true);

    /*
     * Use the Classic SEP OnlinePG endpoint.
     *
     * The token endpoint may return X-IPG-Url pointing to Neo-PG,
     * but direct testing confirms that the Classic OnlinePG flow
     * accepts the generated token correctly.
     */
    $ipgUrl = 'https://sep.shaparak.ir/OnlinePG/OnlinePG';

    if (
        $httpCode < 200 ||
        $httpCode >= 300 ||
        !is_array($decoded) ||
        (int) ($decoded['status'] ?? 0) !== 1 ||
        empty($decoded['token'])
    ) {
        logTransaction(
            'Saman SEP',
            [
                'invoiceid' => $invoiceId,
                'http_code' => $httpCode,
                'request'   => $request,
                'response'  => $body,
            ],
            'TOKEN ERROR'
        );

        return '<div class="alert alert-danger">'
            . 'Saman SEP could not create the payment token.'
            . '</div>';
    }

    $token = htmlspecialchars(
        (string) $decoded['token'],
        ENT_QUOTES,
        'UTF-8'
    );

    $safeIpgUrl = htmlspecialchars(
        $ipgUrl,
        ENT_QUOTES,
        'UTF-8'
    );

    /*
     * POST token to SEP as recommended by the documentation.
     */
    return '
<form id="sep-payment-form" method="post" action="' . $safeIpgUrl . '">
    <input type="hidden" name="Token" value="' . $token . '">
    <input type="hidden" name="GetMethod" value="">
    <noscript>
        <button type="submit" class="btn btn-primary">
            Continue to Saman Payment Gateway
        </button>
    </noscript>
</form>

<script>
(function () {
    var form = document.getElementById("sep-payment-form");
    if (form) {
        form.submit();
    }
})();
</script>';
}
