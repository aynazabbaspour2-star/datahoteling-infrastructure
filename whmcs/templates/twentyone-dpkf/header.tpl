<!doctype html>
<html lang="fa" dir="rtl">
<head>
<meta charset="{$charset}" />
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<meta name="description" content="دیتاهتلینگ؛ ارائه‌دهنده هاست پرسرعت، VPS و خدمات میزبانی وب با زیرساخت پایدار، امنیت بالا و پشتیبانی تخصصی.">
<meta property="og:type" content="website">
<meta property="og:locale" content="fa_IR">
<meta property="og:site_name" content="دیتاهتلینگ">
<meta property="og:title" content="دیتاهتلینگ | هاستینگ مطمئن و پرسرعت">
<meta property="og:description" content="دیتاهتلینگ؛ ارائه‌دهنده هاست پرسرعت، VPS و خدمات میزبانی وب با زیرساخت پایدار، امنیت بالا و پشتیبانی تخصصی.">
<meta property="og:url" content="https://datahoteling.com{$smarty.server.REQUEST_URI}">
<meta property="og:image" content="https://datahoteling.com/templates/twentyone-dpkf/img/headerbg.webp">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="دیتاهتلینگ | هاستینگ مطمئن و پرسرعت">
<meta name="twitter:description" content="دیتاهتلینگ؛ ارائه‌دهنده هاست پرسرعت، VPS و خدمات میزبانی وب با زیرساخت پایدار، امنیت بالا و پشتیبانی تخصصی.">
<meta name="twitter:image" content="https://datahoteling.com/templates/twentyone-dpkf/img/headerbg.webp">
<link rel="canonical" href="https://datahoteling.com{$smarty.server.REQUEST_URI}" />
<link rel="icon" href="/favicon.ico?v=4" sizes="32x32">
<link rel="icon" href="/templates/{$template}/img/favicon/favicon.svg?v=4" type="image/svg+xml">
<link rel="apple-touch-icon" href="/templates/{$template}/img/favicon/apple-touch-icon.png?v=4">
<link rel="manifest" href="/templates/{$template}/img/favicon/site.webmanifest?v=4">
<meta name="theme-color" content="#0A1D18">

<title>دیتاهتلینگ | هاستینگ مطمئن و پرسرعت</title>
    {include file="$template/includes/head.tpl"}
    {$headoutput}
    {* Vazirmatn webfont (fallback). Estedad is loaded from custom.css via @font-face.
       Self-host Vazirmatn if the CDN is slow/unreachable for Iranian visitors. *}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/rastikerdar/vazirmatn@v33.003/Vazirmatn-font-face.css">
    <link rel="stylesheet" href="/templates/{$template}/css/custom.css?v=20">
    <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "دیتاهتلینگ",
  "url": "https://datahoteling.com/",
  "inLanguage": "fa-IR"
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "دیتاهتلینگ",
  "url": "https://datahoteling.com/",
  "logo": "https://datahoteling.com/templates/twentyone-dpkf/img/logo.webp"
}
</script>
</head>
<!-- DP DEBUG templatefile={$templatefile} -->
<body class="primary-bg-color{if $templatefile == 'homepage'} dp-homepage-body{/if}" data-phone-cc-input="{$phoneNumberInputStyle}">
    {if $captcha}{$captcha->getMarkup()}{/if}
    {if false}
        {$headeroutput}
    {/if}

    {* ------------------------------------------------------------------
       Marketing header (all pages). Styling for #header.dp-header lives in
       custom.css. On the homepage it is transparent over the hero and turns
       into dark glass after scrolling.
       ------------------------------------------------------------------ *}
{assign var="dpNavItems" value=[
    ["label" => "هاستینگ", "url" => "/index.php?rp=/store/hstyng"],
    ["label" => "VPS", "url" => "/cart.php?a=add&pid=9"],
    ["label" => "دامنه", "url" => "/cart.php?a=add&domain=register"],
    ["label" => "وبلاگ", "url" => "{$WEB_ROOT}/announcements.php"],
    ["label" => "پشتیبانی", "url" => "{$WEB_ROOT}/submitticket.php"]
]}

    <a class="dp-skip-link" href="#dpMain">پرش به محتوای اصلی</a>

    <header id="header" class="dp-header" data-dp-header>
        <div class="dp-container dp-header__inner">
            <a class="dp-brand" href="{$WEB_ROOT}/index.php" aria-label="دیتاهتلینگ">
                <img class="dp-brand__logo" src="/templates/{$template}/img/favicon/dh-mark.svg" alt="" width="34" height="38">
                <span class="dp-brand__name">دیتاهتلینگ<i class="dp-brand__dot" aria-hidden="true"></i></span>
            </a>

            <nav class="dp-nav" aria-label="منوی اصلی">
                <ul class="dp-nav__list">
                    {foreach $dpNavItems as $dpItem}
                        <li class="dp-nav__item">
                            <a class="dp-nav__link" href="{$dpItem.url}" data-label="{$dpItem.label}"><span>{$dpItem.label}</span></a>
                        </li>
                    {/foreach}
                </ul>
            </nav>

            <div class="dp-header__actions">
                <button type="button" class="dp-icon-btn" data-dp-search-toggle
                        aria-controls="dpHeaderSearch" aria-expanded="false">
                    <i class="fas fa-search" aria-hidden="true"></i>
                    <span class="sr-only">جستجو</span>
                </button>

                <a class="dp-icon-btn" href="{$WEB_ROOT}/cart.php?a=view">
                    <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                    <span class="dp-icon-btn__badge" id="cartItemCount">{$cartitemcount}</span>
                    <span class="sr-only">سبد خرید</span>
                </a>

                {if $loggedin}
                    <a class="dp-btn dp-btn--primary dp-btn--sm dp-header__cta" href="{$WEB_ROOT}/clientarea.php">ناحیه کاربری</a>
                {else}
                    <a class="dp-btn dp-btn--primary dp-btn--sm dp-header__cta" href="{$WEB_ROOT}/login.php">ورود / ثبت‌نام</a>
                {/if}

                <button type="button" class="dp-icon-btn dp-header__burger" data-dp-menu-open
                        aria-controls="dpMobileMenu" aria-expanded="false">
                    <i class="fas fa-bars" aria-hidden="true"></i>
                    <span class="sr-only">منو</span>
                </button>
            </div>
        </div>

        <div class="dp-header__search" id="dpHeaderSearch" hidden>
            <div class="dp-container">
                <form method="post" action="{routePath('knowledgebase-search')}" class="dp-header__search-form">
                    <label class="sr-only" for="dpKbSearch">جستجو در پایگاه دانش</label>
                    <input class="dp-input" type="text" id="dpKbSearch" name="search" placeholder="در پایگاه دانش جستجو کنید...">
                    <button class="dp-btn dp-btn--primary" type="submit">جستجو</button>
                </form>
            </div>
        </div>
    </header>

    <div class="dp-drawer" id="dpMobileMenu" aria-hidden="true">
        <div class="dp-drawer__backdrop" data-dp-menu-close></div>
        <div class="dp-drawer__panel" role="dialog" aria-modal="true" aria-label="منوی موبایل">
            <div class="dp-drawer__head">
                <span class="dp-drawer__title">منو</span>
                <button type="button" class="dp-icon-btn dp-icon-btn--dark" data-dp-menu-close>
                    <i class="fas fa-times" aria-hidden="true"></i>
                    <span class="sr-only">بستن منو</span>
                </button>
            </div>
            <nav aria-label="منوی موبایل">
                <ul class="dp-drawer__list">
                    {foreach $dpNavItems as $dpItem}
                        <li>
                            <a href="{$dpItem.url}">
                                <span>{$dpItem.label}</span>
                                <i class="fas fa-chevron-left" aria-hidden="true"></i>
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </nav>
            <div class="dp-drawer__foot">
                {if $loggedin}
                    <a class="dp-btn dp-btn--primary dp-btn--block" href="{$WEB_ROOT}/clientarea.php">ناحیه کاربری</a>
                    <a class="dp-btn dp-btn--outline dp-btn--block" href="{$WEB_ROOT}/logout.php">خروج</a>
                {else}
                    <a class="dp-btn dp-btn--primary dp-btn--block" href="{$WEB_ROOT}/login.php">ورود</a>
                    <a class="dp-btn dp-btn--outline dp-btn--block" href="{$WEB_ROOT}/register.php">ثبت‌نام</a>
                {/if}
            </div>
        </div>
    </div>


    {include file="$template/includes/network-issues-notifications.tpl"}


    <div class="dp-system-alerts">
        <div class="dp-container">
            {include file="$template/includes/validateuser.tpl"}
            {include file="$template/includes/verifyemail.tpl"}
        </div>
    </div>

            <div class="row">

            {if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}
                <div class="col-lg-4 col-xl-3">
                    <div class="sidebar">
                        {include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}
                    </div>
                    {if !$inShoppingCart && $secondarySidebar->hasChildren()}
                        <div class="d-none d-lg-block sidebar">
                            {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                        </div>
                    {/if}
                </div>
            {/if}
            <div class="{if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}col-lg-8 col-xl-9{else}col-12{/if} primary-content">
