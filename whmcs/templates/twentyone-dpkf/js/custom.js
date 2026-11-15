/**
 * دیتاهتلینگ — homepage behaviour.
 * Vanilla JS, no dependency on jQuery or the WHMCS theme bundle.
 */
(function () {
    'use strict';

    var doc = document;

    function on(el, evt, fn) {
        if (el) { el.addEventListener(evt, fn); }
    }

    /* ------------------------------------------------ sticky header state */
    function initStickyHeader() {
        var header = doc.querySelector('[data-dp-header]');
        if (!header) { return; }

        var ticking = false;

        function update() {
            header.classList.toggle('is-scrolled', window.pageYOffset > 12);
            ticking = false;
        }

        on(window, 'scroll', function () {
            if (!ticking) {
                ticking = true;
                window.requestAnimationFrame(update);
            }
        });

        update();
    }

    /* --------------------------------------------------- header kb search */
    function initHeaderSearch() {
        var toggle = doc.querySelector('[data-dp-search-toggle]');
        var panel = doc.getElementById('dpHeaderSearch');
        if (!toggle || !panel) { return; }

        on(toggle, 'click', function () {
            var willOpen = panel.hasAttribute('hidden');

            if (willOpen) {
                panel.removeAttribute('hidden');
                var field = panel.querySelector('input[type="text"]');
                if (field) { field.focus(); }
            } else {
                panel.setAttribute('hidden', '');
            }

            toggle.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
        });
    }

    /* -------------------------------------------------- mobile navigation */
    function initDrawer() {
        var drawer = doc.getElementById('dpMobileMenu');
        var opener = doc.querySelector('[data-dp-menu-open]');
        if (!drawer || !opener) { return; }

        var panel = drawer.querySelector('.dp-drawer__panel');

        function open(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            drawer.classList.add('is-open');
            drawer.setAttribute('aria-hidden', 'false');
            opener.setAttribute('aria-expanded', 'true');
            doc.body.style.overflow = 'hidden';

            var first = panel && panel.querySelector('a, button');
            if (first) { first.focus(); }
        }

        function close() {
            drawer.classList.remove('is-open');
            drawer.setAttribute('aria-hidden', 'true');
            opener.setAttribute('aria-expanded', 'false');
            doc.body.style.overflow = '';
            opener.focus();
        }

        on(opener, 'click', open);

        Array.prototype.forEach.call(
            drawer.querySelectorAll('[data-dp-menu-close]'),
            function (btn) { on(btn, 'click', close); }
        );

        Array.prototype.forEach.call(
            drawer.querySelectorAll('a'),
            function (link) { on(link, 'click', close); }
        );

        on(doc, 'keydown', function (e) {
            if (e.key === 'Escape' && drawer.classList.contains('is-open')) {
                close();
            }
        });
    }

    /* --------------------------------------------------------- FAQ accordion */
    function initFaq() {
        var root = doc.querySelector('[data-dp-faq]');
        if (!root) { return; }

        var items = root.querySelectorAll('.dp-faq__item');

        function collapse(item) {
            var panel = item.querySelector('.dp-faq__a');
            var button = item.querySelector('.dp-faq__q');
            var icon = item.querySelector('.dp-faq__icon i');

            item.classList.remove('is-open');
            if (panel) {
                panel.style.maxHeight = '0px';
                panel.style.visibility = 'hidden';
            }
            if (button) { button.setAttribute('aria-expanded', 'false'); }
            if (icon) { icon.className = 'fas fa-plus'; }
        }

        function expand(item) {
            var panel = item.querySelector('.dp-faq__a');
            var button = item.querySelector('.dp-faq__q');
            var icon = item.querySelector('.dp-faq__icon i');

            item.classList.add('is-open');
            if (panel) {
                panel.style.visibility = 'visible';
                panel.style.maxHeight = panel.scrollHeight + 'px';
            }
            if (button) { button.setAttribute('aria-expanded', 'true'); }
            if (icon) { icon.className = 'fas fa-minus'; }
        }

        Array.prototype.forEach.call(items, function (item) {
            var button = item.querySelector('.dp-faq__q');
            if (!button) { return; }

            on(button, 'click', function (e) {
                e.preventDefault();
                e.stopPropagation();

                var isOpen = item.classList.contains('is-open');
                Array.prototype.forEach.call(items, collapse);
                if (!isOpen) { expand(item); }
            });
        });

        on(window, 'resize', function () {
            Array.prototype.forEach.call(items, function (item) {
                if (!item.classList.contains('is-open')) { return; }
                var panel = item.querySelector('.dp-faq__a');
                if (panel) { panel.style.maxHeight = panel.scrollHeight + 'px'; }
            });
        });
    }

    /* ------------------------------------------------ domain search forms */
    function initDomainForms() {
        var forms = doc.querySelectorAll('[data-dp-domain-form]');
        if (!forms.length) { return; }

        var VALID = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/i;

        Array.prototype.forEach.call(forms, function (form) {
            var box = form.querySelector('.dp-domain-form__box');
            var name = form.querySelector('[data-dp-domain-name]');
            var tld = form.querySelector('[data-dp-domain-tld]');
            var hidden = form.querySelector('[data-dp-domain-value]');
            var submit = form.querySelector('[data-dp-domain-submit]');
            var label = form.querySelector('[data-dp-domain-label]');
            var msg = form.querySelector('[data-dp-domain-msg]');

            function fail(text) {
                if (box) { box.classList.add('has-error'); }
                if (msg) {
                    msg.textContent = text;
                    msg.removeAttribute('hidden');
                }
                if (name) { name.focus(); }
            }

            function clear() {
                if (box) { box.classList.remove('has-error'); }
                if (msg) { msg.setAttribute('hidden', ''); }
            }

            on(name, 'focus', function () { if (box) { box.classList.add('is-focused'); } });
            on(name, 'blur', function () { if (box) { box.classList.remove('is-focused'); } });
            on(name, 'input', clear);

            on(form, 'submit', function (e) {
                var raw = (name.value || '').trim().toLowerCase().replace(/^https?:\/\//, '');
                var chosenTld = tld ? tld.value : '.com';

                if (raw.indexOf('.') > -1) {
                    var parts = raw.split('.');
                    raw = parts.shift();
                    chosenTld = '.' + parts.join('.');
                }

                clear();

                if (!raw) {
                    e.preventDefault();
                    fail('لطفاً نام دامنه را وارد کنید.');
                    return;
                }

                if (!VALID.test(raw)) {
                    e.preventDefault();
                    fail('نام دامنه فقط می‌تواند شامل حروف انگلیسی، عدد و خط تیره باشد.');
                    return;
                }

                if (hidden) { hidden.value = raw + chosenTld; }
                if (label) { label.textContent = 'در حال بررسی...'; }
                if (submit) { submit.disabled = true; }
            });
        });
    }

    /* ------------------- domain promo: TLD chips ---------------------------- */
    function initDomainChips() {
        var lists = doc.querySelectorAll('[data-dpd-tlds]');
        Array.prototype.forEach.call(lists, function (list) {
            var form = list.closest ? list.closest('.dp-promo') : null;
            var select = form ? form.querySelector('[data-dp-domain-tld]') : null;
            var chips = list.querySelectorAll('.dpd-tld');
            function mark(val) {
                Array.prototype.forEach.call(chips, function (c) { c.classList.toggle('is-active', c.getAttribute('data-tld') === val); });
            }
            on(list, 'click', function (e) {
                var node = e.target && e.target.nodeType === 1 ? e.target : (e.target && e.target.parentNode);
                var chip = node && node.closest ? node.closest('.dpd-tld') : null;
                if (!chip || !select) { return; }
                select.value = chip.getAttribute('data-tld');
                mark(select.value);
                var input = form.querySelector('[data-dp-domain-name]');
                if (input) { input.focus(); }
            });
            on(select, 'change', function () { mark(select.value); });
        });
    }

    /* ------------------- domain promo: pointer glow -------------------------- */
    function initPanelGlow() {
        var panels = doc.querySelectorAll('.dpd-panel, [data-dp-glow]');
        Array.prototype.forEach.call(panels, function (panel) {
            var raf = 0, px = 0, py = 0;
            function paint() {
                raf = 0;
                var r = panel.getBoundingClientRect();
                panel.style.setProperty('--mx', (px - r.left) + 'px');
                panel.style.setProperty('--my', (py - r.top) + 'px');
            }
            on(panel, 'pointermove', function (e) {
                if (e.pointerType === 'touch') { return; }
                px = e.clientX; py = e.clientY;
                panel.style.setProperty('--glow', '1');
                if (!raf) { raf = window.requestAnimationFrame(paint); }
            });
            on(panel, 'pointerleave', function () { panel.style.setProperty('--glow', '0'); });
        });
    }
    /* ------------------------------------------- testimonials quotes ----- */
    function initQuotes() {
        var root = doc.querySelector('[data-dp-quotes]');
        if (!root) { return; }

        var quotes = Array.prototype.slice.call(root.querySelectorAll('.dpt-quote'));
        var tabs = Array.prototype.slice.call(root.querySelectorAll('.dpt-tab'));
        var prev = root.querySelector('[data-dpt-prev]');
        var next = root.querySelector('[data-dpt-next]');
        var stage = root.querySelector('.dpt-stage');
        if (!quotes.length || quotes.length !== tabs.length) { return; }

        var STEP = 6000; /* ms per testimonial */
        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        var current = 0;
        var elapsed = 0;
        var last = 0;
        var hold = { hover: false, focus: false, offscreen: false, touch: false };

        function paused() {
            return reduce || hold.hover || hold.focus || hold.offscreen || hold.touch || doc.hidden;
        }

        function paint(p) {
            var bar = tabs[current].querySelector('.dpt-tab__bar');
            if (bar) { bar.style.transform = 'scaleX(' + p + ')'; }
        }

        function show(i, focusTab) {
            current = (i + quotes.length) % quotes.length;

            quotes.forEach(function (q, k) {
                var on_ = k === current;
                q.classList.toggle('is-active', on_);
                if (on_) { q.removeAttribute('aria-hidden'); } else { q.setAttribute('aria-hidden', 'true'); }
            });

            tabs.forEach(function (t, k) {
                var on_ = k === current;
                var bar = t.querySelector('.dpt-tab__bar');
                t.classList.toggle('is-active', on_);
                t.setAttribute('aria-selected', on_ ? 'true' : 'false');
                t.setAttribute('tabindex', on_ ? '0' : '-1');
                if (bar) { bar.style.transform = 'scaleX(0)'; }
            });

            if (focusTab) { tabs[current].focus(); }
            elapsed = 0;
        }

        function frameLoop(ts) {
            window.requestAnimationFrame(frameLoop);
            if (!last) { last = ts; }
            var dt = Math.min(ts - last, 100);
            last = ts;
            if (paused()) { return; }

            elapsed += dt;
            var p = Math.min(elapsed / STEP, 1);
            paint(p);
            if (p >= 1) { show(current + 1, false); }
        }

        on(prev, 'click', function () { show(current - 1, false); });
        on(next, 'click', function () { show(current + 1, false); });

        tabs.forEach(function (tab, k) {
            on(tab, 'click', function () { show(k, false); });
            on(tab, 'keydown', function (e) {
                /* RTL: right arrow = previous, left arrow = next */
                var dir = e.key === 'ArrowLeft' ? 1 : (e.key === 'ArrowRight' ? -1 : 0);
                if (!dir) { return; }
                e.preventDefault();
                show(current + dir, true);
            });
        });

        on(root, 'mouseenter', function () { hold.hover = true; });
        on(root, 'mouseleave', function () { hold.hover = false; elapsed = 0; paint(0); });
        on(root, 'focusin', function () { hold.focus = true; });
        on(root, 'focusout', function () { hold.focus = false; });

        /* touch swipe on the quote area */
        var startX = null;
        on(stage, 'touchstart', function (e) {
            hold.touch = true;
            startX = e.touches[0].clientX;
        });
        on(stage, 'touchend', function (e) {
            hold.touch = false;
            if (startX === null) { return; }
            var dx = e.changedTouches[0].clientX - startX;
            startX = null;
            if (Math.abs(dx) < 40) { return; }
            /* RTL: swipe right = previous, swipe left = next */
            show(current + (dx > 0 ? -1 : 1), false);
        });

        if ('IntersectionObserver' in window) {
            new IntersectionObserver(function (entries) {
                hold.offscreen = !entries[0].isIntersecting;
            }, { threshold: 0.35 }).observe(root);
        }

        show(0, false);
        if (!reduce) { window.requestAnimationFrame(frameLoop); }
    }
    /* --------------------------- hero: live domain results ---------------- */
    function initDomainResults() {
        var forms = doc.querySelectorAll('[data-dp-domain-form]');

        Array.prototype.forEach.call(forms, function (form) {
            var list = form.querySelector('[data-dp-domain-results]');
            if (!list) { return; }

            var name = form.querySelector('[data-dp-domain-name]');
            var tld = form.querySelector('[data-dp-domain-tld]');
            var rows = list.querySelectorAll('button[data-tld]');

            function base() {
                var v = (name.value || '').trim().toLowerCase()
                    .replace(/^https?:\/\//, '').split('.')[0]
                    .replace(/[^a-z0-9-]/g, '');
                return v || 'mybrand';
            }

            function paint() {
                var b = base();
                Array.prototype.forEach.call(rows, function (row) {
                    var el = row.querySelector('.dp-domain-results__name');
                    if (el) { el.textContent = b + row.getAttribute('data-tld'); }
                });
            }

            on(name, 'input', paint);

            Array.prototype.forEach.call(rows, function (row) {
                on(row, 'click', function () {
                    if (!name.value.trim()) { name.focus(); return; }
                    if (tld) { tld.value = row.getAttribute('data-tld'); }
                    if (form.requestSubmit) { form.requestSubmit(); }
                    else { form.querySelector('[data-dp-domain-submit]').click(); }
                });
            });
        });
    }

    /* ------------------------------------------- popular plans slider ---- */
    function initPlans() {
        var root = doc.querySelector('[data-dp-plans]');
        if (!root) { return; }

        var track = root.querySelector('[data-dp-plans-track]');
        var allCards = Array.prototype.slice.call(root.querySelectorAll('[data-dp-plan]'));
        var bar = root.querySelector('[data-dp-plans-bar]');
        var prev = root.querySelector('[data-dp-plans-prev]');
        var next = root.querySelector('[data-dp-plans-next]');
        if (!track || !allCards.length) { return; }

        var STEP = 2000; /* ms each plan stays active */
        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

        /* align the track's start/end padding with the .dp-container edge (exact px) */
        var viewport = root.querySelector('.dpp-viewport');
        var container = root.querySelector('.dp-container');
        function syncInset() {
            if (!viewport || !container) { return; }
            var r = container.getBoundingClientRect();
            var inset = Math.max(20, Math.round(doc.documentElement.clientWidth - r.right));
            viewport.style.setProperty('--dpp-inset', inset + 'px');
        }
        syncInset();
        on(window, 'resize', syncInset);

        var nf = null;
        try { nf = new Intl.NumberFormat('fa-IR'); } catch (err) { nf = null; }

        var cards = [];          /* currently visible cards (active tab) */
        var home = 0;
        var current = 0;
        var elapsed = 0;
        var last = 0;
        var yearly = false;
        var autoUntil = 0;       /* ignore scroll-sync while we scroll programmatically */
        var scrollTimer = 0;
        var hold = { hover: false, focus: false, offscreen: false, touch: false };

        function paused() {
            return reduce || hold.hover || hold.focus || hold.offscreen || hold.touch || doc.hidden;
        }

        /* progress bar fills from the start edge (right in RTL) */
        function paint(p) {
            if (bar) { bar.style.transform = 'scaleX(' + p + ')'; }
        }

        function reveal(card) {
            var f = track.getBoundingClientRect();
            var c = card.getBoundingClientRect();
            var delta = (c.left + c.width / 2) - (f.left + f.width / 2);
            if (Math.abs(delta) < 2) { return; }
            autoUntil = Date.now() + 1000;
            track.scrollBy({ left: delta, behavior: reduce ? 'auto' : 'smooth' });
        }

        function setActive(i, shouldReveal) {
            if (!cards.length) { return; }
            current = Math.max(0, Math.min(i, cards.length - 1));
            allCards.forEach(function (c) {
                c.classList.toggle('is-active', c === cards[current]);
            });
            if (prev) { prev.disabled = current <= 0; }
            if (next) { next.disabled = current >= cards.length - 1; }
            if (shouldReveal) { reveal(cards[current]); }
            elapsed = 0;
            paint(0);
        }

        function advance() {
            /* walk to the last plan, then return to the best-seller */
            setActive(current >= cards.length - 1 ? home : current + 1, true);
        }

        function frameLoop(ts) {
            window.requestAnimationFrame(frameLoop);
            if (!last) { last = ts; }
            var dt = Math.min(ts - last, 100);
            last = ts;
            if (paused()) { return; }

            elapsed += dt;
            var p = Math.min(elapsed / STEP, 1);
            paint(p);
            if (p >= 1) { advance(); }
        }

        /* ---------- category tabs: show only the plans of that category ---- */
        function applyCategory(cat, animate) {
            allCards.forEach(function (c) {
                c.hidden = c.getAttribute('data-cat') !== cat;
            });
            cards = allCards.filter(function (c) { return !c.hidden; });

            home = 0;
            cards.forEach(function (c, i) { if (c.hasAttribute('data-featured')) { home = i; } });

            autoUntil = Date.now() + 1000;
            track.scrollLeft = 0;

            if (animate && !reduce) {
                track.classList.remove('is-swapping');
                void track.offsetWidth;
                track.classList.add('is-swapping');
            }

            setActive(home, !!animate);
        }

        /* ---------- billing switch: monthly <-> yearly (2 months free) ----- */
        function money(n) {
            return (nf ? nf.format(n) : String(n)) + ' هزار';
        }

        function paintPrices() {
            root.classList.toggle('is-yearly', yearly);

            allCards.forEach(function (card) {
                var base = parseFloat(card.getAttribute('data-price')) || 0;
                var value = yearly ? Math.round(base * 10 / 12) : base;

                var price = card.querySelector('[data-dp-price]');
                var period = card.querySelector('[data-dp-period]');
                var old = card.querySelector('[data-dp-old]');
                var cta = card.querySelector('[data-dp-cta]');

                if (price) { price.textContent = money(value) + ' تومان'; }
                if (period) { period.textContent = yearly ? 'در ماه · پرداخت سالانه' : 'در ماه'; }
                if (old) { old.textContent = money(base); }

                /* WHMCS direct-add links accept a billing cycle */
                if (cta) {
                    if (!cta.hasAttribute('data-href')) { cta.setAttribute('data-href', cta.getAttribute('href')); }
                    var href = cta.getAttribute('data-href');
                    if (/cart\.php\?a=add/.test(href)) {
                        href = href.replace(/[&?]billingcycle=[^&]*/g, '');
                        if (yearly) { href += '&billingcycle=annually'; }
                    }
                    cta.setAttribute('href', href);
                }
            });
        }

        var tabs = root.querySelectorAll('[data-dp-seg]');
        Array.prototype.forEach.call(tabs, function (tab) {
            on(tab, 'click', function () {
                Array.prototype.forEach.call(tabs, function (t) {
                    var isOn = t === tab;
                    t.classList.toggle('is-active', isOn);
                    t.setAttribute('aria-selected', isOn ? 'true' : 'false');
                });
                applyCategory(tab.getAttribute('data-dp-seg'), true);
            });
        });

        var billing = root.querySelector('[data-dp-billing]');
        on(billing, 'click', function () {
            yearly = billing.getAttribute('aria-checked') !== 'true';
            billing.setAttribute('aria-checked', yearly ? 'true' : 'false');
            paintPrices();
        });

        /* ---------- manual controls ---------- */
        on(prev, 'click', function () { if (current > 0) { setActive(current - 1, true); } });
        on(next, 'click', function () { if (current < cards.length - 1) { setActive(current + 1, true); } });

        /* hover = the hovered plan becomes active, autoplay waits */
        allCards.forEach(function (card) {
            on(card, 'pointerenter', function (e) {
                if (e.pointerType && e.pointerType !== 'mouse') { return; }
                hold.hover = true;
                var k = cards.indexOf(card);
                if (k > -1 && k !== current) { setActive(k, false); }
            });
            on(card, 'pointerleave', function (e) {
                if (e.pointerType && e.pointerType !== 'mouse') { return; }
                hold.hover = false;
                elapsed = 0;
                paint(0);
            });
        });

        on(track, 'focusin', function () { hold.focus = true; });
        on(track, 'focusout', function () { hold.focus = false; elapsed = 0; });
        on(track, 'touchstart', function () { hold.touch = true; });
        on(track, 'touchend', function () { hold.touch = false; elapsed = 0; });

        /* user scrolled / swiped the track: highlight the card nearest the centre */
        on(track, 'scroll', function () {
            window.clearTimeout(scrollTimer);
            scrollTimer = window.setTimeout(function () {
                if (Date.now() < autoUntil || hold.hover) { return; }
                var f = track.getBoundingClientRect();
                var mid = f.left + f.width / 2;
                var best = current;
                var bestDist = Infinity;
                cards.forEach(function (c, k) {
                    var r = c.getBoundingClientRect();
                    var d = Math.abs(r.left + r.width / 2 - mid);
                    if (d < bestDist) { bestDist = d; best = k; }
                });
                if (best !== current) { setActive(best, false); }
            }, 140);
        });

        if ('IntersectionObserver' in window) {
            new IntersectionObserver(function (entries) {
                hold.offscreen = !entries[0].isIntersecting;
            }, { threshold: 0.35 }).observe(root);
        }

        applyCategory('hosting', false);
        paintPrices();
        if (!reduce) { window.requestAnimationFrame(frameLoop); }
    }

    /* ---------------------------------------------- newsletter (front-end) */
    function initNewsletter() {
        var form = doc.querySelector('[data-dp-newsletter]');
        if (!form) { return; }

        var msg = doc.querySelector('[data-dp-newsletter-msg]');
        var field = form.querySelector('input[type="email"]');

        on(form, 'submit', function (e) {
            e.preventDefault();

            var value = (field && field.value || '').trim();
            var valid = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value);

            if (!msg) { return; }

            msg.classList.toggle('is-error', !valid);
            msg.textContent = valid
                ? 'ایمیل شما ثبت شد. از این پس اخبار را دریافت می‌کنید.'
                : 'لطفاً یک ایمیل معتبر وارد کنید.';
            msg.removeAttribute('hidden');

            if (valid) { form.reset(); }
        });
    }
    
    /* --------------------------------------------- features accordion list */
    function initFeatures() {
        var list = doc.querySelector('[data-dp-features]');
        if (!list) { return; }

        var items = Array.prototype.slice.call(list.querySelectorAll('.dpf-item'));
        var label = doc.getElementById('dpfActiveLabel');
        var hits = Array.prototype.slice.call(doc.querySelectorAll('.dpf-chip__barcode i.is-hit'));
        if (!items.length) { return; }

        /* the ember ticks of the chip are the "stops": item k lights the k-th one */
        function syncTicks(index) {
            hits.forEach(function (tick, k) {
                tick.classList.toggle('is-on', k === Math.min(index, hits.length - 1));
            });
        }

        function setState(item, isOn) {
            var btn = item.querySelector('.dpf-item__trigger');
            var body = item.querySelector('.dpf-item__body');
            item.classList.toggle('is-active', isOn);
            if (btn) { btn.setAttribute('aria-expanded', isOn ? 'true' : 'false'); }
            if (body) { body.setAttribute('aria-hidden', isOn ? 'false' : 'true'); }
        }

        /* click on an open row closes it; click on another row switches to it */
        function toggle(item) {
            var wasOn = item.classList.contains('is-active');
            items.forEach(function (other) { setState(other, other === item && !wasOn); });

            if (wasOn) {
                hits.forEach(function (tick) { tick.classList.remove('is-on'); });
                return;
            }
            var chip = item.getAttribute('data-chip');
            if (label && chip) { label.textContent = chip; }
            syncTicks(items.indexOf(item));
        }

        /* only the trigger button toggles; clicks on the body text do nothing */
        on(list, 'click', function (e) {
            var node = e.target && e.target.nodeType === 1 ? e.target : (e.target && e.target.parentNode);
            var trg = node && node.closest ? node.closest('.dpf-item__trigger') : null;
            var item = trg ? trg.closest('.dpf-item') : null;
            if (item && list.contains(item)) { toggle(item); }
        });

        var start = 0;
        items.forEach(function (item, k) { if (item.classList.contains('is-active')) { start = k; } });
        syncTicks(start);
    }

    /* ----------------------------------------------- anchor smooth scroll */
    function initSmoothScroll() {
        var header = doc.querySelector('[data-dp-header]');

        on(doc, 'click', function (e) {
            var link = e.target.closest ? e.target.closest('a[href^="#"]') : null;
            if (!link) { return; }

            var id = link.getAttribute('href');
            if (!id || id === '#' || id.length < 2) { return; }

            var target = doc.getElementById(id.slice(1));
            if (!target) { return; }

            e.preventDefault();

            var offset = header ? header.offsetHeight + 12 : 0;
            var top = target.getBoundingClientRect().top + window.pageYOffset - offset;

            window.scrollTo({ top: top, behavior: 'smooth' });
            target.setAttribute('tabindex', '-1');
            target.focus({ preventScroll: true });
        });
    }

    /* ------------------------------------------- stats odometer count-up */
    function initCounters() {
        var odos = doc.querySelectorAll('[data-dp-odo]');
        if (!odos.length) { return; }

        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        var DIGITS = '۰۱۲۳۴۵۶۷۸۹';
        var SEP = /[٬٫\/.,:]/;
        var STRIP = 50; /* 5 cycles of 0-9 so every wheel can spin up to 3 turns */

        function make(tag, cls, text) {
            var n = doc.createElement(tag);
            if (cls) { n.className = cls; }
            if (text) { n.textContent = text; }
            return n;
        }

        /* Turn the final text ("+۵۰٬۰۰۰") into static chars + one rolling wheel per digit */
        function build(root) {
            var raw = (root.getAttribute('data-text') || root.textContent || '').replace(/\s+/g, '');
            var text = raw.replace(/[0-9]/g, function (d) { return DIGITS.charAt(+d); });
            var wheels = [];

            root.textContent = '';

            for (var i = 0; i < text.length; i++) {
                var ch = text.charAt(i);
                var digit = DIGITS.indexOf(ch);

                if (digit < 0) {
                    root.appendChild(make('span', 'dps-s' + (SEP.test(ch) ? ' is-sep' : ''), ch));
                    continue;
                }

                var cell = make('span', 'dps-d');
                var win = make('span', 'dps-win');
                var strip = make('span', 'dps-strip');
                for (var k = 0; k < STRIP; k++) {
                    strip.appendChild(make('i', '', DIGITS.charAt(k % 10)));
                }
                win.appendChild(strip);
                cell.appendChild(win);
                root.appendChild(cell);
                wheels.push({ cell: cell, strip: strip, digit: digit });
            }

            if (wheels.length && root.hasAttribute('data-hot')) {
                wheels[wheels.length - 1].cell.classList.add('is-hot');
            }

            root.dpWheels = wheels;
        }

        function roll(root) {
            if (root.getAttribute('data-rolled') === '1') { return; }
            root.setAttribute('data-rolled', '1');

            var item = root.closest ? root.closest('.dps-item') : null;
            if (item) { item.classList.add('is-counted'); }

            var wheels = root.dpWheels || [];
            wheels.forEach(function (w, i) {
                var rank = wheels.length - 1 - i;                    /* 0 = last digit */
                var n = w.digit + 10 * (1 + Math.min(rank, 2));      /* lower digits spin more */

                if (reduce) {
                    w.strip.style.transition = 'none';
                } else {
                    w.strip.style.setProperty('--dur', (1.3 + i * 0.22).toFixed(2) + 's');
                }
                w.strip.style.setProperty('--n', n);
            });
        }

        Array.prototype.forEach.call(odos, build);

        if (!('IntersectionObserver' in window)) {
            Array.prototype.forEach.call(odos, roll);
            return;
        }

        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) { return; }
                roll(entry.target);
                io.unobserve(entry.target);
            });
        }, { threshold: 0.35, rootMargin: '0px 0px -40px 0px' });

        Array.prototype.forEach.call(odos, function (el) { io.observe(el); });
    }
        /* --------------------------------------------- dashboard showcase ----- */
    function initShowcase() {
        var root = doc.querySelector('[data-dp-showcase]');
        var win = root && root.querySelector('.dpm-window');
        if (!win) { return; }

        if (!('IntersectionObserver' in window)) {
            win.classList.add('is-in');
            return;
        }

        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) { return; }
                win.classList.add('is-in');
                io.disconnect();
            });
        }, { threshold: 0.3 });

        io.observe(win);
    }

    /* ------------------------------------------- testimonials infinite slider */
    function initTestimonials() {
        var root = doc.querySelector('[data-dp-testimonials]');
        if (!root) { return; }

        on(root, 'mouseenter', function () { root.classList.add('is-paused'); });
        on(root, 'mouseleave', function () { root.classList.remove('is-paused'); });
        on(root, 'focusin', function () { root.classList.add('is-paused'); });
        on(root, 'focusout', function () { root.classList.remove('is-paused'); });
    }

    function init() {
        var steps = [
            initStickyHeader, initHeaderSearch, initDrawer, initFaq,
            initDomainForms, initDomainChips, initPanelGlow, initDomainResults, initPlans, initNewsletter,
            initSmoothScroll, initCounters, initTestimonials, initFeatures , initShowcase,initQuotes
        ];

        steps.forEach(function (fn) {
            try {
                fn();
            } catch (err) {
                if (window.console && console.error) {
                    console.error('[dp] ' + (fn.name || 'init') + ' failed:', err);
                }
            }
        });
    }

    if (doc.readyState === 'loading') {
        on(doc, 'DOMContentLoaded', init);
    } else {
        init();
    }
}());