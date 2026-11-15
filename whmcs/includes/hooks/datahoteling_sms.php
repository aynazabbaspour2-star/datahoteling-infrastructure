<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

require_once __DIR__ .
    '/../../modules/addons/datahoteling_sms/lib/sms.php';

use Illuminate\Database\Capsule;

/**
 * Datahoteling SMS
 *
 * InvoicePaid -> Send SMS.ir notification
 *
 * Safety:
 * - SMS is sent only when addon "enabled" is enabled.
 * - One successful SMS per invoice/event.
 * - API key and SMS body are never logged.
 * - Mobile number is masked in WHMCS logs.
 */
add_hook('InvoicePaid', 100, function ($vars) {

    $invoiceId = (int) ($vars['invoiceid'] ?? 0);

    if (!$invoiceId) {
        return;
    }

    try {

        /*
         * Load addon configuration
         */
        $config = datahoteling_sms_get_config();

        $enabled = $config['enabled'] ?? '';
        $invoicePaidEnabled = $config['invoice_paid'] ?? '';

        $isEnabled = (
            $enabled === 'on' ||
            $enabled === '1' ||
            $enabled === 1 ||
            $enabled === 'yes'
        );

        $isInvoicePaidEnabled = (
            $invoicePaidEnabled === 'on' ||
            $invoicePaidEnabled === '1' ||
            $invoicePaidEnabled === 1 ||
            $invoicePaidEnabled === 'yes'
        );

        if (!$isEnabled || !$isInvoicePaidEnabled) {
            return;
        }

        $apiKey = trim((string) ($config['api_key'] ?? ''));
        $lineNumber = trim((string) ($config['line_number'] ?? ''));

        if ($apiKey === '' || $lineNumber === '') {

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                ],
                [
                    'success' => false,
                    'reason' => 'SMS configuration missing',
                ]
            );

            return;
        }

        /*
         * ---------------------------------------------------------
         * Deduplication
         * ---------------------------------------------------------
         *
         * If this invoice already has a successful InvoicePaid
         * record, do not send another SMS.
         */

        $alreadySent = Capsule::table('mod_datahoteling_sms_logs')
            ->where('event', 'InvoicePaid')
            ->where('invoice_id', $invoiceId)
            ->where('status', 'success')
            ->exists();

        if ($alreadySent) {

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                ],
                [
                    'success' => true,
                    'skipped' => true,
                    'reason' => 'SMS already sent for this invoice',
                ]
            );

            return;
        }

        /*
         * Get invoice
         */
        $invoice = \WHMCS\Billing\Invoice::find($invoiceId);

        if (!$invoice) {

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                ],
                [
                    'success' => false,
                    'reason' => 'Invoice not found',
                ]
            );

            return;
        }

        /*
         * Get client
         */
        $clientId = (int) $invoice->userid;

        if (!$clientId) {

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                ],
                [
                    'success' => false,
                    'reason' => 'Invoice has no client',
                ]
            );

            return;
        }

        $client = \WHMCS\User\Client::find($clientId);

        if (!$client) {

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                    'clientid' => $clientId,
                ],
                [
                    'success' => false,
                    'reason' => 'Client not found',
                ]
            );

            return;
        }

        /*
         * Normalize mobile
         */
        $mobile = datahoteling_sms_normalize_mobile(
            (string) $client->phonenumber
        );

        if ($mobile === '') {

            Capsule::table('mod_datahoteling_sms_logs')->insert([
                'event' => 'InvoicePaid',
                'invoice_id' => $invoiceId,
                'client_id' => $clientId,
                'mobile' => null,
                'status' => 'failed',
                'error_message' => 'Client has no valid mobile number',
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            logModuleCall(
                'datahoteling_sms',
                'InvoicePaid',
                [
                    'invoiceid' => $invoiceId,
                    'clientid' => $clientId,
                ],
                [
                    'success' => false,
                    'reason' => 'Client has no valid mobile number',
                ]
            );

            return;
        }

        /*
         * Customer name
         */
        $firstName = trim((string) $client->firstname);

        if ($firstName === '') {
            $firstName = 'مشتری';
        }

        /*
         * Invoice amount
         */
        $amount = number_format(
            (float) $invoice->total,
            0,
            '.',
            ','
        );

        /*
         * SMS body
         */
        $smsText =
            "Datahoteling\n"
            . "سلام {$firstName} عزیز 🌹\n"
            . "پرداخت فاکتور #{$invoiceId} "
            . "به مبلغ {$amount} با موفقیت انجام شد.\n"
            . "از اعتماد شما سپاسگزاریم.";

        /*
         * Send SMS
         */
        $result = datahoteling_sms_send_sms(
            $apiKey,
            $lineNumber,
            $mobile,
            $smsText
        );

        $success = !empty($result['success']);

        $status = $success
            ? 'success'
            : 'failed';

        $messageIds = $result['message_ids'] ?? [];

        $messageId = null;

        if (is_array($messageIds) && !empty($messageIds)) {
            $messageId = (string) $messageIds[0];
        }

        $packId = !empty($result['pack_id'])
            ? (string) $result['pack_id']
            : null;

        $httpCode = isset($result['http_code'])
            ? (int) $result['http_code']
            : null;

        $cost = isset($result['cost'])
            ? (int) $result['cost']
            : null;

        $errorMessage = $success
            ? null
            : (string) ($result['message'] ?? 'SMS sending failed');

        /*
         * Store result in database
         */
        Capsule::table('mod_datahoteling_sms_logs')->insert([
            'event' => 'InvoicePaid',
            'invoice_id' => $invoiceId,
            'client_id' => $clientId,
            'mobile' => $mobile,
            'message_id' => $messageId,
            'pack_id' => $packId,
            'status' => $status,
            'http_code' => $httpCode,
            'cost' => $cost,
            'error_message' => $errorMessage,
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        /*
         * WHMCS module log
         *
         * Never log:
         * - API key
         * - SMS body
         * - full mobile number
         */
        logModuleCall(
            'datahoteling_sms',
            'InvoicePaid',
            [
                'invoiceid' => $invoiceId,
                'clientid' => $clientId,
                'mobile' =>
                    substr($mobile, 0, 4)
                    . '****'
                    . substr($mobile, -2),
            ],
            [
                'success' => $success,
                'status' => $status,
                'http_code' => $httpCode,
                'pack_id' => $packId,
                'message_id' => $messageId,
                'cost' => $cost,
                'message' => $success
                    ? 'SMS accepted by SMS.ir'
                    : $errorMessage,
            ]
        );

    } catch (\Throwable $e) {

        /*
         * Never expose API key or SMS body in exception logs.
         */
        logModuleCall(
            'datahoteling_sms',
            'InvoicePaid',
            [
                'invoiceid' => $invoiceId,
            ],
            [
                'success' => false,
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]
        );
    }
});
