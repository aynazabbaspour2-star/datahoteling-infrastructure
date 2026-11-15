<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

require_once __DIR__ .
    '/../../modules/addons/datahoteling_sms/lib/sms.php';

add_hook('AfterCronJob', 100, function () {

    try {

        /*
         * SMS configuration
         */
        $config = datahoteling_sms_get_config();

        $enabled = $config['enabled'] ?? '';
        $apiKey = trim((string) ($config['api_key'] ?? ''));
        $lineNumber = trim((string) ($config['line_number'] ?? ''));
        $adminMobile = trim((string) ($config['admin_mobile'] ?? ''));

        $isEnabled = in_array(
            $enabled,
            ['on', '1', 1, 'yes'],
            true
        );

        if (
            !$isEnabled ||
            $apiKey === '' ||
            $lineNumber === '' ||
            $adminMobile === ''
        ) {
            return;
        }

        /*
         * Last processed order
         */
        $lastProcessedOrderId = 0;

        $baselineResult = select_query(
            'mod_datahoteling_sms_logs',
            'MAX(order_id) AS max_order_id',
            "event='OrderCreated_BASELINE'"
        );

        if ($baselineResult) {
            $baselineRow = mysql_fetch_assoc($baselineResult);

            if (!empty($baselineRow['max_order_id'])) {
                $lastProcessedOrderId =
                    (int) $baselineRow['max_order_id'];
            }
        }

        /*
         * If OrderCreated records exist,
         * continue from the latest one.
         */
        $processedResult = select_query(
            'mod_datahoteling_sms_logs',
            'MAX(order_id) AS max_order_id',
            "event='OrderCreated'"
        );

        if ($processedResult) {
            $processedRow = mysql_fetch_assoc($processedResult);

            if (!empty($processedRow['max_order_id'])) {
                $lastProcessedOrderId = max(
                    $lastProcessedOrderId,
                    (int) $processedRow['max_order_id']
                );
            }
        }

        /*
         * Find new orders.
         */
        $ordersResult = select_query(
            'tblorders',
            'id, userid, invoiceid, status, amount, date',
            'id > ' . $lastProcessedOrderId,
            'id ASC',
            '',
            '20'
        );

        if (!$ordersResult) {
            logModuleCall(
                'datahoteling_sms',
                'OrderCreated',
                [
                    'last_order_id' => $lastProcessedOrderId,
                ],
                'Could not query tblorders'
            );

            return;
        }

        while ($order = mysql_fetch_assoc($ordersResult)) {

            $orderId = (int) $order['id'];

            /*
             * Prevent duplicate notification.
             */
            $checkResult = select_query(
                'mod_datahoteling_sms_logs',
                'id',
                "event='OrderCreated' AND order_id=" . $orderId,
                'id DESC',
                '',
                '1'
            );

            if (
                $checkResult &&
                mysql_num_rows($checkResult) > 0
            ) {
                continue;
            }

            $clientId = (int) ($order['userid'] ?? 0);

            /*
             * Load client.
             */
            $firstName = '';

            if ($clientId > 0) {

                $clientResult = select_query(
                    'tblclients',
                    'firstname',
                    'id=' . $clientId
                );

                if ($clientResult) {

                    $client = mysql_fetch_assoc(
                        $clientResult
                    );

                    $firstName = trim(
                        (string) ($client['firstname'] ?? '')
                    );
                }
            }

            /*
             * Build SMS.
             */
            $message =
                "Datahoteling\n" .
                "سفارش جدید ثبت شد.\n" .
                "شماره سفارش: #" .
                $orderId .
                "\n";

            if ($firstName !== '') {
                $message .=
                    "مشتری: " .
                    $firstName .
                    "\n";
            }

            $invoiceId = (int) ($order['invoiceid'] ?? 0);

            if ($invoiceId > 0) {
                $message .=
                    "فاکتور: #" .
                    $invoiceId .
                    "\n";
            }

            $amount = (float) ($order['amount'] ?? 0);

            if ($amount > 0) {
                $message .=
                    "مبلغ: " .
                    number_format(
                        $amount,
                        0,
                        '.',
                        ','
                    ) .
                    "\n";
            }

            $message .=
                "لطفاً پنل WHMCS را بررسی کنید.";

            /*
             * Send SMS.
             */
            $result = datahoteling_sms_send_sms(
                $apiKey,
                $lineNumber,
                $adminMobile,
                $message
            );

            $success = !empty($result['success']);

            /*
             * Save SMS log.
             */
            insert_query(
                'mod_datahoteling_sms_logs',
                [
                    'event' => 'OrderCreated',
                    'order_id' => $orderId,
                    'invoice_id' => $invoiceId ?: null,
                    'client_id' => $clientId ?: null,
                    'mobile' => $adminMobile,
                    'message_id' =>
                        $result['message_id'] ?? null,
                    'pack_id' =>
                        $result['pack_id'] ?? null,
                    'status' =>
                        $success ? 'sent' : 'failed',
                    'http_code' =>
                        $result['http_code'] ?? null,
                    'cost' =>
                        $result['cost'] ?? null,
                    'error_message' =>
                        $success
                            ? null
                            : (
                                $result['message']
                                ?? 'Unknown SMS error'
                            ),
                    'created_at' =>
                        date('Y-m-d H:i:s'),
                ]
            );

            /*
             * WHMCS module log.
             */
            try {

                logModuleCall(
                    'datahoteling_sms',
                    'OrderCreated',
                    [
                        'order_id' => $orderId,
                        'client_id' => $clientId,
                    ],
                    $result
                );

            } catch (\Throwable $ignored) {
            }
        }

    } catch (\Throwable $e) {

        error_log(
            'Datahoteling SMS OrderCreated Cron Error: ' .
            $e->getMessage()
        );

        try {

            logModuleCall(
                'datahoteling_sms',
                'OrderCreated',
                [],
                $e->getMessage()
            );

        } catch (\Throwable $ignored) {
        }
    }
});
