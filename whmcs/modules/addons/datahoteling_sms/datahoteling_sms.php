<?php

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

require_once __DIR__ . '/lib/sms.php';


/**
 * Datahoteling SMS Addon Configuration
 */
function datahoteling_sms_config()
{
    return [
        'name' => 'Datahoteling SMS',
        'description' => 'SMS.ir integration for Datahoteling WHMCS',
        'version' => '1.2.0',
        'author' => 'Datahoteling',
        'language' => 'english',

        'fields' => [

            'api_key' => [
                'FriendlyName' => 'SMS.ir API Key',
                'Type' => 'password',
                'Size' => '60',
                'Description' => 'Your SMS.ir API key.',
            ],

            'line_number' => [
                'FriendlyName' => 'Sender Line',
                'Type' => 'text',
                'Size' => '30',
                'Default' => '30002128011552',
                'Description' => 'SMS.ir sender line number.',
            ],

            'enabled' => [
                'FriendlyName' => 'Enable SMS',
                'Type' => 'yesno',
                'Description' => 'Enable automatic SMS sending.',
            ],

            'invoice_paid' => [
                'FriendlyName' => 'Invoice Paid SMS',
                'Type' => 'yesno',
                'Description' => 'Send an SMS when an invoice is paid.',
            ],

            'admin_mobile' => [
                'FriendlyName' => 'Admin SMS Number',
                'Type' => 'text',
                'Size' => '30',
                'Default' => '09211634298',
                'Description' => 'Mobile number that receives new order notifications.',
            ],
        ],
    ];
}


/**
 * Activate Addon
 */
function datahoteling_sms_activate()
{
    try {

        $schema = \WHMCS\Database\Capsule::schema();

        if (!$schema->hasTable('mod_datahoteling_sms_logs')) {

            $schema->create(
                'mod_datahoteling_sms_logs',
                function ($table) {

                    $table->bigIncrements('id');

                    $table->string(
                        'event',
                        100
                    );

                    $table->unsignedBigInteger(
                        'invoice_id'
                    )->nullable();

                    $table->unsignedBigInteger(
                        'client_id'
                    )->nullable();

                    $table->string(
                        'mobile',
                        30
                    )->nullable();

                    $table->string(
                        'message_id',
                        100
                    )->nullable();

                    $table->string(
                        'pack_id',
                        100
                    )->nullable();

                    $table->string(
                        'status',
                        30
                    )->default('pending');

                    $table->integer(
                        'http_code'
                    )->nullable();

                    $table->integer(
                        'cost'
                    )->nullable();

                    $table->text(
                        'error_message'
                    )->nullable();

                    $table->timestamp(
                        'created_at'
                    )->useCurrent();

                    $table->index(
                        'invoice_id'
                    );

                    $table->index(
                        'client_id'
                    );

                    $table->index(
                        'message_id'
                    );

                    $table->unique([
                        'event',
                        'invoice_id'
                    ]);
                }
            );
        }

        return [
            'status' => 'success',
            'description' => 'Datahoteling SMS activated successfully.',
        ];

    } catch (\Throwable $e) {

        return [
            'status' => 'error',
            'description' => $e->getMessage(),
        ];
    }
}


/**
 * Upgrade Addon
 *
 * WHMCS calls this when the configured module version
 * changes.
 */
function datahoteling_sms_upgrade($vars)
{
    $currentlyInstalledVersion = $vars['version'];

    try {

        $schema = \WHMCS\Database\Capsule::schema();

        if (
            version_compare(
                $currentlyInstalledVersion,
                '1.2.0',
                '<'
            )
        ) {

            if (!$schema->hasTable('mod_datahoteling_sms_logs')) {

                $schema->create(
                    'mod_datahoteling_sms_logs',
                    function ($table) {

                        $table->bigIncrements('id');

                        $table->string(
                            'event',
                            100
                        );

                        $table->unsignedBigInteger(
                            'invoice_id'
                        )->nullable();

                        $table->unsignedBigInteger(
                            'client_id'
                        )->nullable();

                        $table->string(
                            'mobile',
                            30
                        )->nullable();

                        $table->string(
                            'message_id',
                            100
                        )->nullable();

                        $table->string(
                            'pack_id',
                            100
                        )->nullable();

                        $table->string(
                            'status',
                            30
                        )->default('pending');

                        $table->integer(
                            'http_code'
                        )->nullable();

                        $table->integer(
                            'cost'
                        )->nullable();

                        $table->text(
                            'error_message'
                        )->nullable();

                        $table->timestamp(
                            'created_at'
                        )->useCurrent();

                        $table->index(
                            'invoice_id'
                        );

                        $table->index(
                            'client_id'
                        );

                        $table->index(
                            'message_id'
                        );

                        $table->unique([
                            'event',
                            'invoice_id'
                        ]);
                    }
                );
            }
        }

    } catch (\Throwable $e) {

        logModuleCall(
            'datahoteling_sms',
            'upgrade',
            [
                'version' => $currentlyInstalledVersion,
            ],
            $e->getMessage(),
            '',
            []
        );
    }
}


/**
 * Deactivate Addon
 *
 * We intentionally DO NOT delete the SMS log table.
 * Historical SMS logs must survive deactivation.
 */
function datahoteling_sms_deactivate()
{
    return [
        'status' => 'success',
        'description' => 'Datahoteling SMS deactivated. SMS logs were preserved.',
    ];
}


/**
 * Admin Output
 */
function datahoteling_sms_output($vars)
{
    require_once __DIR__ . '/lib/sms.php';

    $moduleLink = $vars['modulelink'];

    $message = '';
    $messageType = 'info';

    /*
     * Send test SMS
     */
    if (
        isset($_POST['datahoteling_sms_action'])
        && $_POST['datahoteling_sms_action'] === 'send_test'
    ) {

        $mobile = trim(
            $_POST['mobile'] ?? ''
        );

        $smsText = trim(
            $_POST['sms_text'] ?? ''
        );

        $config = datahoteling_sms_get_config();

        $apiKey = trim(
            $config['api_key'] ?? ''
        );

        $lineNumber = trim(
            $config['line_number'] ?? ''
        );

        if ($apiKey === '') {

            $message = 'SMS.ir API Key is not configured.';
            $messageType = 'danger';

        } elseif ($lineNumber === '') {

            $message = 'Sender line is not configured.';
            $messageType = 'danger';

        } elseif ($mobile === '') {

            $message = 'Mobile number is required.';
            $messageType = 'danger';

        } elseif ($smsText === '') {

            $message = 'SMS text is required.';
            $messageType = 'danger';

        } else {

            $result = datahoteling_sms_send_sms(
                $apiKey,
                $lineNumber,
                $mobile,
                $smsText
            );

            if ($result['success']) {

                $messageType = 'success';

                $message =
                    '<strong>SMS sent successfully.</strong><br>'
                    . 'HTTP Code: '
                    . (int) $result['http_code']
                    . '<br>'
                    . 'Pack ID: '
                    . htmlspecialchars(
                        (string) $result['pack_id'],
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '<br>'
                    . 'Message ID: '
                    . htmlspecialchars(
                        implode(
                            ', ',
                            $result['message_ids']
                        ),
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '<br>'
                    . 'Cost: '
                    . (int) $result['cost'];

            } else {

                $messageType = 'danger';

                $message =
                    '<strong>SMS sending failed.</strong><br>'
                    . htmlspecialchars(
                        (string) $result['message'],
                        ENT_QUOTES,
                        'UTF-8'
                    );
            }
        }
    }


    /*
     * Read current configuration
     */
    $config = datahoteling_sms_get_config();

    $enabled = in_array(
        strtolower(
            (string) ($config['enabled'] ?? '')
        ),
        [
            'on',
            '1',
            'yes',
            'true',
        ],
        true
    );

    $invoicePaid = in_array(
        strtolower(
            (string) ($config['invoice_paid'] ?? '')
        ),
        [
            'on',
            '1',
            'yes',
            'true',
        ],
        true
    );

    $apiConfigured =
        !empty(
            $config['api_key']
        );

    $lineNumber =
        $config['line_number']
        ?? '';


    echo '<div class="card">';
    echo '<div class="card-body">';

    echo '<h2>Datahoteling SMS</h2>';

    echo '<p>';
    echo 'SMS.ir integration for Datahoteling WHMCS';
    echo '</p>';

    if ($message !== '') {

        echo '<div class="alert alert-'
            . htmlspecialchars(
                $messageType,
                ENT_QUOTES,
                'UTF-8'
            )
            . '">';

        echo $message;

        echo '</div>';
    }


    /*
     * Status
     */
    echo '<h3>SMS.ir Configuration</h3>';

    echo '<table class="table table-bordered">';

    echo '<tr>';
    echo '<td><strong>API Status</strong></td>';
    echo '<td>';

    if ($apiConfigured) {

        echo '<span class="label label-success">';
        echo 'Configured';
        echo '</span>';

    } else {

        echo '<span class="label label-danger">';
        echo 'Not Configured';
        echo '</span>';
    }

    echo '</td>';
    echo '</tr>';


    echo '<tr>';
    echo '<td><strong>Sender Line</strong></td>';
    echo '<td>'
        . htmlspecialchars(
            $lineNumber,
            ENT_QUOTES,
            'UTF-8'
        )
        . '</td>';
    echo '</tr>';


    echo '<tr>';
    echo '<td><strong>Automatic SMS</strong></td>';
    echo '<td>';

    if ($enabled) {

        echo '<span class="label label-success">';
        echo 'Enabled';
        echo '</span>';

    } else {

        echo '<span class="label label-default">';
        echo 'Disabled';
        echo '</span>';
    }

    echo '</td>';
    echo '</tr>';


    echo '<tr>';
    echo '<td><strong>Invoice Paid SMS</strong></td>';
    echo '<td>';

    if ($invoicePaid) {

        echo '<span class="label label-success">';
        echo 'Enabled';
        echo '</span>';

    } else {

        echo '<span class="label label-default">';
        echo 'Disabled';
        echo '</span>';
    }

    echo '</td>';
    echo '</tr>';

    echo '</table>';


    /*
     * Test SMS form
     */
    echo '<hr>';

    echo '<h3>Send Test SMS</h3>';

    echo '<form method="post" action="'
        . htmlspecialchars(
            $moduleLink,
            ENT_QUOTES,
            'UTF-8'
        )
        . '">';

    echo '<input type="hidden" '
        . 'name="datahoteling_sms_action" '
        . 'value="send_test">';


    echo '<div class="form-group">';

    echo '<label for="datahoteling_sms_mobile">';
    echo 'Mobile Number';
    echo '</label>';

    echo '<input '
        . 'type="text" '
        . 'class="form-control" '
        . 'id="datahoteling_sms_mobile" '
        . 'name="mobile" '
        . 'placeholder="09123456789" '
        . 'required>';

    echo '</div>';


    echo '<div class="form-group">';

    echo '<label for="datahoteling_sms_text">';
    echo 'SMS Text';
    echo '</label>';

    echo '<textarea '
        . 'class="form-control" '
        . 'id="datahoteling_sms_text" '
        . 'name="sms_text" '
        . 'rows="5" '
        . 'required>'
        . 'Datahoteling: تست اتصال SMS.ir با موفقیت انجام شد.'
        . '</textarea>';

    echo '</div>';


    echo '<button '
        . 'type="submit" '
        . 'class="btn btn-primary">';

    echo 'Send Test SMS';

    echo '</button>';

    echo '</form>';

    echo '</div>';
    echo '</div>';


    /*
     * SMS Logs
     */
    echo '<div class="card" style="margin-top:20px;">';

    echo '<div class="card-body">';

    echo '<h3>SMS Logs</h3>';

    try {

        $logs = \WHMCS\Database\Capsule::table(
            'mod_datahoteling_sms_logs'
        )
        ->orderBy(
            'id',
            'desc'
        )
        ->limit(20)
        ->get();

        if ($logs->count() === 0) {

            echo '<p>';
            echo 'No SMS logs yet.';
            echo '</p>';

        } else {

            echo '<div class="table-responsive">';

            echo '<table class="table table-striped table-bordered">';

            echo '<thead>';
            echo '<tr>';

            echo '<th>ID</th>';
            echo '<th>Event</th>';
            echo '<th>Invoice</th>';
            echo '<th>Client</th>';
            echo '<th>Mobile</th>';
            echo '<th>Status</th>';
            echo '<th>Message ID</th>';
            echo '<th>HTTP</th>';
            echo '<th>Created</th>';

            echo '</tr>';
            echo '</thead>';

            echo '<tbody>';

            foreach ($logs as $log) {

                echo '<tr>';

                echo '<td>'
                    . (int) $log->id
                    . '</td>';

                echo '<td>'
                    . htmlspecialchars(
                        $log->event,
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '</td>';

                echo '<td>'
                    . (int) $log->invoice_id
                    . '</td>';

                echo '<td>'
                    . (int) $log->client_id
                    . '</td>';

                echo '<td>'
                    . htmlspecialchars(
                        $log->mobile ?? '',
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '</td>';

                echo '<td>'
                    . htmlspecialchars(
                        $log->status,
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '</td>';

                echo '<td>'
                    . htmlspecialchars(
                        $log->message_id ?? '',
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '</td>';

                echo '<td>'
                    . (int) $log->http_code
                    . '</td>';

                echo '<td>'
                    . htmlspecialchars(
                        $log->created_at ?? '',
                        ENT_QUOTES,
                        'UTF-8'
                    )
                    . '</td>';

                echo '</tr>';
            }

            echo '</tbody>';

            echo '</table>';

            echo '</div>';
        }

    } catch (\Throwable $e) {

        echo '<div class="alert alert-warning">';
        echo 'Unable to load SMS logs.';
        echo '</div>';

        logModuleCall(
            'datahoteling_sms',
            'admin_logs',
            [],
            $e->getMessage(),
            '',
            []
        );
    }

    echo '</div>';
    echo '</div>';
}
