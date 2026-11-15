{if $templatefile != 'homepage'}
                    </div>
                    {if !$inShoppingCart && $secondarySidebar->hasChildren()}
                        <div class="d-lg-none sidebar sidebar-secondary">
                            {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                        </div>
                    {/if}
                <div class="clearfix"></div>
            </div>
        </div>
    </section>
{/if}

{assign var="dpFooterCols" value=[
    [
        "title" => "محصولات",
        "links" => [
            ["label" => "Data-economy",   "url" => "{$WEB_ROOT}/cart.php?gid=1"],
            ["label" => "Data-wordpress", "url" => "{$WEB_ROOT}/cart.php?gid=4"],
            ["label" => "Data-cloud",     "url" => "{$WEB_ROOT}/cart.php?gid=3"],
            ["label" => "Data Linux",     "url" => "{$WEB_ROOT}/cart.php?gid=2"],
            ["label" => "ثبت دامنه",      "url" => "{$WEB_ROOT}/cart.php?a=add&domain=register"]
        ]
    ],
    [
        "title" => "شرکت",
        "links" => [
            ["label" => "درباره ما",     "url" => "{$WEB_ROOT}/contact.php"],
            ["label" => "تماس با ما",    "url" => "{$WEB_ROOT}/contact.php"],
            ["label" => "وبلاگ",         "url" => "{$WEB_ROOT}/announcements.php"],
            ["label" => "همکاری با ما",  "url" => "{$WEB_ROOT}/affiliates.php"]
        ]
    ],
    [
        "title" => "پشتیبانی",
        "links" => [
            ["label" => "مرکز پشتیبانی",   "url" => "{$WEB_ROOT}/supporttickets.php"],
            ["label" => "پایگاه دانش",     "url" => "{$WEB_ROOT}/knowledgebase.php"],
            ["label" => "تیکت پشتیبانی",   "url" => "{$WEB_ROOT}/submitticket.php"],
            ["label" => "وضعیت سرویس‌ها",  "url" => "{$WEB_ROOT}/serverstatus.php"]
        ]
    ],
    [
        "title" => "قوانین",
        "links" => [
            ["label" => "شرایط استفاده",  "url" => "{if $acceptTOS}{$tosURL}{else}{$WEB_ROOT}/contact.php{/if}"],
            ["label" => "حریم خصوصی",     "url" => "{$WEB_ROOT}/contact.php"],
            ["label" => "بازگشت وجه",     "url" => "{$WEB_ROOT}/contact.php"],
            ["label" => "قوانین دامنه",   "url" => "{$WEB_ROOT}/contact.php"]
        ]
    ]
]}

{* Replace the "#" placeholders with your real social profile URLs. *}
{assign var="dpSocial" value=[
    ["icon" => "fab fa-telegram-plane", "label" => "تلگرام",     "url" => "#"],
    ["icon" => "fab fa-instagram",      "label" => "اینستاگرام", "url" => "#"],
    ["icon" => "fab fa-linkedin-in",    "label" => "لینکدین",    "url" => "#"],
    ["icon" => "fab fa-twitter",        "label" => "ایکس",       "url" => "#"]
]}

    <footer id="footer" class="dp-footer dpft" data-dp-glow>
        <div class="dpft-spot" aria-hidden="true"></div>

        <div class="dp-container dpft-inner">

            {* ---- Newsletter band ---- *}
            <div class="dpft-news">
                <div class="dpft-news__text">
                    <h2 class="dpft-news__title">از تازه‌ترین‌ها جا نمانید</h2>
                    <p class="dpft-news__sub">آخرین تخفیف‌ها، آموزش‌ها و اخبار هاستینگ را دریافت کنید.</p>
                </div>
                <div class="dpft-news__form">
                    {* Front-end only. Point action= at your mailing-list endpoint when you have one. *}
                    <form class="dp-newsletter" data-dp-newsletter novalidate>
                        <label class="sr-only" for="dpNewsletter">ایمیل شما</label>
                        <input class="dp-newsletter__input" type="email" id="dpNewsletter" name="email" placeholder="ایمیل خود را وارد کنید" autocomplete="email" dir="ltr">
                        <button class="dp-newsletter__submit" type="submit">
                            <span>عضویت</span><i class="fas fa-arrow-left" aria-hidden="true"></i>
                        </button>
                    </form>
                    <p class="dp-newsletter__msg" role="alert" data-dp-newsletter-msg hidden></p>
                </div>
            </div>

            {* ---- Brand + link columns ---- *}
            <div class="dpft-main">
                <div class="dpft-brand">
                    <a class="dpft-brand__name" href="{$WEB_ROOT}/">دیتاهتلینگ<i class="dpft-brand__dot" aria-hidden="true"></i></a>
                    <p class="dpft-brand__text">میزبانی وب، سرور مجازی و دامنه روی زیرساختی سریع و قابل اتکا؛ همه در یک پنل.</p>

                    <ul class="dp-social dpft-social">
                        {foreach $dpSocial as $s}
                            <li><a href="{$s.url}" aria-label="{$s.label}"><i class="{$s.icon}" aria-hidden="true"></i></a></li>
                        {/foreach}
                    </ul>

                    <a class="dpft-status" href="{$WEB_ROOT}/serverstatus.php">
                        <span class="dpft-status__ticks" aria-hidden="true">{for $i=1 to 28}<i{if $i==6 || $i==15 || $i==23} class="is-hit"{/if}></i>{/for}</span>
                        <span class="dpft-status__label">وضعیت سرویس‌ها</span>
                    </a>

                    <div class="dp-enamad dpft-enamad">
                        <a referrerpolicy='origin' target='_blank' href='https://trustseal.enamad.ir/?id=555631&Code=kEvrBgSLrXg0vWcIHHWeeHKx1DwsOr5d'>
                            <img referrerpolicy='origin' src='https://trustseal.enamad.ir/logo.aspx?id=555631&Code=kEvrBgSLrXg0vWcIHHWeeHKx1DwsOr5d' alt='نماد اعتماد الکترونیکی' style='cursor:pointer' code='kEvrBgSLrXg0vWcIHHWeeHKx1DwsOr5d'>
                        </a>
                    </div>
                </div>

                <nav class="dpft-cols" aria-label="پیوندهای فوتر">
                    {foreach $dpFooterCols as $col}
                        <div class="dpft-col">
                            <h2 class="dpft-col__title">{$col.title}</h2>
                            <ul class="dpft-col__list">
                                {foreach $col.links as $link}
                                    <li><a href="{$link.url}">{$link.label}</a></li>
                                {/foreach}
                            </ul>
                        </div>
                    {/foreach}
                </nav>
            </div>

            {* ---- Bottom bar ---- *}
            <div class="dpft-bottom">
                <p class="dpft-bottom__copy">© ۱۴۰۵ تمامی حقوق این وب‌سایت برای دیتاهتلینگ خلیج فارس محفوظ است.</p>

                <div class="dpft-bottom__meta">
                    {if $languagechangeenabled && count($locales) > 1 || $currencies}
                        <button type="button" class="dp-footer__locale" data-toggle="modal" data-target="#modalChooseLanguage">
                            <span class="iti-flag {if $activeLocale.countryCode === '001'}us{else}{$activeLocale.countryCode|lower}{/if}"></span>
                            {$activeLocale.localisedName}
                            {if $currencies} / {$activeCurrency.code}{/if}
                        </button>
                    {/if}
                    <a href="{$WEB_ROOT}/contact.php">{lang key='contactus'}</a>
                </div>
            </div>
        </div>

        {* Giant wordmark — revealed in ember under the pointer *}
        <div class="dpft-mark" aria-hidden="true">
            <span class="dpft-mark__base">DATAHOTELING</span>
            <span class="dpft-mark__lit">DATAHOTELING</span>
        </div>
    </footer>

    <div id="fullpage-overlay" class="w-hidden">
        <div class="outer-wrapper">
            <div class="inner-wrapper">
                <img src="{$WEB_ROOT}/assets/img/overlay-spinner.svg" alt="">
                <br>
                <span class="msg"></span>
            </div>
        </div>
    </div>

    <div class="modal system-modal fade" id="modalAjax" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"></h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">&times;</span>
                        <span class="sr-only">{lang key='close'}</span>
                    </button>
                </div>
                <div class="modal-body">
                    {lang key='loading'}
                </div>
                <div class="modal-footer">
                    <div class="float-left loader">
                        <i class="fas fa-circle-notch fa-spin"></i>
                        {lang key='loading'}
                    </div>
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        {lang key='close'}
                    </button>
                    <button type="button" class="btn btn-primary modal-submit">
                        {lang key='submit'}
                    </button>
                </div>
            </div>
        </div>
    </div>

    <form method="get" action="{$currentpagelinkback}">
        <div class="modal modal-localisation" id="modalChooseLanguage" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-body">
                        <button type="button" class="close text-light" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>

                        {if $languagechangeenabled && count($locales) > 1}
                            <h5 class="h5 pt-5 pb-3">{lang key='chooselanguage'}</h5>
                            <div class="row item-selector">
                                <input type="hidden" name="language" data-current="{$language}" value="{$language}" />
                                {foreach $locales as $locale}
                                    <div class="col-4">
                                        <a href="#" class="item{if $language == $locale.language} active{/if}" data-value="{$locale.language}">
                                            {$locale.localisedName}
                                        </a>
                                    </div>
                                {/foreach}
                            </div>
                        {/if}
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-default">{lang key='apply'}</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    {if !$loggedin && $adminLoggedIn}
        <a href="{$WEB_ROOT}/logout.php?returntoadmin=1" class="btn btn-return-to-admin" data-toggle="tooltip" data-placement="bottom" title="{if $adminMasqueradingAsClient}{lang key='adminmasqueradingasclient'} {lang key='logoutandreturntoadminarea'}{else}{lang key='adminloggedin'} {lang key='returntoadminarea'}{/if}">
            <i class="fas fa-redo-alt"></i>
            <span class="d-none d-md-inline-block">{lang key="admin.returnToAdmin"}</span>
        </a>
    {/if}

    {include file="$template/includes/generate-password.tpl"}

    {$footeroutput}

    <script src="/templates/{$template}/js/custom.js?v=9" defer></script>

</body>
</html>
