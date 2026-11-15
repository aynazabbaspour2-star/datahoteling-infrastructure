{* ==========================================================================
   ماسکات هوشمند دیتاهتلینگ — «میزبان حرفه‌ای» (v8.1 - موهای واقع‌گرایانه و لایه‌لایه)
   شامل: موی مردانه با فرق کج و بافت تار مو، کت اسلیم‌فیت متناسب، شمسه ۸ پر و چشم‌های Clip-Path
   ========================================================================== *}

{literal}
<style>
.dpx, .dpx *, .dpx__wake, .dpx__wake * { box-sizing: border-box; }
.dpx [hidden], .dpx__wake[hidden] { display: none !important; }

.dpx {
    --dpx-pine: #0A1D18;
    --dpx-moss: #112A23;
    --dpx-mist: #E9EEEA;
    --dpx-sage: #8FA399;
    --dpx-ember: #F2542D;
    --dpx-line: rgba(233, 238, 234, 0.14);
    --look-x: 0px;
    --look-y: 0px;
    --head-rot: 0deg;

    position: fixed;
    left: 20px;
    bottom: 0;
    z-index: 9990;
    width: 112px;
    direction: rtl;
    pointer-events: none;
    font-family: "Estedad", "Vazirmatn", "IRANYekan", Tahoma, sans-serif;
    user-select: none;
}
.dpx > * { pointer-events: auto; }

/* ---------- استیج و ورود کاراکتر ---------- */
.dpx__stage {
    position: relative;
    opacity: 0;
    visibility: hidden;
    transform: translate3d(-140%, 16px, 0);
    transition:
        transform 0.65s cubic-bezier(0.22, 1, 0.36, 1),
        opacity 0.45s ease,
        visibility 0s linear 0.65s;
}
.dpx.is-in .dpx__stage {
    opacity: 1;
    visibility: visible;
    transform: translate3d(0, 0, 0);
    transition-delay: 0s;
}
.dpx.is-in.is-away .dpx__stage {
    opacity: 0;
    visibility: hidden;
    transform: translate3d(-130%, 24px, 0);
}
.dpx.is-off .dpx__stage,
.dpx.is-off .dpx__bubble {
    display: none !important;
}

/* حذف قطعی هرگونه بوردر، کادر مشکی یا اوت‌لاین در هاور، کلیک و فوکوس */
.dpx__char,
.dpx__char:hover,
.dpx__char:focus,
.dpx__char:focus-visible,
.dpx__char:active {
    position: relative;
    display: block;
    width: 100%;
    padding: 0 !important;
    margin: 0 !important;
    border: 0 !important;
    outline: none !important;
    box-shadow: none !important;
    background: transparent !important;
    cursor: pointer;
    -webkit-tap-highlight-color: transparent;
    transition: transform 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
}
.dpx__char::-moz-focus-inner {
    border: 0 !important;
}
.dpx__char:hover {
    transform: translateY(-3px);
}
.dpx__char:active {
    transform: translateY(0) scale(0.98);
}

.dpx__svg {
    display: block;
    width: 100%;
    height: auto;
    overflow: visible;
    filter: drop-shadow(0 12px 24px rgba(5, 15, 12, 0.65));
}

.dpx__bust { display: none; }

/* نشانگر نوری (Ping) کنار شانه چپ */
.dpx__ping {
    position: absolute;
    top: 22px;
    left: 10px;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: var(--dpx-ember);
    border: 2px solid var(--dpx-pine);
    opacity: 0;
    transform: scale(0);
    pointer-events: none;
    transition: opacity 0.25s ease, transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.dpx.has-unread:not(.is-open) .dpx__ping {
    opacity: 1;
    transform: scale(1);
    animation: dpx-ping-pulse 2.2s infinite;
}
@keyframes dpx-ping-pulse {
    0% { box-shadow: 0 0 0 0 rgba(242, 84, 45, 0.65); }
    70%, 100% { box-shadow: 0 0 0 7px rgba(242, 84, 45, 0); }
}

/* دکمه به خواب بردن مسکات (ظاهر شدن در هاور) */
.dpx__off {
    position: absolute;
    top: 6px;
    right: 0;
    width: 24px;
    height: 24px;
    padding: 0;
    display: grid;
    place-items: center;
    border: 1px solid var(--dpx-line);
    border-radius: 50%;
    background: rgba(10, 29, 24, 0.92);
    backdrop-filter: blur(8px);
    color: var(--dpx-sage);
    font: inherit;
    font-size: 13px;
    line-height: 1;
    cursor: pointer;
    outline: none !important;
    box-shadow: none !important;
    opacity: 0;
    transform: scale(0.8);
    transition: opacity 0.2s ease, transform 0.2s ease, background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}
.dpx__off:hover {
    background: var(--dpx-ember);
    color: var(--dpx-pine);
    border-color: var(--dpx-ember);
}
@media (hover: hover) {
    .dpx__stage:hover .dpx__off,
    .dpx__off:focus-visible {
        opacity: 1;
        transform: scale(1);
    }
}
@media (hover: none) { .dpx__off { display: none; } }

/* ---------- حباب دیالوگ معماری (Architectural Glass HUD) ---------- */
.dpx__bubble {
    position: absolute;
    left: calc(100% + 10px);
    bottom: 78px;
    width: min(320px, calc(100vw - 160px));
    padding: 14px 16px 15px;
    border-radius: 18px;
    background: rgba(17, 42, 35, 0.92);
    border: 1px solid rgba(233, 238, 234, 0.14);
    box-shadow:
        0 24px 50px -16px rgba(4, 12, 10, 0.72),
        inset 0 1px 0 rgba(233, 238, 234, 0.1);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    color: var(--dpx-mist);
    overflow: hidden;
    opacity: 0;
    visibility: hidden;
    transform: translate3d(-12px, 6px, 0) scale(0.96);
    transform-origin: left bottom;
    transition:
        opacity 0.28s ease,
        transform 0.35s cubic-bezier(0.22, 1, 0.36, 1),
        visibility 0s linear 0.28s;
}
.dpx.is-open:not(.is-away) .dpx__bubble {
    opacity: 1;
    visibility: visible;
    transform: translate3d(0, 0, 0) scale(1);
    transition-delay: 0s;
}

.dpx__bhead {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    margin-bottom: 8px;
    padding-bottom: 7px;
    border-bottom: 1px solid rgba(233, 238, 234, 0.08);
}
.dpx__btag {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    font-weight: 700;
    color: var(--dpx-sage);
}
.dpx__btag i {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--dpx-ember);
    box-shadow: 0 0 6px rgba(242, 84, 45, 0.7);
}
.dpx__x {
    width: 22px;
    height: 22px;
    padding: 0;
    display: grid;
    place-items: center;
    border: 1px solid rgba(233, 238, 234, 0.12);
    border-radius: 6px;
    background: rgba(10, 29, 24, 0.5);
    color: var(--dpx-sage);
    font: inherit;
    font-size: 14px;
    line-height: 1;
    cursor: pointer;
    outline: none !important;
    transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}
.dpx__x:hover {
    background: var(--dpx-ember);
    border-color: var(--dpx-ember);
    color: var(--dpx-pine);
}

.dpx__text {
    margin: 0;
    font-size: 13.5px;
    font-weight: 500;
    line-height: 1.85;
    color: var(--dpx-mist);
}

.dpx__bfoot {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-top: 12px;
}
.dpx__cta {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    height: 30px;
    padding-inline: 14px;
    border-radius: 999px;
    background: var(--dpx-ember);
    color: var(--dpx-pine) !important;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none !important;
    outline: none !important;
    transition: background 0.2s ease, transform 0.2s ease;
}
.dpx__cta:hover {
    background: #ff6640;
    transform: translateX(-2px);
}
.dpx__never {
    margin-right: auto;
    padding: 0;
    border: 0;
    background: transparent;
    font: inherit;
    font-size: 11px;
    color: var(--dpx-sage);
    opacity: 0.75;
    cursor: pointer;
    outline: none !important;
    transition: opacity 0.2s ease, color 0.2s ease;
}
.dpx__never:hover {
    opacity: 1;
    color: var(--dpx-mist);
    text-decoration: underline;
    text-underline-offset: 3px;
}

.dpx__timer {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 0;
    height: 2px;
    background: rgba(233, 238, 234, 0.06);
    overflow: hidden;
}
.dpx__timer-bar {
    display: block;
    width: 100%;
    height: 100%;
    background: var(--dpx-ember);
    transform-origin: right center;
    transform: scaleX(0);
}
.dpx.is-open .dpx__timer-bar {
    animation: dpx-countdown 8s linear forwards;
}
.dpx__bubble:hover .dpx__timer-bar {
    animation-play-state: paused;
}
@keyframes dpx-countdown {
    from { transform: scaleX(1); }
    to { transform: scaleX(0); }
}

/* ---------- فیزیک زنده و میکروانیمیشن‌های کاراکتر ---------- */
.dpx .char {
    transform-box: fill-box;
    transform-origin: 50% 100%;
    animation: dpx-breathe 3.8s ease-in-out infinite;
}
.dpx .head-tilt {
    transform-box: fill-box;
    transform-origin: 50% 88%;
    transform: rotate(var(--head-rot, 0deg));
    transition: transform 0.22s ease-out;
}
.dpx .eyes-track {
    transform: translate(var(--look-x, 0px), var(--look-y, 0px));
    transition: transform 0.12s ease-out;
}
.dpx .eye {
    transform-box: fill-box;
    transform-origin: center;
    animation: dpx-blink 5.2s infinite;
}
.dpx .brows {
    transform-box: fill-box;
    transform-origin: center;
    transition: transform 0.3s ease;
}
.dpx[data-mood="focus"] .brows {
    transform: translateY(-3px);
}
.dpx[data-mood="focus"] .head-tilt {
    transform: rotate(-3deg) translateY(-2px);
}

/* انیمیشن خوش‌آمدگویی محترمانه */
.dpx.is-talk .head {
    transform-box: fill-box;
    transform-origin: 50% 90%;
    animation: dpx-nod 0.85s ease-in-out 2;
}
.dpx.is-talk .brows {
    animation: dpx-brow-greet 1.7s ease-in-out 1;
}

@keyframes dpx-breathe { 50% { transform: scale(1.01, 1.018); } }
@keyframes dpx-blink { 0%, 94%, 100% { transform: scaleY(1); } 97% { transform: scaleY(0.08); } }
@keyframes dpx-nod {
    0%, 100% { transform: translate(0, 10px) rotate(0deg); }
    40% { transform: translate(0, 13px) rotate(2.2deg); }
    75% { transform: translate(0, 9px) rotate(-1deg); }
}
@keyframes dpx-brow-greet {
    0%, 100% { transform: translateY(0); }
    25%, 65% { transform: translateY(-2.5px); }
}

/* ---------- دکمه بیدارسازی ---------- */
.dpx__wake,
.dpx__wake:focus,
.dpx__wake:active {
    position: fixed;
    left: 0;
    bottom: 24px;
    z-index: 9990;
    width: 38px;
    height: 52px;
    padding: 0 0 0 4px;
    display: grid;
    place-items: center;
    border: 1px solid rgba(242, 84, 45, 0.55) !important;
    border-left: 0 !important;
    border-radius: 0 999px 999px 0;
    background: rgba(10, 29, 24, 0.92) !important;
    backdrop-filter: blur(12px);
    box-shadow: 0 10px 24px rgba(0, 0, 0, 0.45) !important;
    outline: none !important;
    cursor: pointer;
    transform: translateX(-6px);
    transition: transform 0.25s cubic-bezier(0.2, 0.8, 0.2, 1), border-color 0.2s ease;
}
.dpx__wake:hover {
    transform: translateX(0);
    border-color: var(--dpx-ember) !important;
}
.dpx__wake > span {
    display: block;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    overflow: hidden;
    background: var(--dpx-moss);
    border: 1.5px solid var(--dpx-ember);
}
.dpx__wake .dpx__svg { filter: none; overflow: hidden; }

/* ---------- موبایل و تبلت ---------- */
@media (max-width: 991px), (max-height: 640px) {
    .dpx {
        left: 14px;
        bottom: max(14px, env(safe-area-inset-bottom));
        width: 58px;
    }
    .dpx__full { display: none; }
    .dpx__bust {
        display: block;
        width: 58px;
        height: 58px;
        border-radius: 50%;
        overflow: hidden;
        background: var(--dpx-moss);
        border: 2px solid var(--dpx-ember);
        box-shadow:
            0 0 0 4px rgba(242, 84, 45, 0.15),
            0 12px 24px -8px rgba(0, 0, 0, 0.65);
    }
    .dpx__bust .dpx__svg { filter: none; overflow: hidden; }
    .dpx__off { display: none; }
    .dpx__ping { top: 0; left: 2px; }
    .dpx__bubble {
        left: 0;
        bottom: calc(100% + 12px);
        width: min(296px, calc(100vw - 28px));
        transform-origin: left bottom;
        transform: translate3d(0, 8px, 0) scale(0.96);
    }
}

@media (prefers-reduced-motion: reduce) {
    .dpx *, .dpx__wake { animation: none !important; transition: none !important; }
    .dpx.is-in .dpx__stage { transform: none; }
}
</style>
{/literal}

<div class="dpx" data-dpx role="complementary" aria-label="دستیار هوشمند دیتاهتلینگ">
    <ul class="dpx__data" data-dpx-tips hidden>
        <li data-sel=".dp-hero" data-tag="جستجوی دامنه" data-label="" data-href="">نام برندت را بنویس تا آزاد بودن دامنه را در کسری از ثانیه بررسی کنیم.</li>
        <li data-sel="#plans, .dpp-sec" data-tag="پلن‌های میزبانی" data-label="مقایسه کامل پلن‌ها ←" data-href="{$WEB_ROOT}/index.php?rp=/store/hstyng">ارتقای منابع در هر زمان بدون قطعی انجام می‌شود؛ با خیال راحت شروع کن.</li>
        <li data-sel=".dps-sec, .dp-proof" data-tag="پایداری شبکه" data-label="" data-href="">تمام نودهای ابری ما به صورت ۲۴/۷ مانیتور می‌شوند تا آپتایم ۹۹.۹۹٪ تضمین شود.</li>
        <li data-sel="#features, .dpf-sec" data-tag="معماری سخت‌افزار" data-label="" data-href="">روی هر ویژگی کلیک کن تا جزئیات فنی دیسک‌های NVMe و شبکه را ببینی.</li>
        <li data-sel="#domains, .dpd-sec" data-tag="انتقال و ثبت دامنه" data-label="انتقال دامنه ←" data-href="{$WEB_ROOT}/cart.php?a=add&domain=transfer">دامنه‌ات در شرکت دیگری است؟ می‌توانی بدون قطعی سایت آن را به دیتاهتلینگ منتقل کنی.</li>
        <li data-sel="#panel, .dpm-sec" data-tag="پنل یکپارچه" data-label="" data-href="">مدیریت سرور، DNS، تیکت‌ها و صورت‌حساب‌ها همگی از یک داشبورد انجام می‌شود.</li>
        <li data-sel=".dpc-sec, .dp-cta" data-tag="مشاوره تخصصی" data-label="ارسال تیکت ←" data-href="{$WEB_ROOT}/submitticket.php">برای انتخاب سرور مناسب تردید داری؟ مهندسان ما آماده‌ی راهنمایی هستند.</li>
    </ul>

    <div class="dpx__bubble" data-dpx-bubble role="status" aria-live="polite" aria-hidden="true">
        <div class="dpx__bhead">
            <span class="dpx__btag">
                <i aria-hidden="true"></i>
                <span data-dpx-tag>راهنمای هوشمند</span>
            </span>
            <button type="button" class="dpx__x" data-dpx-close aria-label="بستن پیام (Esc)" title="بستن">×</button>
        </div>

        <p class="dpx__text" data-dpx-text></p>

        <div class="dpx__bfoot">
            <a class="dpx__cta" data-dpx-cta href="#" hidden></a>
            <button type="button" class="dpx__never" data-dpx-never>غیرفعال‌سازی راهنما</button>
        </div>

        <div class="dpx__timer" aria-hidden="true">
            <span class="dpx__timer-bar" data-dpx-timer></span>
        </div>
    </div>

    <div class="dpx__stage">
        <button type="button" class="dpx__char" data-dpx-char aria-label="نمایش راهنمای این بخش">
            <span class="dpx__ping" aria-hidden="true"></span>
            <span class="dpx__full" data-dpx-full aria-hidden="true">
                <!-- گرافیک SVG میزبان حرفه‌ای (v8.1 — موهای واقع‌گرایانه، فرق کج و بافت تار مو) -->
                <svg class="dpx__svg" viewBox="44 46 152 274" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                  <defs>
                    <clipPath id="dpxEyeL"><ellipse cx="104" cy="112" rx="8" ry="5.4"/></clipPath>
                    <clipPath id="dpxEyeR"><ellipse cx="136" cy="112" rx="8" ry="5.4"/></clipPath>
                    <!-- گرادینت حجم‌دهی طبیعی به دسته‌های مو -->
                    <linearGradient id="dpxHairCrown" x1="0" y1="0" x2="1" y2="1">
                      <stop offset="0%" stop-color="#17382E"/>
                      <stop offset="55%" stop-color="#0D241D"/>
                      <stop offset="100%" stop-color="#07130F"/>
                    </linearGradient>
                    <linearGradient id="dpxHairWave" x1="0" y1="0" x2="1" y2="0.4">
                      <stop offset="0%" stop-color="#1D463A"/>
                      <stop offset="100%" stop-color="#0A1D18"/>
                    </linearGradient>
                  </defs>

                  <g class="char" stroke-linejoin="round" stroke-linecap="round">
                    <!-- ۱) گردن (زیر یقه و کراوات) -->
                    <path d="M107 160H133V202H107Z" fill="#E8B892"/>
                    <path d="M107 160H133V186Q120 195 107 186Z" fill="#0A1D18" opacity=".24"/>

                    <!-- ۲) کت اسلیم‌فیت با شانه‌های متناسب -->
                    <path d="M62 324 L56 244 Q55 212 78 202 L104 192 L120 214 L136 192 L162 202 Q185 212 184 244 L178 324 Z" fill="#112A23" stroke="#8FA399" stroke-opacity=".38" stroke-width="1.6"/>

                    <!-- آستین‌های چپ و راست در حالت استراحت طبیعی کنار بدن -->
                    <path d="M62 324 L56 244 Q55 212 78 202 L82 222 Q76 264 78 324 Z" fill="#0A1D18" opacity=".34"/>
                    <path d="M178 324 L184 244 Q185 212 162 202 L158 222 Q164 264 162 324 Z" fill="#0A1D18" opacity=".22"/>
                    <path d="M78 204 Q74 260 78 324 M162 204 Q166 260 162 324" fill="none" stroke="#8FA399" stroke-opacity=".32" stroke-width="1.5"/>

                    <!-- ۳) پیراهن، یقه و کراوات -->
                    <path d="M104 188L136 188L120 260Z" fill="#D5DFD9"/>
                    <path d="M115 202H125L127 212H113Z" fill="#D9431F"/>
                    <path d="M113.5 212H126.5L128.5 250L120 260L111.5 250Z" fill="#F2542D"/>
                    <path d="M120 212V256" stroke="#0A1D18" stroke-width="1.4" opacity=".25" fill="none"/>
                    <path d="M103 188L120 203L101 212L99 194Z M137 188L120 203L139 212L141 194Z" fill="#E9EEEA" stroke="#0A1D18" stroke-opacity=".28" stroke-width="1.3"/>

                    <!-- ۴) یقه کت (Lapels) + سنجاق شمسه ۸ پر + دستمال جیب -->
                    <path d="M84 204L104 192L116 250L95 238Z" fill="#0A1D18" stroke="#8FA399" stroke-opacity=".55" stroke-width="1.5"/>
                    <path d="M156 204L136 192L124 250L145 238Z" fill="#0A1D18" stroke="#8FA399" stroke-opacity=".55" stroke-width="1.5"/>
                    <polygon points="97.0,215.5 98.4,219.6 102.5,217.8 100.6,221.6 104.5,223.0 100.6,224.4 102.5,228.2 98.4,226.4 97.0,230.5 95.6,226.4 91.5,228.2 93.4,224.4 89.5,223.0 93.4,221.6 91.5,217.8 95.6,219.6" fill="#F2542D"/>
                    <circle cx="97" cy="223" r="1.6" fill="#E9EEEA"/>
                    <path d="M138 248 H154" stroke="#8FA399" stroke-opacity=".45" stroke-width="1.6"/>
                    <path d="M141 246.5 L146 242 L151 246.5 Z" fill="#F2542D" opacity=".9"/>

                    <!-- ۵) سر و موهای واقع‌گرایانه -->
                    <g class="head-tilt">
                      <g class="head" transform="translate(0 10)">
                        <!-- لایه پشتی مو (حجم پشت سر قبل از گوش‌ها و صورت) -->
                        <path d="M83 114 C80 96 81 76 89 65 C96 55 110 50 125 51 C142 52 154 62 157 78 C160 92 158 104 155 114 Z" fill="#071410"/>

                        <!-- گوش‌ها -->
                        <ellipse cx="85.5" cy="127" rx="6" ry="10" fill="#E8B892"/>
                        <ellipse cx="154.5" cy="127" rx="6" ry="10" fill="#E8B892"/>
                        <path d="M85 121Q88 127 85 133M155 121Q152 127 155 133" fill="none" stroke="#0A1D18" stroke-width="2" opacity=".3"/>

                        <!-- صورت و سایه‌روشن پوست -->
                        <path d="M86 110C86 86 100 76 120 76C140 76 154 86 154 110V128C154 150 142 168 120 174C98 168 86 150 86 128Z" fill="#E8B892"/>
                        <!-- سایه ظریف زیر خط رویش مو روی پیشانی برای عمق طبیعی -->
                        <path d="M89 92 C92 80 102 75 118 75 C135 75 147 80 151 92 C146 83 135 79 119 79 C103 79 94 83 89 92 Z" fill="#0A1D18" opacity=".14"/>
                        <path d="M154 108C154 142 146 162 124 173C144 160 148 140 147 110Z" fill="#0A1D18" opacity=".15"/>
                        <circle cx="98" cy="136" r="9" fill="#F2542D" opacity=".07"/>
                        <circle cx="142" cy="136" r="9" fill="#F2542D" opacity=".07"/>

                        <!-- بینی -->
                        <path d="M120 110C119 122 116 128 114 132Q120 138 127 132C124 130 123 124 122 110Z" fill="#0A1D18" opacity=".13"/>
                        <path d="M114.5 133Q120 138 125.5 133" fill="none" stroke="#0A1D18" stroke-width="2.1" opacity=".38"/>

                        <!-- ریش و سبیل با بافت طبیعی و بدون کادر مصنوعی -->
                        <path d="M86 118C86 150 98 172 120 177C142 172 154 150 154 118L151 112C150 130 146 142 138 148L102 148C94 142 90 130 89 112Z" fill="#0A1D18"/>
                        <!-- بافت تارهای ریش روی چانه -->
                        <path d="M90 138 Q98 158 114 168 M150 138 Q142 158 126 168 M104 160 Q120 171 136 160" fill="none" stroke="#1D463A" stroke-width="1.3" opacity=".65"/>
                        <path d="M87 128 C89 152 100 171 120 176 C140 171 151 152 153 128" fill="none" stroke="#8FA399" stroke-opacity=".3" stroke-width="1.2"/>

                        <!-- دهان و لبخند -->
                        <path d="M107.5 152.4Q120 168 132.5 152.4Q120 156.4 107.5 152.4Z" fill="#F2542D" fill-opacity=".45"/>
                        <path d="M110 152.8Q120 157.2 130 152.8L129 155.4Q120 159.5 111 155.4Z" fill="#E9EEEA"/>
                        <path d="M102 148Q111 141 120 144.5Q129 141 138 148Q129 151.5 120 149.5Q111 151.5 102 148Z" fill="#0A1D18"/>

                        <!-- ==================== موهای واقع‌گرایانه، لایه‌لایه و با فرق کج ==================== -->
                        <g class="hair-realistic">
                          <!-- ۱. خط ریش و شقیقه چپ (Tapered Left Sideburn & Temple) -->
                          <path d="M86 120 C84 108 82 94 84 82 C85 74 90 67 97 64 L100 74 C94 78 91 83 91 91 L89 120 Z" fill="#0A1D18"/>

                          <!-- ۲. خط ریش و شقیقه راست (Tapered Right Sideburn & Temple) -->
                          <path d="M154 120 C156 108 158 92 155 79 C153 70 147 63 139 60 L136 74 C144 77 148 82 149 91 L151 120 Z" fill="#0A1D18"/>

                          <!-- ۳. دسته موی سمت چپِ خط فرق (Swept Left Part) -->
                          <path d="M98 73 C91 73 85 79 83 88 C82 95 83 103 86 110 C86 98 89 87 95 81 C97 79 99 76 98 73 Z" fill="url(#dpxHairCrown)"/>

                          <!-- ۴. حجم اصلی موی بالای سر با تیغه‌ها و موج‌های طبیعی (Feathered Top Quiff) -->
                          <path d="M98 73 C96 63 102 54 113 51 L110 55 C118 48 131 48 141 53 L137 56 C146 54 154 60 156 70 C158 78 157 88 153 96 C151 86 146 79 137 76 C127 73 116 77 106 77 C101 77 99 75 98 73 Z" fill="url(#dpxHairCrown)"/>

                          <!-- ۵. دسته موی موج‌دار جلوی پیشانی (Front Wave Lock) برای شکستن حالت گنبدی/عمامه‌ای -->
                          <path d="M100 72 C105 61 117 55 130 56 C141 57 149 63 153 72 C145 66 134 64 122 66 C113 68 106 72 100 72 Z" fill="url(#dpxHairWave)"/>

                          <!-- ۶. دسته موی کوچک رها شده روی پیشانی و شقیقه راست -->
                          <path d="M106 76 C115 71 128 70 139 74 C145 76 149 80 151 86 C146 80 138 77 128 76 C119 75 112 77 106 76 Z" fill="#0A1D18"/>

                          <!-- ۷. شکاف طبیعی خط فرق مو (Side-Part Skin Line در x=98) -->
                          <path d="M98.5 74.5 Q96.5 68 94.5 63" fill="none" stroke="#E8B892" stroke-width="1.3" opacity=".55"/>

                          <!-- ۸. تارهای مو و هایلایت‌های نوری طبیعی (Hair Strands) -->
                          <path d="M102 68 C110 59 124 55 139 59" fill="none" stroke="#8FA399" stroke-width="1.2" opacity=".38"/>
                          <path d="M105 72 C116 64 131 63 146 69" fill="none" stroke="#8FA399" stroke-width="1.1" opacity=".32"/>
                          <path d="M113 54 C122 50 132 51 140 55" fill="none" stroke="#8FA399" stroke-width="1" opacity=".28"/>
                          <path d="M95 75 C90 79 87 86 86 95" fill="none" stroke="#8FA399" stroke-width="1.1" opacity=".32"/>
                          <path d="M148 74 C153 80 154 89 152 99" fill="none" stroke="#8FA399" stroke-width="1" opacity=".28"/>
                        </g>

                        <!-- چشم‌ها -->
                        <g class="eye">
                          <ellipse cx="104" cy="112" rx="8" ry="5.4" fill="#E9EEEA"/>
                          <g clip-path="url(#dpxEyeL)">
                            <g class="eyes-track">
                              <circle cx="104" cy="112.4" r="4.3" fill="#0A1D18"/>
                              <circle cx="102.4" cy="110.7" r="1.5" fill="#E9EEEA"/>
                            </g>
                          </g>
                          <path d="M95.5 110Q104 104.5 112.5 110" fill="none" stroke="#0A1D18" stroke-width="2.4"/>
                        </g>
                        <g class="eye">
                          <ellipse cx="136" cy="112" rx="8" ry="5.4" fill="#E9EEEA"/>
                          <g clip-path="url(#dpxEyeR)">
                            <g class="eyes-track">
                              <circle cx="136" cy="112.4" r="4.3" fill="#0A1D18"/>
                              <circle cx="134.4" cy="110.7" r="1.5" fill="#E9EEEA"/>
                            </g>
                          </g>
                          <path d="M127.5 110Q136 104.5 144.5 110" fill="none" stroke="#0A1D18" stroke-width="2.4"/>
                        </g>

                        <!-- عینک -->
                        <path d="M98 101H110Q117 101 117 108V116Q117 124 110 124H98Q91 124 91 116V108Q91 101 98 101Z M130 101H142Q149 101 149 108V116Q149 124 142 124H130Q123 124 123 116V108Q123 101 130 101Z M117 108Q120 105 123 108M91 108L85 106M149 108L155 106" fill="none" stroke="#8FA399" stroke-width="2"/>
                        <path d="M96 105L106 120M128 105L138 120" fill="none" stroke="#E9EEEA" stroke-width="3" opacity=".12"/>

                        <!-- ابروها -->
                        <g class="brows">
                          <path d="M90 92Q101 81 114 87L113.4 91.4Q101 86.5 91.5 96Z" fill="#0A1D18" stroke="#0A1D18" stroke-width="1.4"/>
                          <path d="M126 87Q139 81 150 92L148.5 96Q139 86.5 126.6 91.4Z" fill="#0A1D18" stroke="#0A1D18" stroke-width="1.4"/>
                        </g>
                      </g>
                    </g>
                  </g>
                </svg>
            </span>
            <span class="dpx__bust" data-dpx-bust aria-hidden="true"></span>
        </button>
        <button type="button" class="dpx__off" data-dpx-off aria-label="به خواب بردن راهنما" title="بستن راهنما">×</button>
    </div>
</div>

<button type="button" class="dpx__wake" data-dpx-wake hidden aria-label="بیدار کردن راهنمای سایت" title="نمایش راهنمای سایت">
    <span data-dpx-wakebust aria-hidden="true"></span>
</button>

{literal}
<script>
(function () {
    'use strict';
    var root = document.querySelector('[data-dpx]');
    if (!root) { return; }

    var fullSvg = root.querySelector('[data-dpx-full] svg');
    var bustSlot = root.querySelector('[data-dpx-bust]');
    var wakeBtn = document.querySelector('[data-dpx-wake]');
    var wakeBustSlot = document.querySelector('[data-dpx-wakebust]');
    var bubble = root.querySelector('[data-dpx-bubble]');
    var tagEl = root.querySelector('[data-dpx-tag]');
    var textEl = root.querySelector('[data-dpx-text]');
    var ctaEl = root.querySelector('[data-dpx-cta]');
    var timerBar = root.querySelector('[data-dpx-timer]');
    var closeBtn = root.querySelector('[data-dpx-close]');
    var neverBtn = root.querySelector('[data-dpx-never]');
    var offBtn = root.querySelector('[data-dpx-off]');
    var charBtn = root.querySelector('[data-dpx-char]');

    /* ۱. ساخت آواتار پرتره برای موبایل و دکمه بیدارسازی (با یکتاسازی IDهای گرادینت و ClipPath) */
    var uid = 0;
    function cloneBust(slot) {
        if (!slot || !fullSvg) { return; }
        var copy = fullSvg.cloneNode(true);
        uid += 1;
        copy.querySelectorAll('[id]').forEach(function (el) {
            var oldId = el.id, newId = oldId + '-c' + uid;
            el.id = newId;
            copy.querySelectorAll('[clip-path="url(#' + oldId + ')"]').forEach(function (r) {
                r.setAttribute('clip-path', 'url(#' + newId + ')');
            });
            copy.querySelectorAll('[fill="url(#' + oldId + ')"]').forEach(function (r) {
                r.setAttribute('fill', 'url(#' + newId + ')');
            });
        });
        copy.setAttribute('viewBox', '56 58 128 134');
        slot.appendChild(copy);
    }
    cloneBust(bustSlot);
    cloneBust(wakeBustSlot);

    /* ۲. جمع‌آوری سکشن‌ها و دیالوگ‌ها */
    var tipNodes = root.querySelectorAll('[data-dpx-tips] li');
    var allTips = [];
    var matchedTips = [];

    tipNodes.forEach(function (li, index) {
        var sel = li.getAttribute('data-sel');
        var el = sel ? document.querySelector(sel) : null;
        var item = {
            id: 'tip_' + index,
            el: el,
            tag: li.getAttribute('data-tag') || 'راهنمای بخش',
            text: li.textContent.trim(),
            label: li.getAttribute('data-label') || '',
            href: li.getAttribute('data-href') || ''
        };
        allTips.push(item);
        if (el) { matchedTips.push(item); }
    });

    var STORAGE_KEY = 'dh_mascot_off';
    var seenIds = {};
    var activeTip = matchedTips[0] || allTips[0];
    var dwellTimer = 0;
    var waveTimer = 0;
    var lastScrollY = window.scrollY || 0;
    var lastScrollTime = Date.now();
    var scrollSpeed = 0;

    /* ۳. مدیریت باز و بسته شدن حباب همراه با ریست تایمر CSS */
    function openBubble(tip, isManual) {
        if (!tip || root.classList.contains('is-off') || root.classList.contains('is-away')) { return; }
        activeTip = tip;
        seenIds[tip.id] = true;
        root.classList.remove('has-unread');

        if (tagEl) { tagEl.textContent = tip.tag; }
        textEl.textContent = tip.text;

        if (tip.label && tip.href) {
            ctaEl.textContent = tip.label;
            ctaEl.setAttribute('href', tip.href);
            ctaEl.hidden = false;
        } else {
            ctaEl.hidden = true;
        }

        if (timerBar) {
            timerBar.style.animation = 'none';
            void timerBar.offsetWidth;
            timerBar.style.animation = '';
        }

        root.classList.add('is-open');
        if (isManual || Object.keys(seenIds).length <= 2) {
            root.classList.add('is-talk');
            window.clearTimeout(waveTimer);
            waveTimer = window.setTimeout(function () {
                root.classList.remove('is-talk');
            }, 2000);
        }
        bubble.setAttribute('aria-hidden', 'false');
    }

    function closeBubble() {
        root.classList.remove('is-open', 'is-talk');
        bubble.setAttribute('aria-hidden', 'true');
    }

    if (timerBar) {
        timerBar.addEventListener('animationend', function () {
            closeBubble();
        });
    }

    function disableMascot() {
        closeBubble();
        root.classList.add('is-off');
        root.classList.remove('is-in', 'has-unread');
        if (wakeBtn) { wakeBtn.hidden = false; }
        try { localStorage.setItem(STORAGE_KEY, '1'); } catch (e) {}
    }

    function enableMascot() {
        try { localStorage.removeItem(STORAGE_KEY); } catch (e) {}
        if (wakeBtn) { wakeBtn.hidden = true; }
        root.classList.remove('is-off');
        window.setTimeout(function () {
            root.classList.add('is-in');
            openBubble(activeTip, true);
        }, 60);
    }

    /* ۴. راه‌اندازی اولیه */
    var isDisabled = false;
    try { isDisabled = localStorage.getItem(STORAGE_KEY) === '1'; } catch (e) {}

    if (isDisabled) {
        root.classList.add('is-off');
        if (wakeBtn) { wakeBtn.hidden = false; }
    } else {
        window.setTimeout(function () {
            root.classList.add('is-in');
            openBubble(activeTip, false);
        }, 850);
    }

    /* ۵. کنترل‌های کلیک و کیبورد (Esc) */
    if (closeBtn) { closeBtn.addEventListener('click', closeBubble); }
    if (offBtn) { offBtn.addEventListener('click', disableMascot); }
    if (neverBtn) { neverBtn.addEventListener('click', disableMascot); }
    if (wakeBtn) { wakeBtn.addEventListener('click', enableMascot); }

    if (charBtn) {
        charBtn.addEventListener('click', function () {
            this.blur();
            if (root.classList.contains('is-open')) {
                closeBubble();
            } else {
                openBubble(activeTip, true);
            }
        });
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && root.classList.contains('is-open')) {
            closeBubble();
        }
    });

    /* ۶. محاسبه سرعت اسکرول */
    window.addEventListener('scroll', function () {
        var now = Date.now();
        var dt = Math.max(16, now - lastScrollTime);
        var dy = Math.abs(window.scrollY - lastScrollY);
        scrollSpeed = dy / dt;
        lastScrollY = window.scrollY;
        lastScrollTime = now;
    }, { passive: true });

    /* ۷. تشخیص سکشن فعال با مکث هوشمند */
    if ('IntersectionObserver' in window && matchedTips.length) {
        var secObs = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting && entry.intersectionRatio >= 0.35) {
                    var found = matchedTips.find(function (t) { return t.el === entry.target; });
                    if (!found || found === activeTip) { return; }

                    activeTip = found;
                    window.clearTimeout(dwellTimer);

                    if (seenIds[found.id]) {
                        closeBubble();
                        root.classList.add('has-unread');
                        return;
                    }

                    dwellTimer = window.setTimeout(function () {
                        if (scrollSpeed < 1.2) {
                            openBubble(found, false);
                        } else {
                            root.classList.add('has-unread');
                        }
                    }, 650);
                }
            });
        }, { threshold: [0.35, 0.6] });

        matchedTips.forEach(function (t) { secObs.observe(t.el); });
    }

    /* ۸. کنار رفتن خودکار هنگام رسیدن به فوتر */
    var footerEl = document.querySelector('.dp-footer, .dpft');
    if ('IntersectionObserver' in window && footerEl) {
        var footObs = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                root.classList.toggle('is-away', entry.isIntersecting);
            });
        }, { threshold: 0.15 });
        footObs.observe(footerEl);
    }

    /* ۹. واکنش زنده به تایپ کاربر در فیلد جستجوی دامنه */
    var domainInput = document.querySelector('.dp-domain-form__input');
    if (domainInput) {
        domainInput.addEventListener('focus', function () {
            root.setAttribute('data-mood', 'focus');
        });
        domainInput.addEventListener('blur', function () {
            root.removeAttribute('data-mood');
        });
    }

    /* ۱۰. ردیابی نرم نگاه و چرخش سر با حرکت موس */
    if (window.matchMedia && window.matchMedia('(pointer: fine)').matches) {
        var rafId = 0;
        window.addEventListener('mousemove', function (e) {
            if (rafId || root.classList.contains('is-off')) { return; }
            rafId = window.requestAnimationFrame(function () {
                rafId = 0;
                var rect = root.getBoundingClientRect();
                var cx = rect.left + rect.width * 0.5;
                var cy = rect.top + rect.height * 0.35;
                var dx = (e.clientX - cx) / window.innerWidth;
                var dy = (e.clientY - cy) / window.innerHeight;

                var lookX = Math.max(-3.2, Math.min(3.2, dx * 6));
                var lookY = Math.max(-1.8, Math.min(1.8, dy * 4));
                var headRot = Math.max(-2.8, Math.min(2.8, dx * 4.5));

                root.style.setProperty('--look-x', lookX.toFixed(2) + 'px');
                root.style.setProperty('--look-y', lookY.toFixed(2) + 'px');
                root.style.setProperty('--head-rot', headRot.toFixed(2) + 'deg');
            });
        }, { passive: true });
    }
}());
</script>
{/literal}