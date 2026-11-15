<script>document.body.classList.add("dax-body", "dax-body--register");</script>

{if in_array('state', $optionalFields)}
    <script>
        var statesTab = 10,
            stateNotRequired = true;
    </script>
{/if}

<script src="{$BASE_PATH_JS}/StatesDropdown.js"></script>
<script src="{$BASE_PATH_JS}/PasswordStrength.js"></script>
<script>
    window.langPasswordStrength = "{lang key='pwstrength'}";
    window.langPasswordWeak = "{lang key='pwstrengthweak'}";
    window.langPasswordModerate = "{lang key='pwstrengthmoderate'}";
    window.langPasswordStrong = "{lang key='pwstrengthstrong'}";
    jQuery(document).ready(function() {
        jQuery("#inputNewPassword1").keyup(registerFormPasswordStrengthFeedback);
    });
</script>

<div class="providerLinkingFeedback"></div>

<div class="dax-page dax-page--register">
    <!-- پس‌زمینه تمام‌صفحه همراه با خطوط معماری و مکعب‌های سه‌بعدی -->
    <div class="dax-wall" aria-hidden="true"></div>

    <!-- ۱. هدر بالایی (Minimal Top Chrome) -->
    <header class="dax-top">
        <a class="dax-logo" href="{$WEB_ROOT}/" aria-label="دیتاهتلینگ">
            دیتاهتلینگ<i aria-hidden="true"></i>
        </a>

        <div class="dax-uptime dax-uptime--inline" aria-label="پایداری شبکه ۹۹.۹۹ درصد">
            <div class="dax-uptime__bars" aria-hidden="true">
                <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                <i class="is-ember"></i><i class="is-ember"></i><i></i><i></i>
            </div>
            <span class="dax-uptime__label">پایداری شبکه: ۹۹.۹۹٪</span>
        </div>

        <nav class="dax-nav" aria-label="پیوندهای سریع">
            <a href="{$WEB_ROOT}/index.php" class="dax-back">
                <span>بازگشت به وب‌سایت</span>
                <span class="dax-back__arrow" aria-hidden="true">←</span>
            </a>
        </nav>
    </header>

    <!-- ۲. صحنه اصلی (دو ستونه نامتقارن) -->
    <main class="dax-stage dax-stage--register" id="dpMain">

        <!-- ستون راست: تایپوگرافی ادیتوریال و شاخص مراحل (30%) -->
        <section class="dax-editorial" aria-labelledby="daxRegTitle">
            <div class="dax-badge">
                <i aria-hidden="true"></i>
                <span>ثبت‌نام در درگاه ابری</span>
            </div>

            <h1 class="dax-headline" id="daxRegTitle">
                ساخت حساب<br>کاربری.
            </h1>

            <p class="dax-desc">
                ایجاد شناسه یکپارچه برای استقرار سرورهای ابری، ثبت دامنه و مدیریت سرویس‌های میزبانی.
            </p>

            <!-- شاخص عمودی ۳ مرحله‌ای (هماهنگ با بخش‌های فرم) -->
            <ol class="dax-steps" aria-label="مراحل ثبت‌نام">
                <li class="dax-steps__item is-active" data-step-indicator="1">
                    <span class="dax-steps__dot" aria-hidden="true"></span>
                    <span class="dax-steps__num">۰۱</span>
                    <span class="dax-steps__text">اطلاعات شخصی</span>
                </li>
                <li class="dax-steps__item" data-step-indicator="2">
                    <span class="dax-steps__dot" aria-hidden="true"></span>
                    <span class="dax-steps__num">۰۲</span>
                    <span class="dax-steps__text">آدرس و مشخصات مالی</span>
                </li>
                <li class="dax-steps__item" data-step-indicator="3">
                    <span class="dax-steps__dot" aria-hidden="true"></span>
                    <span class="dax-steps__num">۰۳</span>
                    <span class="dax-steps__text">امنیت و گذرواژه</span>
                </li>
            </ol>
        </section>

        <!-- ستون چپ-مرکز: لوح یکپارچه ثبت‌نام (70%) -->
        <div class="dax-panel-area dax-panel-area--register">
            {if $registrationDisabled}
                <div class="dax-card dax-card--register">
                    <div class="dax-flash" role="alert">
                        {include file="$template/includes/alert.tpl" type="error" msg="{lang key='registerCreateAccount'}"|cat:' <strong><a href="'|cat:"$WEB_ROOT"|cat:'/cart.php" class="alert-link">'|cat:"{lang key='registerCreateAccountOrder'}"|cat:'</a></strong>'}
                    </div>
                </div>
            {else}
                <div id="registration" class="dax-reg-wrap">
                    <form method="post" class="using-password-strength dax-card dax-card--register" action="{$smarty.server.PHP_SELF}" role="form" name="orderfrm" id="frmCheckout" data-dax-reg-form>
                        <input type="hidden" name="register" value="true"/>

                        {if $errormessage}
                            <div class="dax-flash" role="alert">
                                {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
                            </div>
                        {/if}

                        <div id="containerNewUserSignup">
                            <div class="dax-linked dax-linked--top">
                                {include file="$template/includes/linkedaccounts.tpl" linkContext="registration"}
                            </div>

                            <!-- ==================== بخش ۰۱: اطلاعات شخصی ==================== -->
                            <section class="dax-sec" id="personalInformation" data-step-section="1">
                                <header class="dax-sec__head">
                                    <span class="dax-sec__num">۰۱ </span>
                                    <h2 class="dax-sec__title">اطلاعات شخصی</h2>
                                </header>

                                <div class="dax-grid dax-grid--2">
                                    <div class="dax-field">
                                        <label for="inputFirstName">نام</label>
                                        <input type="text" name="firstname" id="inputFirstName" class="dax-input field form-control" value="{$clientfirstname}" {if !in_array('firstname', $optionalFields)}required{/if} autofocus>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputLastName">نام خانوادگی</label>
                                        <input type="text" name="lastname" id="inputLastName" class="dax-input field form-control" value="{$clientlastname}" {if !in_array('lastname', $optionalFields)}required{/if}>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputEmail">آدرس ایمیل</label>
                                        <input type="email" name="email" id="inputEmail" class="dax-input field form-control" placeholder="name@datahoteling.com" dir="ltr" value="{$clientemail}" required>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputPhone">شماره تلفن</label>
                                        <input type="tel" name="phonenumber" id="inputPhone" class="dax-input field form-control" placeholder="0912 345 6789" dir="ltr" value="{$clientphonenumber}" {if !in_array('phonenumber', $optionalFields)}required{/if}>
                                    </div>
                                </div>
                            </section>

                            <!-- ==================== بخش ۰۲: آدرس مالی ==================== -->
                            <section class="dax-sec" data-step-section="2">
                                <header class="dax-sec__head">
                                    <span class="dax-sec__num">۰۲</span>
                                    <h2 class="dax-sec__title">آدرس مالی</h2>
                                </header>

                                <div class="dax-grid dax-grid--2">
                                    <div class="dax-field">
                                        <label for="inputCompanyName">نام شرکت (اختیاری)</label>
                                        <input type="text" name="companyname" id="inputCompanyName" class="dax-input field form-control" value="{$clientcompanyname}">
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputCountry">کشور</label>
                                        <div class="dax-select-wrap">
                                            <select name="country" id="inputCountry" class="dax-input dax-select field form-control">
                                                {foreach $clientcountries as $countryCode => $countryName}
                                                    <option value="{$countryCode}"{if (!$clientcountry && $countryCode eq $defaultCountry) || ($countryCode eq $clientcountry)} selected="selected"{/if}>
                                                        {$countryName}
                                                    </option>
                                                {/foreach}
                                            </select>
                                        </div>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputAddress1">آدرس</label>
                                        <input type="text" name="address1" id="inputAddress1" class="dax-input field form-control" value="{$clientaddress1}" {if !in_array('address1', $optionalFields)}required{/if}>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputAddress2">آدرس ۲ (واحد / پلاک)</label>
                                        <input type="text" name="address2" id="inputAddress2" class="dax-input field form-control" value="{$clientaddress2}">
                                    </div>
                                </div>

                                <div class="dax-grid dax-grid--3 dax-mt-12">
                                    <div class="dax-field form-group">
                                        <label for="state">استان</label>
                                        <input type="text" name="state" id="state" class="dax-input field form-control" value="{$clientstate}" {if !in_array('state', $optionalFields)}required{/if}>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputCity">شهر</label>
                                        <input type="text" name="city" id="inputCity" class="dax-input field form-control" value="{$clientcity}" {if !in_array('city', $optionalFields)}required{/if}>
                                    </div>

                                    <div class="dax-field">
                                        <label for="inputPostcode">کد پستی</label>
                                        <input type="text" name="postcode" id="inputPostcode" class="dax-input field form-control" dir="ltr" value="{$clientpostcode}" {if !in_array('postcode', $optionalFields)}required{/if}>
                                    </div>
                                </div>

                                {if $showTaxIdField}
                                    <div class="dax-grid dax-grid--1 dax-mt-12">
                                        <div class="dax-field">
                                            <label for="inputTaxId">{$taxLabel} ({lang key='orderForm.optional'})</label>
                                            <input type="text" name="tax_id" id="inputTaxId" class="dax-input field form-control" value="{$clientTaxId}">
                                        </div>
                                    </div>
                                {/if}

                                {if $customfields || $currencies}
                                    <div class="dax-grid dax-grid--2 dax-mt-12">
                                        {if $customfields}
                                            {foreach $customfields as $customfield}
                                                <div class="dax-field form-group">
                                                    <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                                                    <div class="control">
                                                        {$customfield.input}
                                                        {if $customfield.description}
                                                            <span class="dax-help">{$customfield.description}</span>
                                                        {/if}
                                                    </div>
                                                </div>
                                            {/foreach}
                                        {/if}

                                        {if $currencies}
                                            <div class="dax-field">
                                                <label for="inputCurrency">واحد پول</label>
                                                <div class="dax-select-wrap">
                                                    <select id="inputCurrency" name="currency" class="dax-input dax-select field form-control">
                                                        {foreach $currencies as $curr}
                                                            <option value="{$curr.id}"{if !$smarty.post.currency && $curr.default || $smarty.post.currency eq $curr.id } selected{/if}>{$curr.code}</option>
                                                        {/foreach}
                                                    </select>
                                                </div>
                                            </div>
                                        {/if}
                                    </div>
                                {/if}
                            </section>
                        </div>

                        <!-- ==================== بخش ۰۳: امنیت اکانت ==================== -->
                        <div id="containerNewUserSecurity"{if $remote_auth_prelinked && !$securityquestions} class="w-hidden"{/if}>
                            <section class="dax-sec" data-step-section="3">
                                <header class="dax-sec__head dax-sec__head--split">
                                    <div class="dax-sec__head-right">
                                        <span class="dax-sec__num">۰۳</span>
                                        <h2 class="dax-sec__title">امنیت اکانت</h2>
                                    </div>

                                    <button type="button" class="dax-gen-pw generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">
                                        <span>ایجاد گذرواژه</span>
                                        <i class="fas fa-sync-alt" aria-hidden="true"></i>
                                    </button>
                                </header>

                                <div id="containerPassword" class="dax-pw-block{if $remote_auth_prelinked && $securityquestions} hidden{/if}">
                                    <div id="passwdFeedback" class="alert alert-info text-center w-hidden"></div>

                                    <div class="dax-grid dax-grid--2">
                                        <div class="dax-field">
                                            <label for="inputNewPassword1">کلمه عبور</label>
                                            <div class="dax-ig dax-ig--pw">
                                                <input type="password" name="password" id="inputNewPassword1" data-error-threshold="{$pwStrengthErrorThreshold}" data-warning-threshold="{$pwStrengthWarningThreshold}" class="dax-input dax-input--pw field form-control" placeholder="••••••••••" dir="ltr" autocomplete="new-password"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                                <div class="dax-pw-actions">
                                                    <button class="dax-reveal" type="button" aria-label="نمایش رمز عبور" aria-pressed="false" data-dax-reveal-pw="inputNewPassword1">
                                                        <i class="fas fa-eye" aria-hidden="true"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="dax-field">
                                            <label for="inputNewPassword2">تایید کلمه عبور</label>
                                            <div class="dax-ig dax-ig--pw">
                                                <input type="password" name="password2" id="inputNewPassword2" class="dax-input dax-input--pw field form-control" placeholder="••••••••••" dir="ltr" autocomplete="new-password"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- نوار سنجش قدرت رمز عبور (۱۰ سگمنت مطابق طرح) -->
                                    <div class="dax-pw-meter password-strength-meter">
                                        <div class="dax-pw-meter__top">
                                            <p class="dax-pw-meter__label" id="passwordStrengthTextLabel">
                                                قدرت رمز عبور: <strong>{lang key='pwstrengthenter'}</strong>
                                            </p>
                                        </div>

                                        <!-- نوار اصلی WHMCS (مخفی، برای حفظ عملکرد PasswordStrength.js) -->
                                        <div class="progress dax-sr-progress" aria-hidden="true">
                                            <div class="progress-bar bg-success bg-striped" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" id="passwordStrengthMeterBar"></div>
                                        </div>

                                        <!-- ۱۰ سگمنت بصری مطابق دیزاین -->
                                        <div class="dax-pw-segments" data-dax-segments aria-hidden="true">
                                            <i></i><i></i><i></i><i></i><i></i>
                                            <i></i><i></i><i></i><i></i><i></i>
                                        </div>
                                    </div>
                                </div>

                                {if $securityquestions}
                                    <div class="dax-grid dax-grid--2 dax-mt-12">
                                        <div class="dax-field">
                                            <label for="inputSecurityQId">{lang key='clientareasecurityquestion'}</label>
                                            <div class="dax-select-wrap">
                                                <select name="securityqid" id="inputSecurityQId" class="dax-input dax-select field form-control">
                                                    <option value="">{lang key='clientareasecurityquestion'}</option>
                                                    {foreach $securityquestions as $question}
                                                        <option value="{$question.id}"{if $question.id eq $securityqid} selected{/if}>
                                                            {$question.question}
                                                        </option>
                                                    {/foreach}
                                                </select>
                                            </div>
                                        </div>
                                        <div class="dax-field">
                                            <label for="inputSecurityQAns">{lang key='clientareasecurityanswer'}</label>
                                            <input type="password" name="securityqans" id="inputSecurityQAns" class="dax-input field form-control" autocomplete="off">
                                        </div>
                                    </div>
                                {/if}

                                {if $showMarketingEmailOptIn}
                                    <div class="dax-marketing dax-mt-12">
                                        <label class="dax-check">
                                            <input type="checkbox" name="marketingoptin" value="1"{if $marketingEmailOptIn} checked{/if} class="no-icheck">
                                            <span class="dax-check__box" aria-hidden="true"></span>
                                            <span>{lang key='emailMarketing.joinOurMailingList'}</span>
                                        </label>
                                    </div>
                                {/if}

                                {if $captcha->isEnabled()}
                                    <div class="dax-captcha dax-mt-12" data-dax-captcha>
                                        {include file="$template/includes/captcha.tpl"}
                                    </div>
                                {/if}
                            </section>
                        </div>

                        <!-- ==================== فوتر کارت: پذیرش قوانین + دکمه ثبت‌نام ==================== -->
                        <footer class="dax-reg-foot">
                            <div class="dax-reg-foot__right">
                                {if $accepttos}
                                    <label class="dax-check dax-check--tos">
                                        <input type="checkbox" name="accepttos" class="form-check-input accepttos" required>
                                        <span class="dax-check__box" aria-hidden="true"></span>
                                        <span>قوانین و شرایط سرویس‌دهی را مطالعه کرده و <a href="{$tosurl}" target="_blank">می‌پذیرم</a>.</span>
                                    </label>
                                {/if}

                                <div class="dax-reg-foot__login">
                                    <span>قبلاً ثبت‌نام کرده‌اید؟</span>
                                    <a href="{$WEB_ROOT}/login.php" class="dax-foot__link">ورود به حساب</a>
                                </div>
                            </div>

                            <div class="dax-reg-foot__left">
                                <button type="submit" class="dax-submit dax-submit--register{$captcha->getButtonClass($captchaForm)}">
                                    <span class="dax-submit__label">ایجاد حساب کاربری ←</span>
                                </button>
                            </div>
                        </footer>
                    </form>
                </div>
            {/if}
        </div>

    </main>
</div>

{literal}
<script>
(function () {
    'use strict';
    var form = document.querySelector('[data-dax-reg-form]');
    if (!form) { return; }

    /* ۱. همگام‌سازی شاخص مراحل سمت راست (۰۱، ۰۲، ۰۳) با فوکوس کاربر روی فیلدها */
    var sections = form.querySelectorAll('[data-step-section]');
    var indicators = document.querySelectorAll('[data-step-indicator]');

    function setActiveStep(stepNum) {
        indicators.forEach(function (ind) {
            ind.classList.toggle('is-active', ind.getAttribute('data-step-indicator') === String(stepNum));
        });
    }

    sections.forEach(function (sec) {
        var step = sec.getAttribute('data-step-section');
        sec.addEventListener('focusin', function () { setActiveStep(step); });
        sec.addEventListener('click', function () { setActiveStep(step); });
    });

    /* ۲. دکمه نمایش / پنهان‌کردن رمز عبور */
    var revealBtn = form.querySelector('[data-dax-reveal-pw]');
    var pw1 = document.getElementById('inputNewPassword1');
    var pw2 = document.getElementById('inputNewPassword2');

    if (revealBtn && pw1) {
        revealBtn.addEventListener('click', function () {
            var show = pw1.type === 'password';
            pw1.type = show ? 'text' : 'password';
            if (pw2) { pw2.type = show ? 'text' : 'password'; }
            revealBtn.setAttribute('aria-pressed', show ? 'true' : 'false');
            var icon = revealBtn.querySelector('i');
            if (icon) { icon.className = show ? 'fas fa-eye-slash' : 'fas fa-eye'; }
            pw1.focus();
        });
    }

    /* ۳. همگام‌سازی نوار ۱۰ سگمنتی قدرت رمز عبور با PasswordStrength.js در WHMCS */
    var meterBar = document.getElementById('passwordStrengthMeterBar');
    var segWrap = form.querySelector('[data-dax-segments]');
    var segments = segWrap ? segWrap.querySelectorAll('i') : [];

    function syncPasswordSegments() {
        if (!meterBar || !segments.length) { return; }
        var val = parseInt(meterBar.getAttribute('aria-valuenow') || '0', 10);
        if (!val && meterBar.style.width) {
            val = parseInt(meterBar.style.width, 10) || 0;
        }
        if (pw1 && !pw1.value) { val = 0; }
        var activeCount = Math.round((Math.min(100, Math.max(0, val)) / 100) * segments.length);
        segments.forEach(function (seg, idx) {
            seg.classList.toggle('is-on', idx < activeCount);
        });
    }

    if (pw1) {
        pw1.addEventListener('keyup', function () { window.setTimeout(syncPasswordSegments, 30); });
        pw1.addEventListener('input', function () { window.setTimeout(syncPasswordSegments, 30); });
        pw1.addEventListener('change', function () { window.setTimeout(syncPasswordSegments, 50); });
    }

    if (meterBar && window.MutationObserver) {
        var obs = new MutationObserver(syncPasswordSegments);
        obs.observe(meterBar, { attributes: true, attributeFilter: ['style', 'aria-valuenow', 'class'] });
    }
}());
</script>
{/literal}