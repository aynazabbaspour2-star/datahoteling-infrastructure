<?php

declare(strict_types=1);

use WHMCS\Database\Capsule;

require __DIR__ . '/init.php';

$clientId = (int) ($_SESSION['uid'] ?? 0);

if ($clientId <= 0) {
    header('Location: /index.php?rp=/login');
    exit;
}

$product = Capsule::table('tblproducts')
    ->where('id', 9)
    ->where('retired', 0)
    ->first();

if (!$product) {
    http_response_code(404);
    exit('VPS product not found.');
}

$configGroupId = (int) $product->gid;

$options = Capsule::table('tblproductconfigoptions')
    ->where('gid', $configGroupId)
    ->where('optiontype', 1)
    ->where('hidden', 0)
    ->orderBy('id')
    ->get();

$values = [];

foreach ($options as $option) {
    $values[(int) $option->id] = [
        'id' => (int) $option->id,
        'name' => (string) $option->optionname,
        'min' => (int) $option->qtyminimum,
        'max' => (int) $option->qtymaximum,
    ];
}

$csrf = $_SESSION['dh_vps_order_token'] ?? '';
if ($csrf === '') {
    $csrf = bin2hex(random_bytes(32));
    $_SESSION['dh_vps_order_token'] = $csrf;
}

$cpu = $values[1] ?? ['min' => 1, 'max' => 16, 'name' => 'CPU'];
$ram = $values[2] ?? ['min' => 1, 'max' => 64, 'name' => 'RAM'];
$storage = $values[3] ?? ['min' => 20, 'max' => 500, 'name' => 'Storage'];

?>
<!doctype html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>سفارش VPS | DataHoteling</title>

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/vazirmatn@33.0.3/Vazirmatn-font-face.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f5f7fb;
            color: #172033;
            font-family: Vazirmatn, Tahoma, sans-serif;
        }

        .dh-vps-wrap {
            max-width: 900px;
            margin: 50px auto;
            padding: 20px;
        }

        .dh-vps-card {
            background: #fff;
            border-radius: 22px;
            padding: 35px;
            box-shadow: 0 15px 45px rgba(20, 40, 80, .10);
        }

        h1 {
            margin-top: 0;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #687386;
            margin-bottom: 35px;
        }

        .field {
            margin-bottom: 30px;
        }

        .field-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .field-name {
            font-weight: 700;
        }

        .field-value {
            font-weight: 700;
            color: #175cff;
            direction: ltr;
        }

        input[type="range"] {
            width: 100%;
            cursor: pointer;
        }

        input[type="text"] {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #d9dfeb;
            border-radius: 12px;
            font-family: inherit;
            font-size: 15px;
            direction: ltr;
        }

        .order-btn {
            width: 100%;
            border: 0;
            border-radius: 13px;
            padding: 16px;
            background: #175cff;
            color: white;
            font-family: inherit;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
        }

        .order-btn:disabled {
            opacity: .6;
            cursor: wait;
        }

        .result {
            display: none;
            margin-top: 20px;
            padding: 15px;
            border-radius: 12px;
            white-space: pre-wrap;
        }

        .result.success {
            display: block;
            background: #e9f8ef;
            color: #166534;
        }

        .result.error {
            display: block;
            background: #fff0f0;
            color: #b42318;
        }
    </style>
</head>

<body>

<div class="dh-vps-wrap">
    <div class="dh-vps-card">

        <h1>ساخت VPS</h1>
        <div class="subtitle">
            منابع VPS خود را انتخاب کنید.
        </div>

        <form id="dhVpsOrderForm">

            <input type="hidden"
                   name="token"
                   value="<?= htmlspecialchars($csrf, ENT_QUOTES, 'UTF-8') ?>">

            <div class="field">
                <div class="field-head">
                    <span class="field-name">CPU</span>
                    <span class="field-value" id="cpuValue"></span>
                </div>

                <input
                    type="range"
                    id="cpu"
                    name="cpu"
                    min="<?= $cpu['min'] ?>"
                    max="<?= $cpu['max'] ?>"
                    value="<?= $cpu['min'] ?>"
                >
            </div>

            <div class="field">
                <div class="field-head">
                    <span class="field-name">RAM</span>
                    <span class="field-value" id="ramValue"></span>
                </div>

                <input
                    type="range"
                    id="ram"
                    name="ram"
                    min="<?= $ram['min'] ?>"
                    max="<?= $ram['max'] ?>"
                    value="<?= $ram['min'] ?>"
                >
            </div>

            <div class="field">
                <div class="field-head">
                    <span class="field-name">Storage</span>
                    <span class="field-value" id="storageValue"></span>
                </div>

                <input
                    type="range"
                    id="storage"
                    name="storage"
                    min="<?= $storage['min'] ?>"
                    max="<?= $storage['max'] ?>"
                    value="<?= $storage['min'] ?>"
                >
            </div>

            <div class="field">
                <div class="field-head">
                    <span class="field-name">Hostname</span>
                </div>

                <input
                    type="text"
                    id="hostname"
                    name="hostname"
                    placeholder="vps-aynaz"
                    maxlength="63"
                    pattern="[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
                    required
                >
            </div>

            <div class="field">
                <div class="field-head">
                    <span class="field-name">Username</span>
                </div>

                <input
                    type="text"
                    id="username"
                    name="username"
                    placeholder="aynaz"
                    minlength="3"
                    maxlength="32"
                    pattern="[a-zA-Z0-9_-]{3,32}"
                    autocomplete="username"
                    required
                >
            </div>

            <div class="field">
                <div class="field-head">
                    <span class="field-name">Password</span>
                </div>

                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="حداقل ۸ کاراکتر"
                    minlength="8"
                    maxlength="128"
                    autocomplete="new-password"
                    required
                >
            </div>

            <button class="order-btn" id="dhVpsSubmit" type="submit">
                سفارش و ساخت خودکار VPS
            </button>

            <div id="dhVpsResult" class="result"></div>

        </form>
    </div>
</div>

<script>
(function () {
    const form = document.getElementById('dhVpsOrderForm');
    const result = document.getElementById('dhVpsResult');
    const button = document.getElementById('dhVpsSubmit');

    function updateValues() {
        document.getElementById('cpuValue').textContent =
            document.getElementById('cpu').value + ' Core';

        document.getElementById('ramValue').textContent =
            document.getElementById('ram').value + ' GB';

        document.getElementById('storageValue').textContent =
            document.getElementById('storage').value + ' GB';
    }

    document.querySelectorAll('input[type="range"]').forEach(function (input) {
        input.addEventListener('input', updateValues);
    });

    updateValues();

    form.addEventListener('submit', async function (event) {
        event.preventDefault();

        button.disabled = true;
        result.className = 'result';
        result.textContent = '';

        try {
            const response = await fetch('/custom/vps-order.php', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type':
                        'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: new URLSearchParams(new FormData(form))
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.error || 'خطا در ثبت سفارش VPS');
            }

            result.className = 'result success';
            result.textContent =
                'سفارش با موفقیت ثبت شد.\n' +
                'Order ID: ' + data.orderid + '\n' +
                'Service ID: ' + data.serviceid + '\n' +
                'Hostname: ' + data.hostname;

        } catch (error) {
            result.className = 'result error';
            result.textContent = error.message || 'خطای ناشناخته';

        } finally {
            button.disabled = false;
        }
    });
})();
</script>

</body>
</html>
