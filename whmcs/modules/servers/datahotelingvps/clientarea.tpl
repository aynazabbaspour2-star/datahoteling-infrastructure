<div class="datahoteling-vps-dashboard" dir="rtl">

    <style>
        .datahoteling-vps-dashboard {
            font-family: inherit;
        }

        .dh-vps-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 24px;
            margin-bottom: 20px;
            border-radius: 16px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
        }

        .dh-vps-title {
            margin: 0 0 6px;
            font-size: 24px;
            font-weight: 700;
        }

        .dh-vps-hostname {
            color: #6b7280;
            font-size: 14px;
        }

        .dh-vps-status {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 7px 12px;
            border-radius: 999px;
            background: #ecfdf5;
            color: #047857;
            font-size: 13px;
            font-weight: 600;
            white-space: nowrap;
        }

        .dh-vps-status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
        }

        .dh-vps-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }

        .dh-vps-card {
            padding: 20px;
            border-radius: 16px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
        }

        .dh-vps-card-title {
            margin: 0 0 16px;
            font-size: 16px;
            font-weight: 700;
        }

        .dh-vps-info-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .dh-vps-info-row:last-child {
            border-bottom: 0;
        }

        .dh-vps-label {
            color: #6b7280;
            font-size: 13px;
        }

        .dh-vps-value {
            color: #111827;
            font-size: 14px;
            font-weight: 600;
            text-align: left;
            direction: ltr;
        }

        .dh-vps-resource {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .dh-vps-resource:last-child {
            border-bottom: 0;
        }

        .dh-vps-resource-name {
            color: #6b7280;
            font-size: 13px;
        }

        .dh-vps-resource-value {
            font-weight: 700;
            color: #111827;
        }

        .dh-vps-actions {
            margin-bottom: 20px;
            padding: 20px;
            border-radius: 16px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
        }

        .dh-vps-actions-title {
            margin: 0 0 14px;
            font-size: 16px;
            font-weight: 700;
        }

        .dh-vps-actions-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
        }

        .dh-vps-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 44px;
            padding: 10px 16px;
            border: 0;
            border-radius: 10px;
            font-family: inherit;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
        }

        .dh-vps-action-on {
            background: #dcfce7;
            color: #166534;
        }

        .dh-vps-action-shutdown {
            background: #fee2e2;
            color: #991b1b;
        }

        .dh-vps-action-restart {
            background: #fef3c7;
            color: #92400e;
        }

        .dh-vps-action:hover {
            opacity: 0.88;
        }

        .dh-vps-operation-status {
            margin-top: 14px;
            padding: 14px 16px;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            background: #f8fafc;
        }

        .dh-vps-operation-status-title {
            margin: 0 0 6px;
            font-size: 13px;
            font-weight: 700;
            color: #374151;
        }

        .dh-vps-operation-status-text {
            margin: 0;
            font-size: 14px;
            line-height: 1.7;
            color: #475569;
        }

        .dh-vps-operation-status-id {
            margin-top: 6px;
            font-size: 11px;
            color: #94a3b8;
            direction: ltr;
            text-align: left;
            word-break: break-all;
        }

        .dh-vps-operation-queued {
            background: #eff6ff;
            border-color: #bfdbfe;
        }

        .dh-vps-operation-running {
            background: #fffbeb;
            border-color: #fde68a;
        }

        .dh-vps-operation-succeeded {
            background: #ecfdf5;
            border-color: #a7f3d0;
        }

        .dh-vps-operation-failed {
            background: #fef2f2;
            border-color: #fecaca;
        }

        .dh-vps-password-card {
            margin-top: 20px;
        }

        .dh-vps-reinstall-card {
            margin-top: 20px;
        }

        .dh-vps-reinstall-warning {
            margin: 0 0 18px;
            padding: 14px 16px;
            border-radius: 12px;
            background: #fff7ed;
            border: 1px solid #fed7aa;
            color: #9a3412;
            line-height: 1.8;
            font-size: 13px;
        }

        .dh-vps-action-reinstall {
            background: #fee2e2;
            color: #991b1b;
        }

        .dh-vps-action-reinstall:hover {
            opacity: 0.88;
        }

        .dh-vps-password-description {
            margin: 0 0 18px;
            color: #64748b;
            line-height: 1.8;
        }

        .dh-vps-password-fields {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin-bottom: 18px;
        }

        .dh-vps-field {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .dh-vps-field label {
            font-weight: 700;
            color: #0f172a;
        }

        .dh-vps-field input {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #dbe3ef;
            border-radius: 10px;
            padding: 11px 13px;
            background: #fff;
            color: #0f172a;
            font-size: 14px;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }

        .dh-vps-field input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, .10);
        }

        .dh-vps-field small {
            color: #64748b;
            font-size: 12px;
        }

        .dh-vps-action-password {
            border: 0;
            cursor: pointer;
        }

        @media (max-width: 700px) {
            .dh-vps-password-fields {
                grid-template-columns: 1fr;
            }
        }

        .dh-vps-monitoring {
            margin-top: 20px;
            padding: 20px;
            border-radius: 16px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
        }

        .dh-vps-monitoring-title {
            margin: 0 0 8px;
            font-size: 16px;
            font-weight: 700;
        }

        .dh-vps-monitoring-text {
            margin: 0;
            color: #64748b;
            font-size: 14px;
            line-height: 1.8;
        }

        @media (max-width: 768px) {
            .dh-vps-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .dh-vps-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="dh-vps-header">
        <div>
            <h2 class="dh-vps-title">
                {$package}
            </h2>

            <div class="dh-vps-hostname">
                {$hostname}
            </div>
        </div>

        <div class="dh-vps-status">
            <span class="dh-vps-status-dot"></span>
            فعال
        </div>
    </div>

    <div class="dh-vps-actions">
        <h3 class="dh-vps-actions-title">
            مدیریت VPS
        </h3>

        <div class="dh-vps-actions-grid">

            <form method="post"
                  action="clientarea.php?action=productdetails"
                  onsubmit="return confirm('آیا از روشن کردن VPS مطمئن هستید؟');">
                <input type="hidden" name="id" value="{$serviceId}">
                <input type="hidden" name="modop" value="custom">
                <input type="hidden" name="a" value="PowerOn">
                <button
                    type="submit"
                    class="dh-vps-action dh-vps-action-on">
                    روشن کردن VPS
                </button>
            </form>

            <form method="post"
                  action="clientarea.php?action=productdetails"
                  onsubmit="return confirm('آیا از خاموش کردن VPS مطمئن هستید؟');">
                <input type="hidden" name="id" value="{$serviceId}">
                <input type="hidden" name="modop" value="custom">
                <input type="hidden" name="a" value="Shutdown">
                <button
                    type="submit"
                    class="dh-vps-action dh-vps-action-shutdown">
                    خاموش کردن VPS
                </button>
            </form>

            <form method="post"
                  action="clientarea.php?action=productdetails"
                  onsubmit="return confirm('آیا از راه‌اندازی مجدد VPS مطمئن هستید؟');">
                <input type="hidden" name="id" value="{$serviceId}">
                <input type="hidden" name="modop" value="custom">
                <input type="hidden" name="a" value="Restart">
                <button
                    type="submit"
                    class="dh-vps-action dh-vps-action-restart">
                    راه‌اندازی مجدد VPS
                </button>
            </form>

        </div>

        {if $managementOperationId}
            <div class="dh-vps-operation-status
                {if $managementStatus == 'queued'}dh-vps-operation-queued
                {elseif $managementStatus == 'running'}dh-vps-operation-running
                {elseif $managementStatus == 'succeeded'}dh-vps-operation-succeeded
                {elseif $managementStatus == 'failed'}dh-vps-operation-failed
                {/if}">

                <p class="dh-vps-operation-status-title">
                    وضعیت آخرین عملیات
                </p>

                <p class="dh-vps-operation-status-text">
                    {if $managementStatus == 'queued'}
                        درخواست ثبت شده و در صف اجرا قرار دارد.
                    {elseif $managementStatus == 'running'}
                        عملیات در حال انجام است...
                    {elseif $managementStatus == 'succeeded'}
                        عملیات با موفقیت انجام شد.
                    {elseif $managementStatus == 'failed'}
                        عملیات ناموفق بود.
                        {if $managementError}
                            {$managementError}
                        {/if}
                    {else}
                        وضعیت عملیات:
                        {$managementStatus|default:'نامشخص'}
                    {/if}
                </p>

                <div class="dh-vps-operation-status-id">
                    Operation ID: {$managementOperationId}
                </div>
            </div>
        {/if}
    </div>

    <div class="dh-vps-card dh-vps-password-card">
        <h3 class="dh-vps-card-title">تغییر رمز عبور VPS</h3>

        <p class="dh-vps-password-description">
            برای تغییر رمز عبور کاربر VPS، رمز جدید را دو بار وارد کنید.
        </p>

        <form method="post"
              action="clientarea.php?action=productdetails"
              autocomplete="off"
              class="dh-vps-password-form">

            <input type="hidden" name="id" value="{$serviceId}">
            <input type="hidden" name="modop" value="custom">
            <input type="hidden" name="a" value="ChangePassword">

            <div class="dh-vps-password-fields">

                <div class="dh-vps-field">
                    <label for="datahoteling_new_password">
                        رمز عبور جدید
                    </label>

                    <input
                        type="password"
                        id="datahoteling_new_password"
                        name="datahoteling_new_password"
                        minlength="8"
                        maxlength="128"
                        autocomplete="new-password"
                        required
                    >

                    <small>حداقل ۸ کاراکتر</small>
                </div>

                <div class="dh-vps-field">
                    <label for="datahoteling_confirm_password">
                        تکرار رمز عبور جدید
                    </label>

                    <input
                        type="password"
                        id="datahoteling_confirm_password"
                        name="datahoteling_confirm_password"
                        minlength="8"
                        maxlength="128"
                        autocomplete="new-password"
                        required
                    >
                </div>

            </div>

            <button
                type="submit"
                class="dh-vps-action dh-vps-action-password"
                onclick="return confirm('آیا از تغییر رمز عبور VPS مطمئن هستید؟');"
            >
                تغییر رمز عبور
            </button>
        </form>
    </div>

    <div class="dh-vps-card dh-vps-reinstall-card">
        <h3 class="dh-vps-card-title">نصب مجدد VPS</h3>

        <p class="dh-vps-reinstall-warning">
            توجه: نصب مجدد VPS سیستم‌عامل فعلی را حذف کرده و VPS را
            از Golden Image مجدداً ایجاد می‌کند. اطلاعات و فایل‌های فعلی
            روی VPS قابل حفظ نخواهند بود.
        </p>

        <form method="post"
              action="clientarea.php?action=productdetails"
              autocomplete="off"
              class="dh-vps-reinstall-form">

            <input type="hidden" name="id" value="{$serviceId}">
            <input type="hidden" name="modop" value="custom">
            <input type="hidden" name="a" value="ReinstallVPS">

            <div class="dh-vps-password-fields">

                <div class="dh-vps-field">
                    <label for="datahoteling_reinstall_password">
                        رمز عبور جدید VPS
                    </label>

                    <input
                        type="password"
                        id="datahoteling_reinstall_password"
                        name="datahoteling_reinstall_password"
                        minlength="8"
                        maxlength="128"
                        autocomplete="new-password"
                        required
                    >

                    <small>حداقل ۸ کاراکتر</small>
                </div>

                <div class="dh-vps-field">
                    <label for="datahoteling_reinstall_confirm_password">
                        تکرار رمز عبور جدید
                    </label>

                    <input
                        type="password"
                        id="datahoteling_reinstall_confirm_password"
                        name="datahoteling_reinstall_confirm_password"
                        minlength="8"
                        maxlength="128"
                        autocomplete="new-password"
                        required
                    >
                </div>

            </div>

            <button
                type="submit"
                class="dh-vps-action dh-vps-action-reinstall"
                onclick="return confirm('هشدار: با نصب مجدد، اطلاعات فعلی VPS حذف می‌شود. آیا از نصب مجدد VPS مطمئن هستید؟');"
            >
                نصب مجدد VPS
            </button>
        </form>
    </div>

    <div class="dh-vps-grid">

        <div class="dh-vps-card">
            <h3 class="dh-vps-card-title">اطلاعات VPS</h3>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">آدرس IP اصلی</span>
                <span class="dh-vps-value">{$dedicatedIp}</span>
            </div>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">نام کاربری</span>
                <span class="dh-vps-value">{$username}</span>
            </div>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">Hostname</span>
                <span class="dh-vps-value">{$hostname}</span>
            </div>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">شناسه سرویس</span>
                <span class="dh-vps-value">#{$serviceId}</span>
            </div>
        </div>

        <div class="dh-vps-card">
            <h3 class="dh-vps-card-title">منابع اختصاص‌یافته</h3>

            <div class="dh-vps-resource">
                <span class="dh-vps-resource-name">پردازنده</span>
                <span class="dh-vps-resource-value">
                    {$cpu} Core
                </span>
            </div>

            <div class="dh-vps-resource">
                <span class="dh-vps-resource-name">حافظه RAM</span>
                <span class="dh-vps-resource-value">
                    {$ramGb} GB
                </span>
            </div>

            <div class="dh-vps-resource">
                <span class="dh-vps-resource-name">فضای دیسک</span>
                <span class="dh-vps-resource-value">
                    {$disk} GB
                </span>
            </div>
        </div>

        <div class="dh-vps-card">
            <h3 class="dh-vps-card-title">وضعیت سرویس</h3>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">وضعیت WHMCS</span>
                <span class="dh-vps-value">{$status}</span>
            </div>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">وضعیت مانیتورینگ</span>
                <span class="dh-vps-value">
                    در حال راه‌اندازی
                </span>
            </div>

            <div class="dh-vps-info-row">
                <span class="dh-vps-label">Package</span>
                <span class="dh-vps-value">{$package}</span>
            </div>
        </div>

    </div>

    <div class="dh-vps-monitoring">
        <h3 class="dh-vps-monitoring-title">
            مصرف لحظه‌ای منابع
        </h3>

        <p class="dh-vps-monitoring-text">
            اطلاعات مصرف CPU، RAM، Disk، Network و Uptime پس از
            اتصال سیستم مانیتورینگ VPS به‌صورت لحظه‌ای نمایش داده خواهد شد.
            در حال حاضر هیچ مقدار ساختگی نمایش داده نمی‌شود.
        </p>
    </div>

</div>
