<div class="dh-blog-page">

    {* =========================
       BLOG HERO
       ========================= *}
    <section class="dh-blog-hero">
        <div class="dh-blog-hero__glow dh-blog-hero__glow--one"></div>
        <div class="dh-blog-hero__glow dh-blog-hero__glow--two"></div>

        <div class="dh-blog-hero__inner">

            <div class="dh-blog-hero__badge">
                <span class="dh-blog-hero__badge-dot"></span>
                مجله دیتاهتلینگ
            </div>

            <h1 class="dh-blog-hero__title">
                دنیای <span>هاستینگ</span> را بهتر بشناسید
            </h1>

            <p class="dh-blog-hero__text">
                آموزش‌ها، راهنماها و مطالب کاربردی درباره هاست، سرور،
                وردپرس، امنیت و دنیای زیرساخت وب.
            </p>

            <div class="dh-blog-hero__stats">
                <div class="dh-blog-stat">
                    <strong>{$announcements|@count}</strong>
                    <span>مقاله منتشر شده</span>
                </div>

                <div class="dh-blog-stat__divider"></div>

                <div class="dh-blog-stat">
                    <strong>24/7</strong>
                    <span>دسترسی به زیرساخت</span>
                </div>

                <div class="dh-blog-stat__divider"></div>

                <div class="dh-blog-stat">
                    <strong>Datahoteling</strong>
                    <span>همراه کسب‌وکار شما</span>
                </div>
            </div>

        </div>
    </section>


    {* =========================
       BLOG CONTENT
       ========================= *}
    <section class="dh-blog-content">

        <div class="dh-blog-heading">
            <div>
                <span class="dh-blog-heading__eyebrow">آخرین مطالب</span>
                <h2>از دیتاهتلینگ بیشتر بدانید</h2>
            </div>

            <p>
                مطالبی که به شما کمک می‌کنند انتخاب بهتر و آگاهانه‌تری
                برای زیرساخت وب‌سایت خود داشته باشید.
            </p>
        </div>


        <div class="dh-blog-grid">

            {foreach $announcements as $announcement}

                <article class="dh-blog-card">

                    <div class="dh-blog-card__top">

                        <div class="dh-blog-card__icon">
                            <i class="fas fa-server"></i>
                        </div>

                        <div class="dh-blog-card__date">
                            <i class="far fa-calendar-alt"></i>
                            {$carbon->createFromTimestamp($announcement.timestamp)->format('Y/m/d')}
                        </div>

                    </div>

                    <div class="dh-blog-card__body">

                        <h2 class="dh-blog-card__title">
                            <a href="{routePath('announcement-view', $announcement.id, $announcement.urlfriendlytitle)}">
                                {$announcement.title}
                            </a>
                        </h2>

                        <div class="dh-blog-card__excerpt">
                            {if $announcement.text|strip_tags|strlen < 350}
                                {$announcement.text}
                            {else}
                                {$announcement.summary}
                            {/if}
                        </div>

                    </div>

                    <div class="dh-blog-card__footer">

                        <a
                            href="{routePath('announcement-view', $announcement.id, $announcement.urlfriendlytitle)}"
                            class="dh-blog-card__link"
                        >
                            <span>ادامه مطلب</span>
                            <i class="fas fa-arrow-left"></i>
                        </a>

                        {if $announcement.editLink}
                            <a href="{$announcement.editLink}" class="dh-blog-card__edit">
                                <i class="fas fa-pen"></i>
                            </a>
                        {/if}

                    </div>

                </article>

            {foreachelse}

                <div class="dh-blog-empty">
                    <div class="dh-blog-empty__icon">
                        <i class="far fa-newspaper"></i>
                    </div>

                    <h3>هنوز مقاله‌ای منتشر نشده است</h3>

                    <p>
                        به‌زودی مطالب آموزشی و کاربردی دیتاهتلینگ را اینجا منتشر می‌کنیم.
                    </p>
                </div>

            {/foreach}

        </div>


        {* =========================
           PAGINATION
           ========================= *}
        {if $prevpage || $nextpage}

            <nav class="dh-blog-pagination" aria-label="صفحه‌بندی مقالات">

                {foreach $pagination as $item}

                    <a
                        href="{$item.link}"
                        class="dh-blog-pagination__item{if $item.disabled} is-disabled{/if}{if $item.active} is-active{/if}"
                    >
                        {$item.text}
                    </a>

                {/foreach}

            </nav>

        {/if}

    </section>


    {* =========================
       FINAL CTA
       ========================= *}
    <section class="dh-blog-cta">

        <div class="dh-blog-cta__glow"></div>

        <div class="dh-blog-cta__inner">

            <div>
                <span class="dh-blog-cta__eyebrow">
                    زیرساخت مطمئن برای رشد شما
                </span>

                <h2>
                    آماده‌اید سایتتان را<br>
                    حرفه‌ای‌تر میزبانی کنید؟
                </h2>

                <p>
                    هاست سریع، پایدار و امن دیتاهتلینگ را برای پروژه خود انتخاب کنید.
                </p>
            </div>

            <a href="{$WEB_ROOT}/index.php?rp=/store/hstyng" class="dh-blog-cta__button">
                مشاهده پلن‌های هاست
                <i class="fas fa-arrow-left"></i>
            </a>

        </div>

    </section>

</div>
