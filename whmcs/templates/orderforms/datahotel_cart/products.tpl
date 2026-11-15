{include file="orderforms/datahotel_cart/common.tpl"}

{assign var="dpoHeroImg" value="/templates/{$template}/img/hero-slabs.webp"}

{assign var="dpoBenefits" value=[
    ["icon" => "fas fa-bolt",        "title" => "سرعت بالا",        "text" => "زیرساخت بهینه برای بارگذاری سریع‌تر سایت و تجربه بهتر کاربران."],
    ["icon" => "fas fa-shield-alt",  "title" => "امنیت",            "text" => "معماری امن و مانیتورینگ دائمی برای محافظت بهتر از اطلاعات شما."],
    ["icon" => "fas fa-headset",     "title" => "پشتیبانی تخصصی",   "text" => "در مسیر راه‌اندازی و مدیریت سرویس، تیم پشتیبانی همراه شماست."],
    ["icon" => "fas fa-tachometer-alt", "title" => "پایداری سرویس", "text" => "منابع و زیرساخت مناسب برای اجرای پایدار پروژه‌های شما."],
    ["icon" => "fas fa-expand-arrows-alt", "title" => "قابل ارتقا", "text" => "با رشد پروژه، سرویس خود را به پلن بالاتر ارتقا دهید."],
    ["icon" => "fas fa-clock",       "title" => "فعال‌سازی سریع",   "text" => "پس از ثبت سفارش، سرویس در سریع‌ترین زمان ممکن آماده می‌شود."]
]}

{assign var="dpoSteps" value=[
    ["title" => "نوع پروژه را مشخص کنید",     "text" => "سایت شرکتی، فروشگاهی، شخصی یا پروژه حرفه‌ای"],
    ["title" => "منابع موردنیاز را بررسی کنید", "text" => "فضا، ترافیک، CPU، RAM و تعداد سایت‌ها"],
    ["title" => "پلن مناسب را انتخاب کنید",    "text" => "هر زمان نیاز داشتید امکان ارتقا وجود دارد"]
]}

{assign var="dpoFaq" value=[
    ["q" => "چطور پلن مناسب خودم را انتخاب کنم؟", "a" => "اگر سایت تازه راه‌اندازی می‌کنید، از پلن پایه شروع کنید. برای سایت‌های پرترافیک یا فروشگاهی بهتر است پلنی با منابع بیشتر انتخاب شود."],
    ["q" => "آیا بعداً می‌توانم پلن را ارتقا دهم؟", "a" => "بله، در صورت افزایش نیاز پروژه می‌توانید سرویس خود را به پلن بالاتر ارتقا دهید."],
    ["q" => "فعال‌سازی سرویس چقدر زمان می‌برد؟", "a" => "پس از تکمیل سفارش و پرداخت، سرویس شما به‌صورت خودکار و در کوتاه‌ترین زمان فعال می‌شود."],
    ["q" => "قیمت‌ها شامل چه مواردی هستند؟", "a" => "قیمت هر پلن بر اساس دوره‌ی پرداخت نمایش داده می‌شود. هزینه‌ی راه‌اندازی (در صورت وجود) زیر قیمت اعلام شده است."]
]}

<script>document.body.classList.add("dpo-body");</script>
<div id="order-standard_cart" class="dpo-page">

    {* ================= HERO ================= *}
    <section class="dpo-hero">
        <div class="dpo-hero__grain" aria-hidden="true"></div>
        <div class="dpo-hero__object" style="background-image:url('{$dpoHeroImg}')" aria-hidden="true"></div>

        <div class="dpo-in dpo-hero__inner"><div class="dpo-hero__content">
            <p class="dpo-eyebrow"><i class="fas fa-cloud" aria-hidden="true"></i> {if $productGroup.name}{$productGroup.name}{else}هاستینگ دیتاهتلینگ{/if}</p>
            <h1 class="dpo-hero__title">هاست مناسب<br>کسب‌وکار شما.</h1>
            <p class="dpo-hero__text">از یک وب‌سایت شخصی تا فروشگاه و پروژه‌های حرفه‌ای؛ پلن مناسب خود را انتخاب کنید و با زیرساختی سریع، پایدار و امن شروع کنید.</p>

            <div class="dpo-hero__actions">
                <a href="#hosting-plans" class="dp-btn dp-btn--primary dp-btn--lg">مشاهده پلن‌ها <i class="fas fa-arrow-down" aria-hidden="true"></i></a>
                <a href="#hosting-faq" class="dpo-link-ghost">سوالی دارید؟</a>
            </div>

            <ul class="dpo-hero__trust">
                <li><i class="fas fa-shield-alt" aria-hidden="true"></i> زیرساخت پایدار</li>
                <li><i class="fas fa-bolt" aria-hidden="true"></i> سرعت بالا</li>
                <li><i class="fas fa-headset" aria-hidden="true"></i> پشتیبانی تخصصی</li>
            </ul>
        </div></div>
    </section>

    {* ================= ERRORS / CATEGORY SWITCH ================= *}
    {if $errormessage || !$productGroup}
        <div class="dpo-in dpo-alerts">
            {if $errormessage}
                <div class="alert alert-danger dpo-alert">{$errormessage}</div>
            {elseif !$productGroup}
                <div class="alert alert-info dpo-alert">{lang key='orderForm.selectCategory'}</div>
            {/if}
        </div>
    {/if}
    <div class="dpo-in dpo-categories">
        {include file="orderforms/standard_cart/sidebar-categories-collapsed.tpl"}
    </div>

    {* ================= PLANS ================= *}
    <section class="dpo-sec dpo-plans" id="hosting-plans">
        <div class="dpo-in">
        <header class="dpo-head">
            <p class="dpo-kicker">پلن‌های میزبانی</p>
            <h2 class="dpo-head__title">پلن مناسب خودتان را انتخاب کنید</h2>
            <p class="dpo-head__sub">قیمت‌ها و امکانات هر پلن را مقایسه کنید؛ هر زمان نیاز داشتید می‌توانید ارتقا دهید.</p>
        </header>

        <div class="products dpo-grid" id="products">
            {foreach $products as $key => $product}
                {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}

                <article class="dpo-plan{if $product@iteration == 2} dpo-plan--featured{/if}" id="{$idPrefix}">

                    <div class="dpo-plan__top">
                        <div class="dpo-plan__id">
                            <span class="dpo-plan__icon">
                                {if $product@iteration == 1}<i class="fas fa-seedling" aria-hidden="true"></i>
                                {elseif $product@iteration == 2}<i class="fas fa-rocket" aria-hidden="true"></i>
                                {elseif $product@iteration == 3}<i class="fas fa-crown" aria-hidden="true"></i>
                                {else}<i class="fas fa-server" aria-hidden="true"></i>{/if}
                            </span>
                            <div>
                                <h3 class="dpo-plan__name" id="{$idPrefix}-name">{$product.name}</h3>
                                <p class="dpo-plan__stock">
                                    {if $product.stockControlEnabled}{$product.qty} {$LANG.orderavailable}{else}آماده فعال‌سازی{/if}
                                </p>
                            </div>
                        </div>
                        {if $product@iteration == 2}<span class="dpo-plan__badge">پیشنهاد محبوب</span>{/if}
                    </div>

                    {if $product.featuresdesc}
                        <p class="dpo-plan__desc" id="{$idPrefix}-description">{$product.featuresdesc|strip_tags|truncate:130:"…"}</p>
                    {/if}

                    <ul class="dpo-plan__list">
                        {if $product.features|@count > 0}
                            {foreach $product.features as $feature => $value}
                                {if $value@iteration <= 6}
                                    <li id="{$idPrefix}-feature{$value@iteration}">{$feature}{if $value} <b>{$value}</b>{/if}</li>
                                {/if}
                            {/foreach}
                        {else}
                            <li>منابع اختصاصی و پایدار</li>
                            <li>پشتیبانی تخصصی</li>
                            <li>فعال‌سازی سریع</li>
                        {/if}
                    </ul>
                    {if $product.features|@count > 6}
                        <details class="dpo-plan__more">
                            <summary>+ {$product.features|@count - 6} امکان دیگر</summary>
                            <ul class="dpo-plan__list dpo-plan__list--extra">
                                {foreach $product.features as $feature => $value}
                                    {if $value@iteration > 6}
                                        <li id="{$idPrefix}-feature{$value@iteration}">{$feature}{if $value} <b>{$value}</b>{/if}</li>
                                    {/if}
                                {/foreach}
                            </ul>
                        </details>
                    {/if}

                    <div class="dpo-plan__buy">
                        <div class="dpo-plan__price product-pricing" id="{$idPrefix}-price">
                            {if $product.bid}
                                <span class="dpo-plan__from">قیمت بسته</span>
                                <p class="dpo-plan__amount">
                                    {if $product.displayprice}<strong>{$product.displayprice}</strong>{/if}
                                    <span>{$LANG.bundledeal}</span>
                                </p>
                            {else}
                                <span class="dpo-plan__from">{if $product.pricing.hasconfigoptions}{$LANG.startingfrom}{else}شروع قیمت از{/if}</span>
                                <p class="dpo-plan__amount">
                                    <strong>{$product.pricing.minprice.price}</strong>
                                    <span>
                                        {if $product.pricing.minprice.cycle eq "monthly"}{$LANG.orderpaymenttermmonthly}
                                        {elseif $product.pricing.minprice.cycle eq "quarterly"}{$LANG.orderpaymenttermquarterly}
                                        {elseif $product.pricing.minprice.cycle eq "semiannually"}{$LANG.orderpaymenttermsemiannually}
                                        {elseif $product.pricing.minprice.cycle eq "annually"}{$LANG.orderpaymenttermannually}
                                        {elseif $product.pricing.minprice.cycle eq "biennially"}{$LANG.orderpaymenttermbiennially}
                                        {elseif $product.pricing.minprice.cycle eq "triennially"}{$LANG.orderpaymenttermtriennially}{/if}
                                    </span>
                                </p>
                                {if $product.pricing.minprice.setupFee}
                                    <small class="dpo-plan__setup">{$product.pricing.minprice.setupFee->toPrefixed()} {$LANG.ordersetupfee}</small>
                                {/if}
                            {/if}
                        </div>

                        <a href="{if $product.pid == 9}/vps-configure.php{else}{$product.productUrl}{/if}"
                           class="dp-btn dpo-plan__cta btn-order-now"
                           id="{$idPrefix}-order-button"
                           {if $product.hasRecommendations}data-has-recommendations="1"{/if}>
                            انتخاب این پلن <i class="fas fa-arrow-left" aria-hidden="true"></i>
                        </a>
                    </div>
                </article>
            {/foreach}
        </div>
        </div>
    </section>

    {* ================= BENEFITS ================= *}
    <section class="dpo-sec dpo-benefits">
        <div class="dpo-in">
        <header class="dpo-head">
            <p class="dpo-kicker">چرا دیتاهتلینگ؟</p>
            <h2 class="dpo-head__title">بیشتر از یک هاست معمولی</h2>
            <p class="dpo-head__sub">زیرساختی که برای سریع، پایدار و آماده‌ی رشد بودن سایت شما طراحی شده است.</p>
        </header>

        <ul class="dpo-benefits__grid">
            {foreach $dpoBenefits as $b}
                <li class="dpo-benefit">
                    <span class="dpo-benefit__icon"><i class="{$b.icon}" aria-hidden="true"></i></span>
                    <h3>{$b.title}</h3>
                    <p>{$b.text}</p>
                </li>
            {/foreach}
        </ul>
        </div>
    </section>

    {* ================= HOW TO CHOOSE ================= *}
    <section class="dpo-sec dpo-choose">
        <div class="dpo-in">
        <div class="dpo-choose__panel">
            <div class="dpo-choose__text">
                <p class="dpo-kicker dpo-kicker--dark">انتخاب ساده‌تر</p>
                <h2>نمی‌دانید کدام پلن مناسب شماست؟</h2>
                <p>نیازهای سایت، میزان بازدید و منابع موردنیاز را در نظر بگیرید یا قبل از خرید با پشتیبانی مشورت کنید.</p>
                <a href="/contact" class="dp-btn dp-btn--primary dp-btn--lg">مشاوره با پشتیبانی <i class="fas fa-arrow-left" aria-hidden="true"></i></a>
            </div>

            <ol class="dpo-steps">
                {foreach $dpoSteps as $s}
                    <li class="dpo-step">
                        <b>{$s@iteration}</b>
                        <div><strong>{$s.title}</strong><small>{$s.text}</small></div>
                    </li>
                {/foreach}
            </ol>
        </div>
        </div>
    </section>

    {* ================= FAQ ================= *}
    <section class="dpo-sec dpo-faq" id="hosting-faq">
        <div class="dpo-in">
        <div class="dpo-faq__grid">
            <header class="dpo-faq__head">
                <p class="dpo-kicker">سوالات متداول</p>
                <h2 class="dpo-head__title">قبل از خرید بدانید</h2>
                <p class="dpo-head__sub">پاسخ پرسش‌های رایج درباره‌ی سرویس‌های هاستینگ.</p>
                <a href="/contact" class="dpo-link">سوال دیگری دارید؟ <i class="fas fa-arrow-left" aria-hidden="true"></i></a>
            </header>

            <div class="dpo-faq__list">
                {foreach $dpoFaq as $f}
                    <details class="dpo-faq__item"{if $f@first} open{/if}>
                        <summary><span>{$f.q}</span><i class="dpo-faq__icon" aria-hidden="true"></i></summary>
                        <p>{$f.a}</p>
                    </details>
                {/foreach}
            </div>
        </div>
        </div>
    </section>

    {* ================= FINAL CTA (same component as the homepage) ================= *}
    <section class="dpc-sec dpo-cta">
        <div class="dpo-in"><div class="dpc-panel">
            <div class="dpc-panel__grain" aria-hidden="true"></div>
            <div class="dpc-content">
                <h2 class="dpc-title">آماده‌ی شروع هستید؟</h2>
                <p class="dpc-desc">وب‌سایت خود را روی زیرساخت دیتاهتلینگ اجرا کنید؛ پلن مناسب را انتخاب کنید و همین امروز شروع کنید.</p>
                <div class="dpc-actions">
                    <a class="dp-btn dp-btn--primary dp-btn--lg dpc-btn" href="#hosting-plans">مشاهده پلن‌ها <i class="fas fa-arrow-left" aria-hidden="true"></i></a>
                    <a class="dpc-btn--outline" href="/contact">تماس با ما</a>
                </div>
            </div>
            <div class="dpc-visual" aria-hidden="true">
                <div class="dpc-lines"><i></i><i></i><i></i></div>
                <div class="dpc-circle"></div>
            </div>
        </div></div>
    </section>

</div>

{include file="orderforms/standard_cart/recommendations-modal.tpl"}
