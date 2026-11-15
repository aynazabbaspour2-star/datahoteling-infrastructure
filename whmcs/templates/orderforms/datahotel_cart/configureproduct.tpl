{include file="orderforms/standard_cart/common.tpl"}

{* ==========================================================================
   VPS BUILDER — پیکربندی سرور مجازی با ۵ اسلایدر زنده منطبق با جدول قیمت
   مسیر: templates/orderforms/datahotel_cart/configureproduct.tpl
   ========================================================================== *}
{assign var="dpvPids" value=[9]}
{if in_array($productinfo.pid, $dpvPids) || $productinfo.type == 'server' || $productinfo.name|lower|strpos:'vps' !== false}

{* ---- جدول دقیق ۵ آیتم منابع سرور مجازی، ضرایب، قیمت واحد و مقادیر پیش‌فرض ---- *}
{assign var="dpvSpecList" value=[
    ["key" => "cpu",  "title" => "پردازنده (CPU)",      "icon" => "fas fa-microchip", "unit" => "هسته",     "block" => 1,   "price" => 25000000, "min" => 1, "max" => 32,  "def" => 6,  "storage" => 0, "hint" => "هر هسته پردازشی اختصاصی: ۲۵٬۰۰۰٬۰۰۰"],
    ["key" => "ram",  "title" => "حافظه رم (RAM)",      "icon" => "fas fa-memory",    "unit" => "گیگابایت", "block" => 1,   "price" => 4000000,  "min" => 1, "max" => 128, "def" => 16, "storage" => 0, "hint" => "هر گیگابایت رم DDR4/DDR5: ۴٬۰۰۰٬۰۰۰"],
    ["key" => "nvme", "title" => "فضای دیسک NVMe",      "icon" => "fas fa-bolt",      "unit" => "گیگابایت", "block" => 50,  "price" => 20000000, "min" => 0, "max" => 40,  "def" => 4,  "storage" => 1, "hint" => "هر واحد ۵۰ گیگابایتی NVMe پرسرعت: ۲۰٬۰۰۰٬۰۰۰"],
    ["key" => "ssd",  "title" => "فضای دیسک SSD",       "icon" => "fas fa-hdd",       "unit" => "گیگابایت", "block" => 50,  "price" => 10000000, "min" => 0, "max" => 40,  "def" => 1,  "storage" => 1, "hint" => "هر واحد ۵۰ گیگابایتی SSD سازمانی: ۱۰٬۰۰۰٬۰۰۰"],
    ["key" => "sas",  "title" => "فضای دیسک HDD / SAS", "icon" => "fas fa-database",  "unit" => "گیگابایت", "block" => 100, "price" => 5000000,  "min" => 0, "max" => 40,  "def" => 2,  "storage" => 1, "hint" => "هر واحد ۱۰۰ گیگابایتی SAS/HDD: ۵٬۰۰۰٬۰۰۰"]
]}

{assign var="dpvCur" value=$currency.suffix|default:''|trim}
{if !$dpvCur}{assign var="dpvCur" value="تومان
"}{assign var="dpvHeroImg" value="/templates/{$template}/img/hero-slabs.webp"}
{/if}

{* ---- تطبیق خودکار Configurable Options تعریف‌شده در WHMCS با ۵ اسلایدر بالا ---- *}
{assign var="coMap" value=[]}
{assign var="extraOptions" value=[]}
{foreach $configurableoptions as $co}
    {assign var="lname" value=$co.optionname|lower}
    {if $lname|strpos:'cpu' !== false || $lname|strpos:'core' !== false || $lname|strpos:'پردازنده' !== false}
        {append var="coMap" index="cpu" value=$co}
    {elseif $lname|strpos:'ram' !== false || $lname|strpos:'memory' !== false || $lname|strpos:'رم' !== false}
        {append var="coMap" index="ram" value=$co}
    {elseif $lname|strpos:'nvme' !== false}
        {append var="coMap" index="nvme" value=$co}
    {elseif $lname|strpos:'ssd' !== false || $lname|strpos:'storage' !== false}
        {append var="coMap" index="ssd" value=$co}
    {elseif $lname|strpos:'sas' !== false || $lname|strpos:'hdd' !== false || $lname|strpos:'hrd' !== false}
        {append var="coMap" index="sas" value=$co}
    {else}
        {append var="extraOptions" value=$co}
    {/if}
{/foreach}

<script>document.body.classList.add("dpo-body","dpv-body");</script>

<div id="order-standard_cart" class="dpo-page dpv-page" dir="rtl">

{* ================= 1. HERO (چسبیده به هدر با ماژول زنده سخت‌افزار در سمت چپ) ================= *}
    <section class="dpo-hero dpv-hero" style="--dpv-hero-img: url('{$dpvHeroImg}')">
        <div class="dpo-hero__grain" aria-hidden="true"></div>
        <div class="dpv-hero__grid">
            <div class="dpo-hero__content">
                <p class="dpo-eyebrow"><i class="fas fa-server" aria-hidden="true"></i> {$productinfo.name|default:'سرور مجازی ابری'}</p>
                <h1 class="dpo-hero__title">سرور مجازی اختصاصی،<br>دقیقاً به اندازه‌ی نیاز شما</h1>
                <p class="dpo-hero__text">منابع پردازشی و حافظه را با اسلایدر تنظیم کنید؛ قیمت پکیج در لحظه محاسبه شده و آماده اتصال به درگاه پرداخت است.</p>
                <ul class="dpv-hero__pills">
                    <li><i class="fas fa-bolt" aria-hidden="true"></i> تحویل آنی زیر ۶۰ ثانیه</li>
                    <li><i class="fas fa-Microchip" aria-hidden="true"></i> منابع ۱۰۰٪ اختصاصی</li>
                    <li><i class="fas fa-terminal" aria-hidden="true"></i> دسترسی کامل Root</li>
                </ul>
            </div>

            {* قاب بصری سمت چپ هیرو (نمایش زنده پیکربندی انتخابی) *}
            <div class="dpv-hero__visual" aria-hidden="true">
                <div class="dpv-hero__vhead">
                    <span class="dpv-hero__vstatus"><i></i>شاسی سرور ابری نسل جدید</span>
                    <span>SLA 99.99%</span>
                </div>
                <div class="dpv-hero__vspecs">
                    <div class="dpv-hero__vbox">
                        <small>پردازنده</small>
                        <strong data-dpv-hero-cpu>۶ هسته</strong>
                    </div>
                    <div class="dpv-hero__vbox">
                        <small>حافظه رم</small>
                        <strong data-dpv-hero-ram>۱۶ گیگ</strong>
                    </div>
                    <div class="dpv-hero__vbox">
                        <small>مجموع دیسک</small>
                        <strong data-dpv-hero-disk>۴۵۰ گیگ</strong>
                    </div>
                </div>
                <div class="dpv-hero__vbar">
                    <span>پورت شبکه: ۱۰Gbps</span>
                    <div class="dpv-hero__ticks">
                        <i class="is-on"></i><i class="is-on"></i><i class="is-on"></i><i class="is-on"></i>
                        <i class="is-on"></i><i class="is-on"></i><i></i><i></i><i></i><i></i>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* ================= 2. BUILDER WORKSPACE ================= *}
    <section class="dpv-sec">
        <div class="dpo-in">

            {if $errormessage}
                <div class="alert alert-danger dpo-alert">{$errormessage}</div>
            {/if}
            <div class="alert alert-danger dpo-alert w-hidden" role="alert" id="containerProductValidationErrors">
                <p>{$LANG.orderForm.correctErrors}:</p>
                <ul id="containerProductValidationErrorsList"></ul>
            </div>

            {if $adminLoggedIn}
                {assign var="dpvBad" value=false}
                {if $pricing.type != 'recurring'}{assign var="dpvBad" value=true}{/if}
                {foreach $dpvSpecList as $spec}
                    {assign var="dk0" value=$spec.key}
                    {assign var="dco0" value=$coMap[$dk0]|default:null}
                    {if !$dco0 || $dco0.optiontype != 4}{assign var="dpvBad" value=true}{/if}
                {/foreach}
                <details class="dpv-diag" dir="rtl"{if $dpvBad} open{/if}>
                    <summary>پنل عیب‌یابی (فقط مدیر می‌بیند){if $dpvBad} — مشکل پیدا شد{else} — همه‌چیز درست است ✓{/if}</summary>
                    <ul>
                        <li{if $pricing.type != 'recurring'} class="is-bad"{/if}>
                            نوع پرداخت محصول: <b>{$pricing.type}</b>
                            {if $pricing.type != 'recurring'} — باید «Recurring» باشد (روی Free قیمت گزینه‌ها محاسبه نمی‌شود){/if}
                        </li>
                        {foreach $dpvSpecList as $spec}
                            {assign var="dk" value=$spec.key}
                            {assign var="dco" value=$coMap[$dk]|default:null}
                            <li{if !$dco || $dco.optiontype != 4} class="is-bad"{/if}>
                                {$spec.title}:
                                {if $dco}
                                    گزینه «{$dco.optionname}» (#{$dco.id}) — نوع {if $dco.optiontype == 4}Quantity ✓{elseif $dco.optiontype == 1}Dropdown ✗ (باید Quantity باشد){else}{$dco.optiontype} ✗{/if}
                                {else}
                                    در WHMCS گزینه‌ای با این نام پیدا نشد ✗
                                {/if}
                            </li>
                        {/foreach}
                    </ul>
                </details>
            {/if}

            <form id="frmConfigureProduct" class="dpv-grid" data-dpv>
                <input type="hidden" name="configure" value="true" />
                <input type="hidden" name="i" value="{$i}" />

                {* ---------- ستون راست: ۵ اسلایدر منابع + مشخصات سرور ---------- *}
                <div class="dpv-main">

                    <div class="dpv-block-head">
                        <h2>۱. منابع سخت‌افزاری سرور را تنظیم کنید</h2>
                        <button type="button" class="dpv-reset" data-dpv-reset>
                            <i class="fas fa-undo-alt" aria-hidden="true"></i> بازگشت به پکیج پیشنهادی
                        </button>
                    </div>

                    {* رندر تضمینی هر ۵ کارت اسلایدر مطابق جدول *}
                    {foreach $dpvSpecList as $spec}
                        {assign var="k" value=$spec.key}
                        {assign var="matchedCo" value=$coMap[$k]|default:null}
                        {assign var="mn" value=$spec.min}
                        {assign var="mx" value=$spec.max}
                        {assign var="cur" value=$spec.def}

                        {if $matchedCo && $matchedCo.optiontype == 4}
                            {if $matchedCo.qtyminimum > 0}{assign var="mn" value=$matchedCo.qtyminimum}{/if}
                            {if $matchedCo.qtymaximum > 0}{assign var="mx" value=$matchedCo.qtymaximum}{/if}
                            {if $matchedCo.selectedqty !== '' && $matchedCo.selectedqty !== null && $matchedCo.selectedqty > 0}
                                {assign var="cur" value=$matchedCo.selectedqty}
                            {/if}
                        {/if}

                        <div class="dpv-card"
                             data-dpv-item
                             data-key="{$spec.key}"
                             data-title="{$spec.title|escape}"
                             data-price="{$spec.price}"
                             data-block="{$spec.block}"
                             data-unit="{$spec.unit|escape}"
                             data-def="{$spec.def}"
                             data-storage="{$spec.storage}">

                            <div class="dpv-card__top">
                                <span class="dpv-card__icon"><i class="{$spec.icon}" aria-hidden="true"></i></span>
                                <div class="dpv-card__id">
                                    <div class="dpv-card__title-row">
                                        <label class="dpv-card__title" for="dpvRange_{$spec.key}">{$spec.title}</label>
                                        <span class="dpv-card__pkg-price" data-dpv-card-sum></span>
                                    </div>
                                    <small>{$spec.hint} {$dpvCur}</small>
                                </div>
                                <div class="dpv-card__val">
                                    <button type="button" class="dpv-step" data-dpv-dec aria-label="کاهش">−</button>
                                    <output class="dpv-card__amount" data-dpv-out for="dpvRange_{$spec.key}">
                                        <b>{$cur * $spec.block}</b> <span>{$spec.unit}</span>
                                    </output>
                                    <button type="button" class="dpv-step" data-dpv-inc aria-label="افزایش">+</button>
                                </div>
                            </div>

                            {* اسلایدر اصلی *}
                            <input class="dpv-range"
                                   type="range"
                                   id="dpvRange_{$spec.key}"
                                   {if $matchedCo && $matchedCo.optiontype == 4}
                                       name="configoption[{$matchedCo.id}]"
                                   {else}
                                       name="custom_vps_{$spec.key}"
                                   {/if}
                                   min="{$mn}"
                                   max="{$mx}"
                                   step="1"
                                   value="{$cur}"
                                   data-dpv-range>

                            {* اگر در WHMCS گزینه از نوع Dropdown بود، یک select مخفی برای سازگاری با فرم WHMCS نگه می‌داریم *}
                            {if $matchedCo && $matchedCo.optiontype == 1}
                                <select name="configoption[{$matchedCo.id}]" class="dpv-sr" data-dpv-sync-select tabindex="-1" aria-hidden="true">
                                    {foreach $matchedCo.options as $opt}
                                        <option value="{$opt.id}" data-opt-name="{$opt.name|escape}"{if $matchedCo.selectedvalue == $opt.id} selected{/if}>{$opt.name}</option>
                                    {/foreach}
                                </select>
                            {/if}

                            <div class="dpv-card__scale" aria-hidden="true">
                                <span data-dpv-min></span>
                                <span class="dpv-card__sub" data-dpv-sub></span>
                                <span data-dpv-max></span>
                            </div>
                        </div>
                    {/foreach}

                    {* سایر گزینه‌های جانبی در صورت وجود (مثل سیستم‌عامل یا کنترل‌پنل) *}
                    {if $extraOptions}
                        <div class="dpv-block-head dpv-block-head--sub"><h2>سایر تنظیمات نرم‌افزاری</h2></div>
                        <div class="dpv-fields">
                            {foreach $extraOptions as $co}
                                {if $co.optiontype == 1}
                                    <div class="dpv-field">
                                        <label for="dpvOpt{$co.id}">{$co.optionname}</label>
                                        <select class="dpv-input" id="dpvOpt{$co.id}" name="configoption[{$co.id}]" data-dpv-extra>
                                            {foreach $co.options as $opt}
                                                <option value="{$opt.id}"{if $co.selectedvalue == $opt.id} selected{/if}>{$opt.name}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                {elseif $co.optiontype == 2}
                                    <fieldset class="dpv-field">
                                        <legend>{$co.optionname}</legend>
                                        <div class="dpv-choices">
                                            {foreach $co.options as $opt}
                                                <label class="dpv-choice">
                                                    <input type="radio" name="configoption[{$co.id}]" value="{$opt.id}"{if $co.selectedvalue == $opt.id} checked{/if} data-dpv-extra>
                                                    <span>{$opt.name}</span>
                                                </label>
                                            {/foreach}
                                        </div>
                                    </fieldset>
                                {elseif $co.optiontype == 3}
                                    <div class="dpv-field">
                                        <label class="dpv-choice dpv-choice--row">
                                            <input type="checkbox" name="configoption[{$co.id}]" value="1"{if $co.selectedqty} checked{/if} data-dpv-extra>
                                            <span>{$co.options.0.name}</span>
                                        </label>
                                    </div>
                                {/if}
                            {/foreach}
                        </div>
                    {/if}

                    {if $productinfo.type == 'server'}
                        <div class="dpv-block-head dpv-block-head--sub"><h2>۲. مشخصات دسترسی سرور</h2></div>
                        <div class="dpv-fields">
                            <div class="dpv-field">
                                <label for="inputHostname">نام میزبان (Hostname)</label>
                                <input class="dpv-input" dir="ltr" type="text" name="hostname" id="inputHostname" value="{$server.hostname|default:''}" placeholder="server.yourdomain.com">
                            </div>
                            <div class="dpv-field">
                                <label for="inputRootpw">رمز عبور Root</label>
                                <input class="dpv-input" dir="ltr" type="password" name="rootpw" id="inputRootpw" value="{$server.rootpw|default:''}" placeholder="••••••••••" autocomplete="new-password">
                            </div>
                            <div class="dpv-field">
                                <label for="inputNs1prefix">پیشوند NS1</label>
                                <input class="dpv-input" dir="ltr" type="text" name="ns1prefix" id="inputNs1prefix" value="{$server.ns1prefix|default:'ns1'}" placeholder="ns1">
                            </div>
                            <div class="dpv-field">
                                <label for="inputNs2prefix">پیشوند NS2</label>
                                <input class="dpv-input" dir="ltr" type="text" name="ns2prefix" id="inputNs2prefix" value="{$server.ns2prefix|default:'ns2'}" placeholder="ns2">
                            </div>
                        </div>
                    {/if}

                    {if $customfields}
                        <div class="dpv-fields dpv-fields--custom">
                            {foreach $customfields as $cf}
                                <div class="dpv-field">
                                    <label for="customfield{$cf.id}">{$cf.name}{if $cf.required == '*'} <b class="dpv-req">*</b>{/if}</label>
                                    <div class="dpv-cf">{$cf.input}</div>
                                    {if $cf.description}<small>{$cf.description}</small>{/if}
                                </div>
                            {/foreach}
                        </div>
                    {/if}

                    {if $addons}
                        <div class="dpv-block-head dpv-block-head--sub"><h2>افزونه‌های جانبی</h2></div>
                        <div class="dpv-choices dpv-choices--stack">
                            {foreach $addons as $addon}
                                <label class="dpv-choice dpv-choice--row">
                                    <input type="checkbox" name="addons[{$addon.id}]" id="addon{$addon.id}"{if $addon.status} checked{/if} data-dpv-extra>
                                    <span><b>{$addon.name}</b>{if $addon.pricing} · {$addon.pricing}{/if}{if $addon.description}<small>{$addon.description}</small>{/if}</span>
                                </label>
                            {/foreach}
                        </div>
                    {/if}
                </div>

                {* ---------- ستون چپ: خلاصه‌ی زنده پکیج و پرداخت ---------- *}
                <aside class="dpv-sum" id="dpvSum" aria-live="polite">
                    <div class="dpv-sum__panel">
                        <div class="dpv-sum__head">
                            <p class="dpv-sum__kicker">خلاصه‌ی پکیج اختصاصی شما</p>
                            <span class="dpv-sum__live"><i></i>محاسبه آنی</span>
                        </div>

                        <div class="dpv-sum__bars" aria-hidden="true" data-dpv-bars></div>

                        <ul class="dpv-sum__lines" data-dpv-lines></ul>

                        {if $pricing.type == 'recurring'}
                            <div class="dpv-sum__cycle">
                                <label for="inputBillingcycle">دوره‌ی پرداخت</label>
                                <select class="dpv-input dpv-input--dark" name="billingcycle" id="inputBillingcycle" data-dpv-cycle>
                                    {if $pricing.monthly}<option value="monthly"{if $billingcycle == 'monthly'} selected{/if}>ماهانه</option>{/if}
                                    {if $pricing.quarterly}<option value="quarterly"{if $billingcycle == 'quarterly'} selected{/if}>سه‌ماهه</option>{/if}
                                    {if $pricing.semiannually}<option value="semiannually"{if $billingcycle == 'semiannually'} selected{/if}>شش‌ماهه</option>{/if}
                                    {if $pricing.annually}<option value="annually"{if $billingcycle == 'annually'} selected{/if}>سالانه</option>{/if}
                                    {if $pricing.biennially}<option value="biennially"{if $billingcycle == 'biennially'} selected{/if}>دوساله</option>{/if}
                                    {if $pricing.triennially}<option value="triennially"{if $billingcycle == 'triennially'} selected{/if}>سه‌ساله</option>{/if}
                                </select>
                            </div>
                        {/if}

                        <div class="dpv-sum__total">
                            <span>مبلغ کل پکیج</span>
                            <strong data-dpv-total>۳۱٬۴۰۰٬۰۰۰</strong>
                            <small data-dpv-cur data-cur="{$dpvCur|escape}">{$dpvCur} <em data-dpv-per>در ماه</em></small>
                        </div>

                        <div id="orderSummary" class="dpv-sr" aria-hidden="true">
                            <div class="order-summary">
                                <div class="loader" id="orderSummaryLoader"></div>
                                <div class="summary-container" id="producttotal"></div>
                            </div>
                        </div>

                        <p class="dpv-sum__warn" data-dpv-priceerr hidden>قیمت‌گذاری این سرویس هنوز در سیستم تکمیل نشده است؛ لطفاً با پشتیبانی تماس بگیرید.</p>

                        <p class="dpv-sum__warn" data-dpv-warn hidden>حداقل یکی از دیسک‌ها (NVMe، SSD یا HDD/SAS) باید بیشتر از صفر باشد.</p>

                        <button type="submit" class="dp-btn dp-btn--primary dpv-sum__cta" id="btnCompleteProductConfig" data-dpv-submit>
                            ادامه و اتصال به درگاه پرداخت <i class="fas fa-arrow-left" aria-hidden="true"></i>
                        </button>
                        <p class="dpv-sum__note"><i class="fas fa-lock" aria-hidden="true"></i> پرداخت امن · تحویل خودکار پس از تایید پرداخت</p>
                    </div>
                </aside>
            </form>
        </div>
    </section>

    <div class="dpv-mbar" data-dpv-mbar>
        <div><small>مبلغ قابل پرداخت</small><strong data-dpv-total2>۳۱٬۴۰۰٬۰۰۰</strong> <small data-dpv-per2></small></div>
        <a href="#dpvSum" class="dp-btn dp-btn--primary">مشاهده و پرداخت</a>
    </div>
</div>

{literal}
<script>
(function () {
    'use strict';
    var form = document.querySelector('[data-dpv]');
    if (!form) { return; }

    var items   = [].slice.call(form.querySelectorAll('[data-dpv-item]'));
    var linesEl = form.querySelector('[data-dpv-lines]');
    var barsEl  = form.querySelector('[data-dpv-bars]');
    var totalEl = form.querySelector('[data-dpv-total]');
    var perEl   = form.querySelector('[data-dpv-per]');
    var cycleEl = form.querySelector('[data-dpv-cycle]');
    var warnEl  = form.querySelector('[data-dpv-warn]');
    var submit  = form.querySelector('[data-dpv-submit]');
    var total2  = document.querySelector('[data-dpv-total2]');
    var per2    = document.querySelector('[data-dpv-per2]');
    var mbar    = document.querySelector('[data-dpv-mbar]');
    var curEl   = form.querySelector('[data-dpv-cur]');
    var cur     = curEl ? (curEl.getAttribute('data-cur') || 'تومان') : 'تومان';
    var fa      = new Intl.NumberFormat('fa-IR');
    var serverTimer = null;
    var serverVal = null;      /* مبلغ نهایی محاسبه‌شده توسط خود WHMCS */
    var localTotal = 0;
    var priceErrEl = form.querySelector('[data-dpv-priceerr]');

    var CYCLE_LABEL = {
        monthly: 'در ماه',
        quarterly: 'هر ۳ ماه',
        semiannually: 'هر ۶ ماه',
        annually: 'در سال',
        biennially: 'هر ۲ سال',
        triennially: 'هر ۳ سال'
    };
    var CYCLE_MULT = {
        monthly: 1,
        quarterly: 3,
        semiannually: 6,
        annually: 12,
        biennially: 24,
        triennially: 36
    };

    function n(v) { return fa.format(Math.round(v)); }

    function model() {
        return items.map(function (el) {
            var r = el.querySelector('[data-dpv-range]');
            var q = parseInt(r.value, 10) || 0;
            var block = parseFloat(el.getAttribute('data-block')) || 1;
            var price = parseFloat(el.getAttribute('data-price')) || 0;
            return {
                el: el,
                r: r,
                qty: q,
                amount: q * block,
                price: price,
                sum: q * price,
                unit: el.getAttribute('data-unit') || '',
                title: el.getAttribute('data-title') || '',
                storage: el.getAttribute('data-storage') === '1',
                block: block
            };
        });
    }

    function syncHiddenDropdown(m) {
        var sel = m.el.querySelector('[data-dpv-sync-select]');
        if (!sel || !sel.options.length) { return; }
        var targetNum = m.amount;
        var bestIdx = 0;
        var bestDiff = Infinity;
        for (var i = 0; i < sel.options.length; i++) {
            var txt = sel.options[i].getAttribute('data-opt-name') || sel.options[i].text || '';
            var match = txt.match(/\d+/);
            if (match) {
                var num = parseInt(match[0], 10);
                var diff = Math.abs(num - targetNum);
                if (diff < bestDiff) {
                    bestDiff = diff;
                    bestIdx = i;
                }
            }
        }
        sel.selectedIndex = bestIdx;
    }

    function paintCard(m) {
        var min = +m.r.min, max = +m.r.max;
        var p = max > min ? ((m.qty - min) / (max - min)) * 100 : 0;
        m.r.style.setProperty('--p', p + '%');
        m.el.querySelector('[data-dpv-out]').innerHTML = '<b>' + n(m.amount) + '</b> <span>' + m.unit + '</span>';
        m.el.querySelector('[data-dpv-min]').textContent = 'حداقل: ' + n(min * m.block) + ' ' + m.unit;
        m.el.querySelector('[data-dpv-max]').textContent = 'حداکثر: ' + n(max * m.block) + ' ' + m.unit;

        var sub = m.el.querySelector('[data-dpv-sub]');
        if (sub) {
            sub.textContent = m.block > 1 ? (n(m.qty) + ' واحد × ' + n(m.block) + ' ' + m.unit) : (n(m.qty) + ' ' + m.unit);
        }

        var cardSum = m.el.querySelector('[data-dpv-card-sum]');
        if (cardSum) {
            cardSum.textContent = m.sum > 0 ? (n(m.sum) + ' ' + cur) : 'غیرفعال (۰)';
            cardSum.classList.toggle('is-zero', m.sum === 0);
        }

        syncHiddenDropdown(m);
    }

    function render() {
        var ms = model(), monthlyTotal = 0, storage = 0;
        linesEl.innerHTML = '';
        barsEl.innerHTML = '';

        ms.forEach(function (m) {
            paintCard(m);
            monthlyTotal += m.sum;
            if (m.storage) { storage += m.qty; }

            var li = document.createElement('li');
            if (m.qty === 0) { li.className = 'is-muted'; }
            li.innerHTML =
                '<span>' + m.title + ' <em>(' + n(m.amount) + ' ' + m.unit + ')</em></span>' +
                '<b>' + n(m.sum) + ' <small>' + cur + '</small></b>';
            linesEl.appendChild(li);

            var bar = document.createElement('i');
            var ratio = (+m.r.value - +m.r.min) / Math.max(1, (+m.r.max - +m.r.min));
            bar.style.height = Math.round(6 + ratio * 30) + 'px';
            barsEl.appendChild(bar);
        });
var hCpu = document.querySelector('[data-dpv-hero-cpu]');
        var hRam = document.querySelector('[data-dpv-hero-ram]');
        var hDisk = document.querySelector('[data-dpv-hero-disk]');
        var totalDiskGb = 0;
        ms.forEach(function (m) {
            if (m.el.getAttribute('data-key') === 'cpu' && hCpu) { hCpu.textContent = n(m.amount) + ' هسته'; }
            if (m.el.getAttribute('data-key') === 'ram' && hRam) { hRam.textContent = n(m.amount) + ' گیگ'; }
            if (m.storage) { totalDiskGb += m.amount; }
        });
        if (hDisk) { hDisk.textContent = n(totalDiskGb) + ' گیگ'; }
        var cyc = cycleEl ? cycleEl.value : 'monthly';
        var mult = CYCLE_MULT[cyc] || 1;
        var finalTotal = monthlyTotal * mult;

        localTotal = monthlyTotal;
        var shown = serverVal !== null ? serverVal : finalTotal;

        perEl.textContent = CYCLE_LABEL[cyc] || 'در ماه';
        totalEl.textContent = n(shown);

        if (total2) {
            total2.textContent = n(shown);
            per2.textContent = cur + ' ' + (CYCLE_LABEL[cyc] || 'در ماه');
        }

        var hasStorage = storage > 0;
        /* اگر WHMCS برای این پیکربندی مبلغ صفر حساب کند (قیمت گزینه‌ها تنظیم نشده)، ثبت سفارش مسدود می‌شود */
        var priceBroken = serverVal !== null && serverVal <= 0 && localTotal > 0;
        warnEl.hidden = hasStorage;
        if (priceErrEl) { priceErrEl.hidden = !priceBroken; }
        submit.disabled = !hasStorage || priceBroken;
    }

    /* تبدیل «۳۱٬۴۰۰٬۰۰۰٫۰۰ ریال» یا «31,400,000.00 IRR» به عدد */
    function parseAmount(s) {
        s = String(s || '')
            .replace(/[۰-۹]/g, function (d) { return '۰۱۲۳۴۵۶۷۸۹'.indexOf(d); })
            .replace(/[٠-٩]/g, function (d) { return '٠١٢٣٤٥٦٧٨٩'.indexOf(d); })
            .replace(/[٬,\s]/g, '').replace(/٫/g, '.');
        var m = s.match(/\d+(?:\.\d+)?/);
        return m ? parseFloat(m[0]) : null;
    }
    function readServerTotal() {
        var box = document.getElementById('producttotal');
        var amt = box && (box.querySelector('.total-due-today .amt') || box.querySelector('#totalDueToday'));
        var v = amt ? parseAmount(amt.textContent) : null;
        if (v !== null) { serverVal = v; render(); }
    }
    var sumBox = document.getElementById('producttotal');
    if (sumBox && 'MutationObserver' in window) {
        new MutationObserver(readServerTotal).observe(sumBox, { childList: true, subtree: true });
    }

    function syncServer() {
        clearTimeout(serverTimer);
        serverTimer = setTimeout(function () {
            if (typeof window.recalctotals === 'function') { window.recalctotals(); }
        }, 300);
    }

    function change() {
        serverVal = null;
        render();
        syncServer();
    }

    form.addEventListener('input', function (e) {
        if (e.target.matches('[data-dpv-range]')) { change(); }
    });
    form.addEventListener('change', function (e) {
        if (e.target.matches('[data-dpv-cycle],[data-dpv-extra]')) { change(); }
    });
    form.addEventListener('click', function (e) {
        var b = e.target.closest('[data-dpv-inc],[data-dpv-dec]');
        if (b) {
            var r = b.closest('[data-dpv-item]').querySelector('[data-dpv-range]');
            var nextVal = (+r.value) + (b.hasAttribute('data-dpv-inc') ? 1 : -1);
            r.value = Math.min(+r.max, Math.max(+r.min, nextVal));
            change();
            return;
        }
        if (e.target.closest('[data-dpv-reset]')) {
            items.forEach(function (el) {
                var r = el.querySelector('[data-dpv-range]');
                var d = parseInt(el.getAttribute('data-def'), 10);
                if (!isNaN(d)) { r.value = Math.min(+r.max, Math.max(+r.min, d)); }
            });
            change();
        }
    });
    form.addEventListener('submit', function (e) {
        if (submit.disabled) { e.preventDefault(); }
    });

    var sum = document.getElementById('dpvSum');
    if (mbar && sum && 'IntersectionObserver' in window) {
        new IntersectionObserver(function (en) {
            mbar.classList.toggle('is-hidden', en[0].isIntersecting);
        }, { threshold: 0.15 }).observe(sum);
    }

    render();
    syncServer();
})();
</script>
{/literal}

<script>if (typeof recalctotals === 'function') { recalctotals(); }</script>
{include file="orderforms/standard_cart/recommendations-modal.tpl"}

{else}
{* ================= فرم استاندارد برای سایر محصولات غیر VPS ================= *}
<script>
var _localLang = {
    'addToCart': '{$LANG.orderForm.addToCart|escape}',
    'addedToCartRemove': '{$LANG.orderForm.addedToCartRemove|escape}'
}
</script>
<div id="order-standard_cart">
    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/standard_cart/sidebar-categories.tpl"}
        </div>
        <div class="cart-body">
            <div class="header-lined">
                <h1 class="font-size-36">{$LANG.orderconfigure}</h1>
            </div>
            {include file="orderforms/standard_cart/sidebar-categories-collapsed.tpl"}
            <form id="frmConfigureProduct">
                <input type="hidden" name="configure" value="true" />
                <input type="hidden" name="i" value="{$i}" />
                <div class="row">
                    <div class="secondary-cart-body">
                        <p>{$LANG.orderForm.configureDesiredOptions}</p>
                        <div class="product-info">
                            <p class="product-title">{$productinfo.name}</p>
                            <p>{$productinfo.description}</p>
                        </div>
                        <div class="alert alert-danger w-hidden" role="alert" id="containerProductValidationErrors">
                            <p>{$LANG.orderForm.correctErrors}:</p>
                            <ul id="containerProductValidationErrorsList"></ul>
                        </div>
                        {if $pricing.type eq "recurring"}
                            <div class="field-container">
                                <div class="form-group">
                                    <label for="inputBillingcycle">{$LANG.cartchoosecycle}</label><br>
                                    <select name="billingcycle" id="inputBillingcycle" class="form-control select-inline custom-select" onchange="updateConfigurableOptions({$i}, this.value); return false">
                                        {if $pricing.monthly}<option value="monthly"{if $billingcycle eq "monthly"} selected{/if}>{$pricing.monthly}</option>{/if}
                                        {if $pricing.quarterly}<option value="quarterly"{if $billingcycle eq "quarterly"} selected{/if}>{$pricing.quarterly}</option>{/if}
                                        {if $pricing.semiannually}<option value="semiannually"{if $billingcycle eq "semiannually"} selected{/if}>{$pricing.semiannually}</option>{/if}
                                        {if $pricing.annually}<option value="annually"{if $billingcycle eq "annually"} selected{/if}>{$pricing.annually}</option>{/if}
                                        {if $pricing.biennially}<option value="biennially"{if $billingcycle eq "biennially"} selected{/if}>{$pricing.biennially}</option>{/if}
                                        {if $pricing.triennially}<option value="triennially"{if $billingcycle eq "triennially"} selected{/if}>{$pricing.triennially}</option>{/if}
                                    </select>
                                </div>
                            </div>
                        {/if}
                        {if $productinfo.type eq "server"}
                            <div class="sub-heading"><span class="primary-bg-color">{$LANG.cartconfigserver}</span></div>
                            <div class="field-container">
                                <div class="row">
                                    <div class="col-sm-6"><div class="form-group"><label for="inputHostname">{$LANG.serverhostname}</label><input type="text" name="hostname" class="form-control" id="inputHostname" value="{$server.hostname}" placeholder="servername.example.com"></div></div>
                                    <div class="col-sm-6"><div class="form-group"><label for="inputRootpw">{$LANG.serverrootpw}</label><input type="password" name="rootpw" class="form-control" id="inputRootpw" value="{$server.rootpw}"></div></div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6"><div class="form-group"><label for="inputNs1prefix">{$LANG.serverns1prefix}</label><input type="text" name="ns1prefix" class="form-control" id="inputNs1prefix" value="{$server.ns1prefix}" placeholder="ns1"></div></div>
                                    <div class="col-sm-6"><div class="form-group"><label for="inputNs2prefix">{$LANG.serverns2prefix}</label><input type="text" name="ns2prefix" class="form-control" id="inputNs2prefix" value="{$server.ns2prefix}" placeholder="ns2"></div></div>
                                </div>
                            </div>
                        {/if}
                        {if $configurableoptions}
                            <div class="sub-heading"><span class="primary-bg-color">{$LANG.orderconfigpackage}</span></div>
                            <div class="product-configurable-options" id="productConfigurableOptions">
                                <div class="row">
                                    {foreach $configurableoptions as $num => $configoption}
                                        {if $configoption.optiontype eq 1}
                                            <div class="col-sm-6"><div class="form-group"><label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label><select name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" class="form-control">{foreach key=num2 item=options from=$configoption.options}<option value="{$options.id}"{if $configoption.selectedvalue eq $options.id} selected="selected"{/if}>{$options.name}</option>{/foreach}</select></div></div>
                                        {/if}
                                    {/foreach}
                                </div>
                            </div>
                        {/if}
                    </div>
                    <div class="secondary-cart-sidebar" id="scrollingPanelContainer">
                        <div id="orderSummary">
                            <div class="order-summary">
                                <div class="loader" id="orderSummaryLoader"><i class="fas fa-fw fa-sync fa-spin"></i></div>
                                <h2 class="font-size-30">{$LANG.ordersummary}</h2>
                                <div class="summary-container" id="producttotal"></div>
                            </div>
                            <div class="text-center">
                                <button type="submit" id="btnCompleteProductConfig" class="btn btn-primary btn-lg">{$LANG.continue} <i class="fas fa-arrow-circle-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<script>recalctotals();</script>
{include file="orderforms/standard_cart/recommendations-modal.tpl"}
{/if}