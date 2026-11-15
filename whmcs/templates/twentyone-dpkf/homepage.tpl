{* Premium RTL hosting homepage — دیتاهتلینگ
   Hero: pine/persimmon with glass domain panel.
   Popular plans: auto-walking slider (see initPlans in custom.js).
   Full hosting plans are available at /index.php?rp=/store/hstyng *}
{assign var="dpHero" value="/templates/{$template}/img/headerbg.webp"}
{assign var="dpHeroObj" value="/templates/{$template}/img/hero-slabs.webp"}
{assign var="dpStoreUrl" value="{$WEB_ROOT}/index.php?rp=/store/hstyng"}
{assign var="dpStats" value=[
    ["text" => "+۵۰٬۰۰۰", "unit" => "", "hot" => 1, "icon" => "fas fa-users", "meter" => 0, "sr" => "بیش از ۵۰ هزار", "label" => "کسب‌وکار و پروژه فعال"],
    ["text" => "+۱۰", "unit" => "سال", "hot" => 0, "icon" => "fas fa-award", "meter" => 0, "sr" => "بیش از ۱۰ سال", "label" => "تجربه میزبانی حرفه‌ای"],
    ["text" => "٪۹۹٫۹۹", "unit" => "", "hot" => 0, "icon" => "fas fa-chart-line", "meter" => 1, "sr" => "۹۹٫۹۹ درصد", "label" => "آپتایم تضمین‌شده شبکه"],
    ["text" => "۲۴/۷/۳۶۵", "unit" => "", "hot" => 0, "icon" => "fas fa-headset", "meter" => 0, "sr" => "۲۴ ساعت، ۷ روز هفته، ۳۶۵ روز سال", "label" => "پشتیبانی فنی شبانه‌روزی"]
]}
{assign var="dpTech" value=[
    ["icon" => "fab fa-wordpress", "name" => "WordPress"],
    ["icon" => "fas fa-cogs", "name" => "cPanel"],
    ["icon" => "fas fa-cloud", "name" => "Cloudflare"],
    ["icon" => "fab fa-laravel", "name" => "Laravel"],
    ["icon" => "fab fa-php", "name" => "PHP"],
    ["icon" => "fas fa-database", "name" => "MySQL"]
]}
{assign var="dpFeatures" value=[
    ["icon" => "fas fa-bolt", "title" => "پردازش فوق‌سریع", "text" => "بهره‌گیری از دیسک‌های NVMe نسل جدید و وب‌سرورهای بهینه برای بارگذاری آنی صفحات."],
    ["icon" => "fas fa-shield-alt", "title" => "امنیت چندلایه", "text" => "محافظت ۲۴ ساعته با فایروال سخت‌افزاری، پایش ترافیک و دفع هوشمند حملات."],
    ["icon" => "fas fa-sliders-h", "title" => "استقرار آسان", "text" => "نصب یک‌کلیکی وردپرس و سیستم‌های محبوب، همراه با انتقال رایگان وب‌سایت شما."],
    ["icon" => "fas fa-database", "title" => "بکاپ خودکار", "text" => "تهیه نسخه پشتیبان روزانه در فضای مجزا با امکان بازگردانی سریع در مواقع ضروری."],
    ["icon" => "fas fa-lock", "title" => "گواهی SSL رایگان", "text" => "صدور و تمدید خودکار گواهی امنیتی SSL روی تمامی پلن‌ها برای رمزنگاری داده‌ها."],
    ["icon" => "fas fa-headset", "title" => "پشتیبانی ۲۴/۷", "text" => "همراهی مستقیم تیم مهندسی در تمام ساعات شبانه‌روز و ایام تعطیل سال."]
]}
{assign var="dpBenefits" value=[
    "انتقال رایگان وب‌سایت",
    "نصب سریع اپلیکیشن‌ها",
    "مدیریت متمرکز دامنه‌ها",
    "بکاپ‌گیری منظم خودکار",
    "پایش هوشمند امنیت",
    "پشتیبانی فنی تخصصی"
]}
{assign var="dpTestimonials" value=[
    ["quote" => "در کمپین‌های فروش، پایداری سرورها و سرعت پاسخگویی پشتیبانی واقعاً عالی بوده و خیالم از سایت کاملاً راحت است.", "name" => "مهدی رستمی", "role" => "مدیر فروشگاه اینترنتی"],
    ["quote" => "انتقال سایت ما بدون یک ثانیه قطعی انجام شد و سرعت بارگذاری صفحات بعد از مهاجرت به شکل محسوسی افزایش یافت.", "name" => "سارا احمدی", "role" => "بنیان‌گذار استارتاپ"],
    ["quote" => "پنل مدیریت بسیار روان و مهندسی‌شده است و تقریباً تمام تنظیمات فنی را بدون اتلاف وقت انجام می‌دهم.", "name" => "علی محمدی", "role" => "توسعه‌دهنده وب"]
]}
{* ---------------- (A) داده پلن‌ها ---------------- *}
{assign var="dpPlans" value=[
    ["cat" => "hosting", "name" => "Data Economy", "num" => "۳", "unit" => "گیگ", "label" => "گیگابایت حافظه NVMe", "fill" => 3, "price" => 129, "priceText" => "۱۲۹ هزار", "featured" => 0,
     "url" => "{$WEB_ROOT}/index.php?rp=/store/hstyng",
     "features" => ["۵۰ گیگابایت ترافیک ماهانه", "۵ ایمیل، ۲ دیتابیس، ۲ FTP", "مناسب ۱ سایت و ۲ ساب‌دامین"]],
    ["cat" => "hosting", "name" => "Data Linux", "num" => "۱۰", "unit" => "گیگ", "label" => "گیگابایت حافظه NVMe", "fill" => 7, "price" => 249, "priceText" => "۲۴۹ هزار", "featured" => 1,
     "url" => "{$WEB_ROOT}/index.php?rp=/store/hstyng",
     "features" => ["۱۰۰ گیگابایت ترافیک ماهانه", "۲۰ ایمیل، ۵ دیتابیس، ۵ FTP", "۵ ساب‌دامین، ۱ ادآن دامین"]],
    ["cat" => "hosting", "name" => "Data High Traffic", "num" => "۵۰", "unit" => "گیگ", "label" => "گیگابایت حافظه NVMe", "fill" => 16, "price" => 499, "priceText" => "۴۹۹ هزار", "featured" => 0,
     "url" => "{$WEB_ROOT}/index.php?rp=/store/hstyng",
     "features" => ["۵۰۰ گیگابایت ترافیک ماهانه", "۱۰۰ ایمیل، ۲۰ دیتابیس، ۱۵ FTP", "۲۰ ساب‌دامین، ۱۰ ادآن دامین"]],
    ["cat" => "vps", "name" => "VPS استارت", "num" => "۸۰", "unit" => "گیگ", "label" => "گیگابایت فضای SSD", "fill" => 13, "price" => 490, "priceText" => "۴۹۰ هزار", "featured" => 0,
     "url" => "{$WEB_ROOT}/cart.php?a=add&pid=9",
     "features" => ["۲ هسته CPU و ۴ گیگ رم", "دسترسی کامل Root اختصاصی", "تحویل آنی در چند دقیقه"]],
    ["cat" => "vps", "name" => "VPS حرفه‌ای", "num" => "۱۶۰", "unit" => "گیگ", "label" => "گیگابایت فضای NVMe", "fill" => 18, "price" => 980, "priceText" => "۹۸۰ هزار", "featured" => 1,
     "url" => "{$WEB_ROOT}/cart.php?a=add&pid=9",
     "features" => ["۴ هسته CPU و ۸ گیگ رم", "پورت شبکه ۱ گیگابیت پایدار", "دسترسی کامل Root اختصاصی"]],
    ["cat" => "vps", "name" => "VPS پیشرفته", "num" => "۳۲۰", "unit" => "گیگ", "label" => "گیگابایت فضای NVMe", "fill" => 20, "price" => 1900, "priceText" => "۱٬۹۰۰ هزار", "featured" => 0,
     "url" => "{$WEB_ROOT}/cart.php?a=add&pid=9",
     "features" => ["۸ هسته CPU و ۱۶ گیگ رم", "پورت شبکه ۱ گیگابیت پایدار", "دسترسی کامل Root اختصاصی"]]
]}
{assign var="dpFeaturesImg" value="/templates/{$template}/img/macro.webp"}
{assign var="dpFeaturesV2" value=[
    ["title" => "پردازش فوق‌سریع", "text" => "بهره‌گیری از دیسک‌های NVMe نسل جدید و وب‌سرورهای بهینه برای بارگذاری آنی صفحات و بهبود سئو.", "chip" => "NVMe SSD"],
    ["title" => "امنیت چندلایه", "text" => "محافظت ۲۴ ساعته با فایروال سخت‌افزاری، پایش لحظه‌ای ترافیک و دفع هوشمند حملات سایبری.", "chip" => "فایروال"],
    ["title" => "استقرار آسان", "text" => "نصب یک‌کلیکی وردپرس و اپلیکیشن‌های پرکاربرد، همراه با انتقال رایگان وب‌سایت شما.", "chip" => "وردپرس"],
    ["title" => "بکاپ خودکار", "text" => "تهیه نسخه پشتیبان روزانه در سرور مجزا، با امکان بازگردانی سریع اطلاعات در مواقع نیاز.", "chip" => "خودکار"],
    ["title" => "گواهی SSL رایگان", "text" => "صدور و تمدید خودکار گواهی امنیتی SSL برای تمامی پلن‌ها جهت رمزنگاری ارتباطات.", "chip" => "همه پلن‌ها"],
    ["title" => "پشتیبانی ۲۴/۷", "text" => "همراهی مستقیم تیم مهندسی در تمام ساعات شبانه‌روز و ایام تعطیل برای رفع سریع دغدغه‌ها.", "chip" => "شبانه‌روزی"]
]}
<main class="whmcs-premium-homepage" id="dpMain">
    {* ================= 1. HERO ================= *}
    <section class="dp-hero">
        <div class="dp-hero__object" style="background-image:url('{$dpHeroObj}')" aria-hidden="true"></div>
        <div class="dp-container dp-hero__inner">
            <div class="dp-hero__content">
                <h1 class="dp-hero__title">میزبانی مطمئن<br>برای رشد پایدار کسب‌وکار شما</h1>
                <p class="dp-hero__desc">سرورهای ابری NVMe، آپتایم ۹۹.۹۹٪ و پشتیبانی ۲۴ ساعته؛ زیرساختی مهندسی‌شده برای کسب‌وکارهایی که به پایداری اهمیت می‌دهند.</p>
                <form class="dp-domain-form dp-domain-form--glass" method="post" action="{$WEB_ROOT}/domainchecker.php" data-dp-domain-form novalidate>
                    <input type="hidden" name="token" value="{$token}">
                    <input type="hidden" name="domain" value="" data-dp-domain-value>
                    <div class="dp-domain-form__box">
                        <label class="sr-only" for="dpDomainTld">پسوند دامنه</label>
                        <select class="dp-domain-form__tld" id="dpDomainTld" data-dp-domain-tld>
                            <option value=".com">.com</option>
                            <option value=".ir">.ir</option>
                            <option value=".net">.net</option>
                            <option value=".org">.org</option>
                            <option value=".co">.co</option>
                        </select>
                        <label class="sr-only" for="dpDomainName">نام دامنه</label>
                        <input class="dp-domain-form__input" type="text" id="dpDomainName" placeholder="mybrand" autocomplete="off" spellcheck="false" dir="ltr" data-dp-domain-name>
                        <button class="dp-btn dp-btn--primary dp-domain-form__submit" type="submit" data-dp-domain-submit>
                            <span data-dp-domain-label>بررسی دامنه</span>
                        </button>
                    </div>
                    <p class="dp-domain-form__msg" role="alert" data-dp-domain-msg hidden></p>
                    <ul class="dp-domain-results" data-dp-domain-results>
                        <li>
                            <button type="button" data-tld=".com">
                                <i></i>
                                <span class="dp-domain-results__name" dir="ltr">mybrand.com</span>
                                <span class="dp-domain-results__price">از ۴۸۰ هزار تومان</span>
                                <span class="dp-domain-results__act">بررسی</span>
                            </button>
                        </li>
                        <li>
                            <button type="button" data-tld=".ir">
                                <i></i>
                                <span class="dp-domain-results__name" dir="ltr">mybrand.ir</span>
                                <span class="dp-domain-results__price">از ۶۵ هزار تومان</span>
                                <span class="dp-domain-results__act">بررسی</span>
                            </button>
                        </li>
                        <li>
                            <button type="button" data-tld=".net">
                                <i></i>
                                <span class="dp-domain-results__name" dir="ltr">mybrand.net</span>
                                <span class="dp-domain-results__price">از ۵۹۰ هزار تومان</span>
                                <span class="dp-domain-results__act">بررسی</span>
                            </button>
                        </li>
                    </ul>
                </form>
            </div>
        </div>
        <div class="dp-container dp-hero__uptime" aria-label="آپتایم ۹۹.۹۹٪ در ۱۲ ماه گذشته">
            <div class="dp-hero__ticks" aria-hidden="true">
                {for $i=1 to 96}<i{if $i==22 || $i==51 || $i==77} class="is-hit"{/if}></i>{/for}
            </div>
            <span class="dp-hero__uptime-label">۹۹.۹۹٪ آپتایم در ۱۲ ماه گذشته</span>
        </div>
    </section>

    {* ================= 1b. POPULAR PLANS ================= *}
    <section class="dp-section dpp-sec" id="plans" data-dp-plans>
        <div class="dp-container">
            <header class="dpp-head">
                <div class="dpp-head__text">
                    <h2 class="dpp-head__title">سرویس‌های منتخب میزبانی</h2>
                    <p class="dpp-head__sub">پرفروش‌ترین پیکربندی‌ها با امکان ارتقای آنی منابع بدون قطعی سرویس.</p>
                </div>
                <div class="dpp-head__tools">
                    <div class="dpp-seg" role="tablist" aria-label="نوع سرویس">
                        <button type="button" role="tab" class="is-active" aria-selected="true" data-dp-seg="hosting">هاست</button>
                        <button type="button" role="tab" aria-selected="false" data-dp-seg="vps">VPS</button>
                    </div>
                    <div class="dpp-billing">
                        <span class="dpp-billing__label">ماهانه / سالانه</span>
                        <button type="button" class="dpp-switch" role="switch" aria-checked="false" aria-label="پرداخت سالانه" data-dp-billing><i></i></button>
                    </div>
                </div>
            </header>
        </div>
        <div class="dpp-viewport">
            <div class="dpp-track" data-dp-plans-track>
                {foreach $dpPlans as $plan}
                    <article class="dpp-card{if $plan.featured && $plan.cat == 'hosting'} is-active{/if}" data-dp-plan data-cat="{$plan.cat}" data-price="{$plan.price}"{if $plan.featured} data-featured="1"{/if}{if $plan.cat != 'hosting'} hidden{/if}>
                        <div class="dpp-card__top">
                            <h3 class="dpp-card__name">{$plan.name}</h3>
                            {if $plan.featured}<span class="dpp-card__badge">پرفروش‌ترین</span>{/if}
                        </div>
                        <p class="dpp-card__big"><b>{$plan.num}</b><span>{$plan.unit}</span></p>
                        <p class="dpp-card__label">{$plan.label}</p>
                        <div class="dpp-card__ticks" aria-hidden="true">
                            {for $t=1 to 20}<i{if $t <= $plan.fill} class="is-on"{/if}></i>{/for}
                        </div>
                        <ul class="dpp-card__list">
                            {foreach $plan.features as $f}<li>{$f}</li>{/foreach}
                        </ul>
                        <div class="dpp-card__buy">
                            <p class="dpp-card__price">
                                <del class="dpp-card__old" data-dp-old>{$plan.priceText}</del>
                                <strong data-dp-price>{$plan.priceText} تومان</strong>
                                <span data-dp-period>در ماه</span>
                            </p>
                            <a class="dp-btn dpp-card__cta" href="{$plan.url}" data-dp-cta>انتخاب سرویس</a>
                        </div>
                    </article>
                {/foreach}
            </div>
        </div>
        <div class="dp-container">
            <div class="dpp-foot">
                <div class="dpp-arrows">
                    <button type="button" class="dpp-arrow" data-dp-plans-prev aria-label="پلن قبلی"><i class="fas fa-chevron-right" aria-hidden="true"></i></button>
                    <button type="button" class="dpp-arrow" data-dp-plans-next aria-label="پلن بعدی"><i class="fas fa-chevron-left" aria-hidden="true"></i></button>
                </div>
                <div class="dpp-progress" aria-hidden="true"><span class="dpp-progress__bar" data-dp-plans-bar></span></div>
                <a class="dpp-foot__link" href="{$dpStoreUrl}">مقایسه همه پلن‌ها</a>
            </div>
        </div>
    </section>

    {* ================= 2. STATS (odometer) + TECH ================= *}
    <section class="dp-section dps-sec" id="stats" aria-labelledby="dpsTitle">
        <div class="dp-container">
            <div class="dps-panel">
                <header class="dps-top">
                    <div class="dps-top__text">
                        <h2 class="dps-top__title" id="dpsTitle">کارنامه پایداری و تعهد ما</h2>
                        <p class="dps-top__sub">حاصل بیش از یک دهه میزبانی مطمئن از کسب‌وکارهای آنلاین در سراسر ایران</p>
                    </div>
                    <span class="dps-badge"><i aria-hidden="true"></i>پایش لحظه‌ای</span>
                </header>
                <ul class="dps-grid" data-dp-stats>
                    {foreach $dpStats as $s}
                        <li class="dps-item">
                            <p class="dps-value">
                                <span class="dps-odo" data-dp-odo{if $s.hot} data-hot{/if} aria-hidden="true">{$s.text}</span>
                                {if $s.unit}<span class="dps-unit" aria-hidden="true">{$s.unit}</span>{/if}
                                <span class="sr-only">{$s.sr}</span>
                            </p>
                            <div class="dps-meter" aria-hidden="true">
                                {if $s.meter}{for $t=1 to 56}<i style="--i:{$t}"{if $t == 14 || $t == 38 || $t == 51} class="is-hit"{/if}></i>{/for}{/if}
                            </div>
                            <p class="dps-label"><i class="{$s.icon}" aria-hidden="true"></i>{$s.label}</p>
                        </li>
                    {/foreach}
                </ul>
                <div class="dps-techrow">
                    <p class="dps-techrow__title">بهینه‌شده برای پلتفرم‌ها و ابزارهای استاندارد وب</p>
                    <ul class="dps-tech">
                        {foreach $dpTech as $dpItem}<li>{$dpItem.name}</li>{/foreach}
                    </ul>
                </div>
            </div>
        </div>
    </section>

    {* ================= 3. FEATURES (WHY CHOOSE US) ================= *}
    <section class="dp-section dpf-sec" id="features">
        <div class="dp-container">
            <header class="dpf-head">
                <div class="dpf-head__text">
                    <h2 class="dpf-head__title">مزیت‌های زیرساخت ما</h2>
                    <p class="dpf-head__sub">معماری مهندسی‌شده برای حداکثر سرعت، امنیت و آرامش خاطر شما</p>
                </div>
                <a href="{$WEB_ROOT}/index.php?rp=/store/hstyng" class="dp-btn dp-btn--outline dpf-head__btn">مقایسه پلن‌ها</a>
            </header>
            <div class="dpf-grid">
                {* LEFT COLUMN: Visual Panel *}
                <div class="dpf-visual-col">
                    <div class="dpf-panel">
                        <div class="dpf-panel__img" style="background-image:url('{$dpFeaturesImg}')" aria-hidden="true"></div>
                        <div class="dpf-chip" aria-hidden="true">
                            <div class="dpf-chip__top">
                                <i></i><span id="dpfActiveLabel">NVMe SSD</span>
                            </div>
                            <div class="dpf-chip__barcode">
                                {for $t=1 to 20}<i{if $t==3 || $t==8 || $t==12 || $t==15 || $t==18 || $t==19} class="is-hit"{/if}></i>{/for}
                            </div>
                        </div>
                    </div>
                </div>
                {* RIGHT COLUMN: Accordion List *}
                <div class="dpf-list-col">
                    <div class="dpf-list" data-dp-features>
                        {foreach $dpFeaturesV2 as $idx => $item}
                            <article class="dpf-item{if $idx == 0} is-active{/if}" data-chip="{$item.chip}">
                                <button type="button" class="dpf-item__trigger" aria-expanded="{if $idx == 0}true{else}false{/if}">
                                    <div class="dpf-item__right">
                                        <i class="dpf-item__dot" aria-hidden="true"></i>
                                        <h3 class="dpf-item__title">{$item.title}</h3>
                                    </div>
                                    <div class="dpf-item__left">
                                        <span class="dpf-item__badge">{$item.chip}</span>
                                        <span class="dpf-action" aria-hidden="true"></span>
                                    </div>
                                </button>
                                <div class="dpf-item__body" aria-hidden="{if $idx == 0}false{else}true{/if}">
                                    <div class="dpf-item__inner">
                                        <p class="dpf-item__text">{$item.text}</p>
                                    </div>
                                </div>
                            </article>
                        {/foreach}
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* ================= 4. DOMAIN PROMOTION =================*}
    {assign var="dpPromoTlds" value=[".com", ".ir", ".net", ".org", ".co"]}
    <section class="dp-section dpd-sec" id="domains">
        <div class="dp-container">
            <div class="dp-promo dpd-panel">
                <div class="dp-promo__content">
                    <p class="dpd-eyebrow"><i class="fas fa-globe" aria-hidden="true"></i> ثبت و انتقال دامنه</p>
                    <h2 class="dp-promo__title">نام تجاری خود را در وب ماندگار کنید</h2>
                    <p class="dp-promo__text">پیش از دیگران، دامنه اختصاصی برندتان را با مالکیت کامل قانونی به نام خود ثبت کنید.</p>
                    <form class="dp-domain-form dp-domain-form--light" method="post" action="{$WEB_ROOT}/domainchecker.php" data-dp-domain-form novalidate>
                        <input type="hidden" name="token" value="{$token}">
                        <input type="hidden" name="domain" value="" data-dp-domain-value>
                        <div class="dp-domain-form__box">
                            <label class="sr-only" for="dpPromoTld">پسوند دامنه</label>
                            <select class="dp-domain-form__tld" id="dpPromoTld" data-dp-domain-tld>
                                {foreach $dpPromoTlds as $t}<option value="{$t}">{$t}</option>{/foreach}
                            </select>
                            <label class="sr-only" for="dpPromoDomain">نام دامنه</label>
                            <input class="dp-domain-form__input" type="text" id="dpPromoDomain" placeholder="mybrand" autocomplete="off" spellcheck="false" dir="ltr" data-dp-domain-name>
                            <button class="dp-btn dp-btn--primary dp-domain-form__submit" type="submit" data-dp-domain-submit>
                                <span data-dp-domain-label>جستجو</span>
                            </button>
                        </div>
                        <p class="dp-domain-form__msg" role="alert" data-dp-domain-msg hidden></p>
                    </form>
                    <div class="dpd-foot">
                        <ul class="dpd-tlds" data-dpd-tlds aria-label="پسوندهای پرطرفدار">
                            {foreach $dpPromoTlds as $t}
                                <li><button type="button" class="dpd-tld{if $t@first} is-active{/if}" data-tld="{$t}">{$t}</button></li>
                            {/foreach}
                        </ul>
                        <a class="dp-link dpd-transfer" href="{$WEB_ROOT}/cart.php?a=add&amp;domain=transfer">
                            انتقال دامنه از سایر شرکت‌ها <i class="fas fa-arrow-left" aria-hidden="true"></i>
                        </a>
                    </div>
                </div>
                <div class="dp-promo__visual" aria-hidden="true">
                    <span class="dpd-orbit dpd-orbit--1"></span>
                    <span class="dpd-orbit dpd-orbit--2"></span>
                    <span class="dp-promo__globe"><i class="fas fa-globe"></i></span>
                    <span class="dp-promo__www">WWW</span>
                </div>
            </div>
        </div>
    </section>

    {* ================= 5. DASHBOARD SHOWCASE + BENEFITS ================= *}
    <section class="dp-section dpm-sec" id="panel" data-dp-showcase>
        <div class="dp-container dpm-grid">
            <div class="dpm-content">
                <h2 class="dpm-title">مدیریت متمرکز، کنترل کامل</h2>
                <p class="dpm-sub">سرورها، دامنه‌ها و سرویس‌های میزبانی خود را از یک پنل یکپارچه و قدرتمند مدیریت کنید.</p>
                <ul class="dpm-benefits">
                    {foreach $dpBenefits as $benefit}
                        <li><i class="dpm-dot" aria-hidden="true"></i><span>{$benefit}</span></li>
                    {/foreach}
                </ul>
                <a class="dpm-link" href="{$WEB_ROOT}/clientarea.php">
                    ورود به ناحیه کاربری <i class="fas fa-arrow-left" aria-hidden="true"></i>
                </a>
            </div>
            <div class="dpm-window" aria-hidden="true">
                <div class="dpm-window__bar">
                    <span class="dpm-window__dots"><i></i><i></i><i></i></span>
                    <span class="dpm-window__live"><i></i>آنلاین</span>
                </div>
                <div class="dpm-window__body">
                    <div class="dpm-tiles">
                        <div class="dpm-tile"><span class="dpm-tile__label">سرویس‌های فعال</span><span class="dpm-tile__value">۴</span></div>
                        <div class="dpm-tile"><span class="dpm-tile__label">دامنه‌های ثبت‌شده</span><span class="dpm-tile__value">۷</span></div>
                    </div>
                    <div class="dpm-meters">
                        <div class="dpm-meter" style="--i:0">
                            <span class="dpm-meter__top"><span>مصرف CPU</span><b>۳۲٪</b></span>
                            <span class="dpm-meter__track"><span class="dpm-meter__fill" style="--w:32%"></span></span>
                        </div>
                        <div class="dpm-meter" style="--i:1">
                            <span class="dpm-meter__top"><span>حافظه رم</span><b>۵۴٪</b></span>
                            <span class="dpm-meter__track"><span class="dpm-meter__fill" style="--w:54%"></span></span>
                        </div>
                        <div class="dpm-meter" style="--i:2">
                            <span class="dpm-meter__top"><span>فضای دیسک</span><b>۱۸٪</b></span>
                            <span class="dpm-meter__track"><span class="dpm-meter__fill" style="--w:18%"></span></span>
                        </div>
                    </div>
                    <p class="dpm-caption">گزارش وضعیت خودکار</p>
                    <ul class="dpm-log">
                        <li><i></i><span>بکاپ روزانه با موفقیت ذخیره شد</span></li>
                        <li><i></i><span>گواهی امنیتی SSL تمدید شد</span></li>
                        <li><i></i><span>رکوردهای DNS دامنه جدید فعال شد</span></li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    {* ================= 6. TESTIMONIALS ================= *}
    <section class="dp-section dpq-sec" id="testimonials">
        <div class="dpq-band">
            <div class="dp-container">
                <header class="dpq-head">
                    <h2 class="dpq-head__title">دیدگاه مشتریان دیتاهتلینگ</h2>
                    <p class="dpq-head__sub">تجربه کسب‌وکارهایی که میزبانی زیرساخت خود را به ما سپرده‌اند</p>
                </header>
            </div>
            <div class="dpq-marquee" data-dp-testimonials aria-label="نظرات مشتریان">
                <div class="dpq-track">
                    {foreach [1,2,3,4] as $dpLoop}
                        {foreach $dpTestimonials as $item}
                            <figure class="dpq-card{if $item@iteration == 2} dpq-card--hot{/if}"{if $dpLoop > 1} aria-hidden="true"{/if}>
                                <div class="dpq-card__rate" role="img" aria-label="امتیاز ۵ از ۵">
                                    <i></i><i></i><i></i><i></i><i></i>
                                </div>
                                <blockquote class="dpq-card__quote">{$item.quote}</blockquote>
                                <figcaption class="dpq-card__author">
                                    <span class="dpq-card__avatar" aria-hidden="true">{$item.name|truncate:1:""}</span>
                                    <span>
                                        <span class="dpq-card__name">{$item.name}</span>
                                        <span class="dpq-card__role">{$item.role}</span>
                                    </span>
                                </figcaption>
                            </figure>
                        {/foreach}
                    {/foreach}
                </div>
            </div>
        </div>
    </section>
</main>
{include file="$template/includes/mascot.tpl"}