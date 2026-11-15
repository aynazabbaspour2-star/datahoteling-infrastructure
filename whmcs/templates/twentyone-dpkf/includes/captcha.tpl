{if $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
    <div class="dh-captcha-wrap{if $containerClass} {$containerClass}{/if}">
        {if $templatefile == 'homepage'}
            <div class="domainchecker-homepage-captcha">
        {/if}

        {if $captcha->recaptcha->isEnabled() && !$captcha->recaptcha->isInvisible()}
            <div id="google-recaptcha-domainchecker" class="form-group recaptcha-container dh-recaptcha mx-auto" data-action="{$captchaForm}"></div>
        {elseif !$captcha->recaptcha->isEnabled()}
            <div id="default-captcha-domainchecker" class="dh-captcha{if $filename == 'domainchecker'} input-group input-group-box{/if}" data-dh-captcha>
                
                <div class="dh-captcha__head">
                    <span class="dh-captcha__label">کد امنیتی</span>
                    <span class="dh-captcha__hint">حروف تصویر را وارد کنید</span>
                </div>

                <div class="dh-captcha__dock">
                    <!-- فیلد ورود کد امنیتی -->
                    <div class="dh-captcha__field">
                        <input
                            id="inputCaptcha"
                            type="text"
                            name="code"
                            maxlength="6"
                            class="form-control dh-captcha__input"
                            placeholder="• • • • • •"
                            dir="ltr"
                            autocomplete="off"
                            autocapitalize="characters"
                            spellcheck="false"
                            aria-label="{lang key='captchaverify'}"
                            data-toggle="tooltip"
                            data-placement="right"
                            data-trigger="manual"
                            title="{lang key='orderForm.required'}"
                            required
                        />
                    </div>

                    <!-- تصویر کپچا (تاریک‌شده با فیلتر نوری) + دکمه بارگذاری مجدد -->
                    <div class="dh-captcha__visual captchaimage">
                        <div class="dh-captcha__img-box" title="برای دریافت تصویر جدید کلیک کنید">
                            <img
                                id="inputCaptchaImage"
                                class="dh-captcha__img"
                                data-src="{$systemurl}includes/verifyimage.php"
                                src="{$systemurl}includes/verifyimage.php"
                                alt="Captcha"
                            />
                        </div>
                        <button
                            type="button"
                            class="dh-captcha__refresh"
                            aria-label="دریافت کد امنیتی جدید"
                            title="تصویر جدید"
                            data-dh-captcha-refresh
                        >
                            <i class="fas fa-sync-alt" aria-hidden="true"></i>
                        </button>
                    </div>
                </div>

            </div>
        {/if}

        {if $templatefile == 'homepage'}
            </div>
        {/if}
    </div>

    {literal}
    <script>
    (function () {
        'use strict';
        var widgets = document.querySelectorAll('[data-dh-captcha]:not([data-dh-ready])');
        widgets.forEach(function (widget) {
            widget.setAttribute('data-dh-ready', '1');
            var img = widget.querySelector('#inputCaptchaImage');
            var btn = widget.querySelector('[data-dh-captcha-refresh]');
            var input = widget.querySelector('#inputCaptcha');
            if (!img) { return; }

            var baseSrc = img.getAttribute('data-src') || img.getAttribute('src') || '';
            function refreshCaptcha(e) {
                if (e) { e.preventDefault(); }
                if (btn) {
                    btn.classList.remove('is-spinning');
                    void btn.offsetWidth;
                    btn.classList.add('is-spinning');
                }
                var sep = baseSrc.indexOf('?') > -1 ? '&' : '?';
                img.src = baseSrc + sep + 'r=' + Date.now();
                if (input) {
                    input.value = '';
                    input.focus();
                }
            }

            if (btn) { btn.addEventListener('click', refreshCaptcha); }
            img.addEventListener('click', refreshCaptcha);
        });
    }());
    </script>
    {/literal}
{/if}