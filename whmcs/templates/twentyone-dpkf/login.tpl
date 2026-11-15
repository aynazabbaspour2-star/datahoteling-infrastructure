<script>document.body.classList.add("dax-body");</script>

<div class="providerLinkingFeedback"></div>

<div class="dax-page">
    <!-- پس‌زمینه، مکعب‌های سه‌بعدی در پایین-چپ و خطوط معماری ۱ پیکسلی -->
    <div class="dax-wall" aria-hidden="true">
        <span class="dax-vline"></span>
        <span class="dax-crosshair"></span>
    </div>

    <!-- ۱. هدر بالایی (72px) -->
    <header class="dax-top">
        <a class="dax-logo" href="{$WEB_ROOT}/" aria-label="دیتاهتلینگ">
            دیتاهتلینگ<i aria-hidden="true"></i>
        </a>

        <div class="dax-uptime" aria-label="پایداری شبکه ۹۹.۹۹ درصد">
            <div class="dax-uptime__bars" aria-hidden="true">
                <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                <i></i><i></i><i></i><i></i><i class="is-ember"></i><i></i><i></i><i></i>
                <i></i><i></i><i></i><i></i><i></i><i class="is-ember"></i><i></i><i></i>
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

    <!-- ۲. صحنه اصلی نامتقارن -->
    <main class="dax-stage" id="dpMain">
        
        <!-- ستون راست: تایپوگرافی ادیتوریال (ورود به زیرساخت.) -->
        <section class="dax-editorial" aria-labelledby="daxHeroTitle">
            <div class="dax-badge">
                <i aria-hidden="true"></i>
                <span>درگاه یکپارچه ابری</span>
            </div>
            <h1 class="dax-headline" id="daxHeroTitle">
                ورود به<br>زیرساخت.
            </h1>
            <p class="dax-desc">
                مدیریت سرورها، دامنه‌ها و سرویس‌های میزبانی در یک محیط امن و یکپارچه.
            </p>
        </section>

        <!-- ستون چپ-مرکز: کارت لاگین مونولیتیک -->
        <div class="dax-panel-area">
            <form method="post" action="{routePath('login-validate')}" class="login-form dax-card" data-dax-form>
                
                <div class="dax-card__head">
                    <span class="dax-card__pill">ورود به حساب کاربری</span>
                </div>

                <div class="dax-flash" role="alert">{include file="$template/includes/flashmessage.tpl"}</div>

                <div class="dax-fields">
                    <!-- فیلد ایمیل / نام کاربری -->
                    <div class="dax-field">
                        <label for="inputEmail">پست الکترونیک یا نام کاربری</label>
                        <div class="dax-ig">
                            <input
                                type="email"
                                class="dax-input"
                                name="username"
                                id="inputEmail"
                                placeholder="مثال: username@datahoteling.com"
                                dir="ltr"
                                inputmode="email"
                                autocomplete="username"
                                autocapitalize="off"
                                spellcheck="false"
                                required
                            >
                        </div>
                    </div>

                    <!-- فیلد رمز عبور + فراموشی رمز در سمت چپ داخل کادر -->
                    <div class="dax-field">
                        <label for="inputPassword">رمز عبور</label>
                        <div class="dax-ig dax-ig--pw">
                            <input
                                type="password"
                                class="dax-input dax-input--pw"
                                name="password"
                                id="inputPassword"
                                placeholder="••••••••••"
                                dir="ltr"
                                autocomplete="current-password"
                                aria-describedby="daxCaps"
                                required
                            >
                            <div class="dax-pw-actions">
                                <button class="dax-reveal" type="button" aria-label="نمایش رمز عبور" aria-pressed="false" data-dax-reveal>
                                    <i class="fas fa-eye" aria-hidden="true"></i>
                                </button>
                                <a href="{routePath('password-reset-begin')}" class="dax-forgot">فراموشی رمز؟</a>
                            </div>
                        </div>
                        <p class="dax-hint" id="daxCaps" hidden>Caps Lock روشن است.</p>
                    </div>

                    <input type="hidden" name="rememberme" value="on">

                    {if $captcha->isEnabled()}
                        <div class="dax-captcha" data-dax-captcha>{include file="$template/includes/captcha.tpl"}</div>
                    {/if}

                    <button id="login" type="submit" class="dax-submit{$captcha->getButtonClass($captchaForm)}">
                        <span class="dax-submit__label">ورود به زیرساخت</span>
                    </button>
                </div>

                <div class="dax-linked">
                    {include file="$template/includes/linkedaccounts.tpl" linkContext="login" customFeedback=true}
                </div>

                <div class="dax-foot">
                    <span>حساب ندارید؟</span>
                    <a href="{$WEB_ROOT}/register.php" class="dax-foot__link">ثبت‌نام کنید</a>
                </div>
            </form>
        </div>

    </main>

    <footer class="dax-note" id="daxNote" hidden>
        <i class="fas fa-lock" aria-hidden="true"></i> اتصال شما رمزگذاری‌شده است
    </footer>
</div>

{literal}
<script>
(function () {
    'use strict';
    var form = document.querySelector('[data-dax-form]');
    if (!form) { return; }

    var email = form.querySelector('#inputEmail');
    var pass = form.querySelector('#inputPassword');

    if (email && window.matchMedia && window.matchMedia('(min-width: 992px)').matches) {
        email.focus();
    }

    var note = document.getElementById('daxNote');
    if (note && window.location.protocol === 'https:') { note.hidden = false; }

    var reveal = form.querySelector('[data-dax-reveal]');
    if (reveal && pass) {
        reveal.addEventListener('click', function () {
            var show = pass.type === 'password';
            pass.type = show ? 'text' : 'password';
            reveal.setAttribute('aria-pressed', show ? 'true' : 'false');
            reveal.setAttribute('aria-label', show ? 'پنهان کردن رمز عبور' : 'نمایش رمز عبور');
            var icon = reveal.querySelector('i');
            if (icon) { icon.className = show ? 'fas fa-eye-slash' : 'fas fa-eye'; }
            pass.focus();
        });
    }

    var caps = document.getElementById('daxCaps');
    function checkCaps(e) {
        if (!caps || !e.getModifierState) { return; }
        caps.hidden = !e.getModifierState('CapsLock');
    }
    if (pass) {
        pass.addEventListener('keydown', checkCaps);
        pass.addEventListener('keyup', checkCaps);
        pass.addEventListener('blur', function () { if (caps) { caps.hidden = true; } });
    }

    var cap = form.querySelector('[data-dax-captcha]');
    if (cap) {
        var capInput = cap.querySelector('input[type="text"]');
        var capImg = cap.querySelector('img');
        if (capInput) {
            capInput.setAttribute('placeholder', 'کد تصویر');
            capInput.setAttribute('autocomplete', 'off');
            capInput.setAttribute('aria-label', 'کد امنیتی داخل تصویر');
            capInput.setAttribute('dir', 'ltr');
        }
        if (capImg && capImg.parentNode) {
            var baseSrc = capImg.getAttribute('src') || '';
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'dax-captcha__refresh';
            btn.setAttribute('aria-label', 'دریافت تصویر جدید');
            btn.innerHTML = '<i class="fas fa-sync-alt" aria-hidden="true"></i>';
            capImg.parentNode.appendChild(btn);
            var refresh = function () {
                var sep = baseSrc.indexOf('?') > -1 ? '&' : '?';
                capImg.src = baseSrc + sep + 'r=' + Date.now();
                if (capInput) { capInput.value = ''; capInput.focus(); }
            };
            btn.addEventListener('click', refresh);
            capImg.addEventListener('click', refresh);
        }
    }

    var submit = form.querySelector('.dax-submit');
    var timer = 0;
    function idle() {
        if (submit) { submit.classList.remove('is-loading'); }
        form.removeAttribute('data-busy');
        window.clearTimeout(timer);
    }
    form.addEventListener('submit', function (e) {
        if (form.getAttribute('data-busy') === '1') { e.preventDefault(); return; }
        window.setTimeout(function () {
            if (e.defaultPrevented) { return; }
            form.setAttribute('data-busy', '1');
            if (submit) { submit.classList.add('is-loading'); }
            timer = window.setTimeout(idle, 12000);
        }, 0);
    });
    window.addEventListener('pageshow', idle);
}());
</script>
{/literal}