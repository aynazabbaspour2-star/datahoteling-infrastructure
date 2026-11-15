<!-- DH-TEMPLATE-MARKER: DATAHOTEL_STANDARD_CART -->
{include file="orderforms/standard_cart/common.tpl"}


<script>
var _localLang = {
    'addToCart': '{$LANG.orderForm.addToCart|escape}',
    'addedToCartRemove': '{$LANG.orderForm.addedToCartRemove|escape}'
}
</script>

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/standard_cart/sidebar-categories.tpl"}
        </div>
        <div class="cart-body">

            <div class="header-lined">
                <h1 class="font-size-36">{$LANG.orderconfigure}</h1>
            </div>

            {include file="orderforms/standard_cart/sidebar-categories-collapsed.tpl"}

            <form id="frmConfigureProduct">
                <input type="hidden" name="configure" value="true" />
                <input type="hidden" name="i" value="{$i}" />

                <div class="row">
                    <div class="secondary-cart-body">

                        <p>{$LANG.orderForm.configureDesiredOptions}</p>

                        <div class="product-info">
                            <p class="product-title">{$productinfo.name}</p>
                            <p>{$productinfo.description}</p>
                        </div>

                        <div class="alert alert-danger w-hidden" role="alert" id="containerProductValidationErrors">
                            <p>{$LANG.orderForm.correctErrors}:</p>
                            <ul id="containerProductValidationErrorsList"></ul>
                        </div>

                        {if $pricing.type eq "recurring"}
                            <div class="field-container">
                                <div class="form-group">
                                    <label for="inputBillingcycle">{$LANG.cartchoosecycle}</label>
                                    <br>
                                    <select name="billingcycle" id="inputBillingcycle" class="form-control select-inline custom-select" onchange="updateConfigurableOptions({$i}, this.value); return false">
                                        {if $pricing.monthly}
                                            <option value="monthly"{if $billingcycle eq "monthly"} selected{/if}>
                                                {$pricing.monthly}
                                            </option>
                                        {/if}
                                        {if $pricing.quarterly}
                                            <option value="quarterly"{if $billingcycle eq "quarterly"} selected{/if}>
                                                {$pricing.quarterly}
                                            </option>
                                        {/if}
                                        {if $pricing.semiannually}
                                            <option value="semiannually"{if $billingcycle eq "semiannually"} selected{/if}>
                                                {$pricing.semiannually}
                                            </option>
                                        {/if}
                                        {if $pricing.annually}
                                            <option value="annually"{if $billingcycle eq "annually"} selected{/if}>
                                                {$pricing.annually}
                                            </option>
                                        {/if}
                                        {if $pricing.biennially}
                                            <option value="biennially"{if $billingcycle eq "biennially"} selected{/if}>
                                                {$pricing.biennially}
                                            </option>
                                        {/if}
                                        {if $pricing.triennially}
                                            <option value="triennially"{if $billingcycle eq "triennially"} selected{/if}>
                                                {$pricing.triennially}
                                            </option>
                                        {/if}
                                    </select>
                                </div>
                            </div>
                        {/if}

                        {if count($metrics) > 0}
                            <div class="sub-heading">
                                <span class="primary-bg-color">{$LANG.metrics.title}</span>
                            </div>

                            <p>{$LANG.metrics.explanation}</p>

                            <ul>
                                {foreach $metrics as $metric}
                                    <li>
                                        {$metric.displayName}
                                        -
                                        {if count($metric.pricing) > 1}
                                            {$LANG.metrics.startingFrom} {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                            <button type="button" class="btn btn-default btn-sm" data-toggle="modal" data-target="#modalMetricPricing-{$metric.systemName}">
                                                {$LANG.metrics.viewPricing}
                                            </button>
                                        {elseif count($metric.pricing) == 1}
                                            {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                            {if $metric.includedQuantity > 0} ({$metric.includedQuantity} {$LANG.metrics.includedNotCounted}){/if}
                                        {/if}
                                        {include file="$template/usagebillingpricing.tpl"}
                                    </li>
                                {/foreach}
                            </ul>

                            <br>
                        {/if}

                        {if $productinfo.type eq "server"}
                            <div class="sub-heading">
                                <span class="primary-bg-color">{$LANG.cartconfigserver}</span>
                            </div>

                            <div class="field-container">

                                <div class="row">
                                    <div class="col-sm-6">
                                        <div class="form-group">
                                            <label for="inputHostname">{$LANG.serverhostname}</label>
                                            <input type="text" name="hostname" class="form-control" id="inputHostname" value="{$server.hostname}" placeholder="servername.example.com">
                                        </div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="form-group">
                                            <label for="inputRootpw">{$LANG.serverrootpw}</label>
                                            <input type="password" name="rootpw" class="form-control" id="inputRootpw" value="{$server.rootpw}">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-sm-6">
                                        <div class="form-group">
                                            <label for="inputNs1prefix">{$LANG.serverns1prefix}</label>
                                            <input type="text" name="ns1prefix" class="form-control" id="inputNs1prefix" value="{$server.ns1prefix}" placeholder="ns1">
                                        </div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="form-group">
                                            <label for="inputNs2prefix">{$LANG.serverns2prefix}</label>
                                            <input type="text" name="ns2prefix" class="form-control" id="inputNs2prefix" value="{$server.ns2prefix}" placeholder="ns2">
                                        </div>
                                    </div>
                                </div>

                            </div>
                        {/if}

                        {if $configurableoptions}
                            <div class="sub-heading">
                                <span class="primary-bg-color">{$LANG.orderconfigpackage}</span>
                            </div>
                            <div class="product-configurable-options" id="productConfigurableOptions">
                                <div class="row">
                                    {foreach $configurableoptions as $num => $configoption}
                                    {if $configoption.optiontype eq 1}
                                        {assign var="dhInitialQty" value=$configoption.selectedqty}
                                        {if !$dhInitialQty}
                                            {assign var="dhInitialQty" value=$configoption.qtyminimum}
                                        {/if}

                                        <div class="col-sm-6">
                                            <div class="dh-vps-config-card">

                                                <div class="dh-vps-config-head">
                                                    <div class="dh-vps-config-title-wrap">
                                                        <span class="dh-vps-config-icon">
                                                            {if $configoption.optionname eq "CPU"}
                                                                CPU
                                                            {elseif $configoption.optionname eq "RAM"}
                                                                RAM
                                                            {else}
                                                                SSD
                                                            {/if}
                                                        </span>

                                                        <span class="dh-vps-config-title">
                                                            {$configoption.optionname}
                                                        </span>
                                                    </div>

                                                    <strong
                                                        class="dh-vps-config-value"
                                                        id="dhVpsValue{$configoption.id}">
                                                        {$dhInitialQty}
                                                        {if $configoption.optionname eq "CPU"} Core
                                                        {elseif $configoption.optionname eq "RAM"} GB
                                                        {elseif $configoption.optionname eq "Storage"} GB
                                                        {/if}
                                                    </strong>
                                                </div>

                                                <input
                                                    type="range"
                                                    class="dh-vps-slider"
                                                    id="dhVpsSlider{$configoption.id}"
                                                    min="0"
                                                    max="{$configoption.options|@count-1}"
                                                    step="1"
                                                    value="0"
                                                    data-config-id="{$configoption.id}"
                                                    data-option-name="{$configoption.optionname}"
                                                >

                                                <div class="dh-vps-slider-meta">
                                                    <span>
                                                        {$configoption.options.0.name}
                                                    </span>

                                                    <span>
                                                        {$configoption.options[$configoption.options|@count-1].name}
                                                    </span>
                                                </div>

                                                <div class="dh-vps-stepper">

                                                    <button
                                                        type="button"
                                                        class="dh-vps-step-btn"
                                                        data-action="minus"
                                                        data-config-id="{$configoption.id}">
                                                        −
                                                    </button>

                                                    <span class="dh-vps-step-hint">
                                                        مقدار موردنظر را انتخاب کنید
                                                    </span>

                                                    <button
                                                        type="button"
                                                        class="dh-vps-step-btn"
                                                        data-action="plus"
                                                        data-config-id="{$configoption.id}">
                                                        +
                                                    </button>

                                                </div>

                                                <select
                                                    name="configoption[{$configoption.id}]"
                                                    id="inputConfigOption{$configoption.id}"
                                                    style="display:none;"
                                                >
                                                    {foreach key=dhNum item=dhOption from=$configoption.options}
                                                        <option
                                                            value="{$dhOption.id}"
                                                            {if $configoption.selectedvalue eq $dhOption.id}selected="selected"{/if}
                                                        >{$dhOption.name}</option>
                                                    {/foreach}
                                                </select>

                                            </div>
                                        </div>

                                    {elseif $configoption.optiontype eq 2}
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label>
                                                {foreach key=num2 item=options from=$configoption.options}
                                                    <br />
                                                    <label>
                                                        <input type="radio" name="configoption[{$configoption.id}]" value="{$options.id}"{if $configoption.selectedvalue eq $options.id} checked="checked"{/if} />
                                                        {if $options.name}
                                                            {$options.name}
                                                        {else}
                                                            {$LANG.enable}
                                                        {/if}
                                                    </label>
                                                {/foreach}
                                            </div>
                                        </div>
                                    {elseif $configoption.optiontype eq 3}
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label>
                                                <br />
                                                <label>
                                                    <input type="checkbox" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="1"{if $configoption.selectedqty} checked{/if} />
                                                    {if $configoption.options.0.name}
                                                        {$configoption.options.0.name}
                                                    {else}
                                                        {$LANG.enable}
                                                    {/if}
                                                </label>
                                            </div>
                                        </div>
                                    {elseif $configoption.optiontype eq 4}
                                        <div class="col-sm-12">
                                            <div class="form-group">
                                                <label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label>
                                                {if $configoption.qtymaximum}
                                                {if !$rangesliderincluded}
                                                    <script type="text/javascript" src="{$BASE_PATH_JS}/ion.rangeSlider.min.js"></script>
                                                <link href="{$BASE_PATH_CSS}/ion.rangeSlider.css" rel="stylesheet">
                                                <link href="{$BASE_PATH_CSS}/ion.rangeSlider.skinModern.css" rel="stylesheet">
                                                    {assign var='rangesliderincluded' value=true}
                                                {/if}
                                                    <input type="text" name="configoption[{$configoption.id}]" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}" id="inputConfigOption{$configoption.id}" class="form-control" />
                                                    <script>
                                                        var sliderTimeoutId = null;
                                                        var sliderRangeDifference = {$configoption.qtymaximum} - {$configoption.qtyminimum};
                                                        // The largest size that looks nice on most screens.
                                                        var sliderStepThreshold = 25;
                                                        // Check if there are too many to display individually.
                                                        var setLargerMarkers = sliderRangeDifference > sliderStepThreshold;

                                                        jQuery("#inputConfigOption{$configoption.id}").ionRangeSlider({
                                                            min: {$configoption.qtyminimum},
                                                            max: {$configoption.qtymaximum},
                                                            grid: true,
                                                            grid_snap: setLargerMarkers ? false : true,
                                                            onChange: function() {
                                                                if (sliderTimeoutId) {
                                                                    clearTimeout(sliderTimeoutId);
                                                                }

                                                                sliderTimeoutId = setTimeout(function() {
                                                                    sliderTimeoutId = null;
                                                                    recalctotals();
                                                                }, 250);
                                                            }
                                                        });
                                                    </script>
                                                {else}
                                                    <div>
                                                        <input type="number" name="configoption[{$configoption.id}]" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}" id="inputConfigOption{$configoption.id}" min="{$configoption.qtyminimum}" onchange="recalctotals()" onkeyup="recalctotals()" class="form-control form-control-qty" />
                                                        <span class="form-control-static form-control-static-inline">
                                                                x {$configoption.options.0.name}
                                                            </span>
                                                    </div>
                                                {/if}
                                            </div>
                                        </div>
                                    {/if}
                                    {if $num % 2 != 0}
                                </div>
                                <div class="row">
                                    {/if}
                                    {/foreach}
                                </div>
                            </div>

                        {/if}

                        {if $customfields}

                            <div class="sub-heading pb-1">
                                <span class="primary-bg-color">{$LANG.orderadditionalrequiredinfo}<br><i><small>{lang key='orderForm.requiredField'}</small></i></span>
                            </div>

                            <div class="field-container">
                                {foreach $customfields as $customfield}
                                    <div class="form-group">
                                        <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                                        {$customfield.input}
                                        {if $customfield.description}
                                            <span class="field-help-text">
                                                {$customfield.description}
                                            </span>
                                        {/if}
                                    </div>
                                {/foreach}
                            </div>

                        {/if}

                        {if $addons || count($addonsPromoOutput) > 0}

                            <div id="productAddonsContainer">
                                <div class="sub-heading">
                                    <span class="primary-bg-color">{$LANG.cartavailableaddons}</span>
                                </div>

                                {foreach $addonsPromoOutput as $output}
                                    <div>
                                        {$output}
                                    </div>
                                {/foreach}

                                <div class="row addon-products">
                                    {foreach $addons as $addon}
                                        <div class="col-sm-{if count($addons) > 1}6{else}12{/if}">
                                            <div class="panel card panel-default panel-addon{if $addon.status} panel-addon-selected{/if}">
                                                <div class="panel-body card-body">
                                                    <label>
                                                        <input type="checkbox" name="addons[{$addon.id}]"{if $addon.status} checked{/if} />
                                                        {$addon.name}
                                                    </label><br />
                                                    {$addon.description}
                                                </div>
                                                <div class="panel-price">
                                                    {$addon.pricing}
                                                </div>
                                                <div class="panel-add">
                                                    <i class="fas fa-plus"></i>
                                                    {$LANG.addtocart}
                                                </div>
                                            </div>
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        {/if}

                        <div class="alert alert-warning info-text-sm">
                            <i class="fas fa-question-circle"></i>
                            {$LANG.orderForm.haveQuestionsContact} <a href="{$WEB_ROOT}/contact.php" target="_blank" class="alert-link">{$LANG.orderForm.haveQuestionsClickHere}</a>
                        </div>

                    </div>
                    <div class="secondary-cart-sidebar" id="scrollingPanelContainer">

                        <div id="orderSummary">
                            <div class="order-summary">
                                <div class="loader" id="orderSummaryLoader">
                                    <i class="fas fa-fw fa-sync fa-spin"></i>
                                </div>
                                <h2 class="font-size-30">{$LANG.ordersummary}</h2>
                                <div class="summary-container" id="producttotal"></div>
                            </div>
                            <div class="text-center">
                                <button type="submit" id="btnCompleteProductConfig" class="btn btn-primary btn-lg">
                                    {$LANG.continue}
                                    <i class="fas fa-arrow-circle-right"></i>
                                </button>
                            </div>
                        </div>

                    </div>

                </div>

            </form>
        </div>
    </div>
</div>

<script>recalctotals();</script>

{include file="orderforms/standard_cart/recommendations-modal.tpl"}


<style>
/* =========================================================
   DataHoteling VPS Configurator
   ========================================================= */

.dh-vps-config-card {
    position: relative;
    margin: 0 0 18px;
    padding: 20px 20px 16px;
    background: linear-gradient(145deg, #ffffff 0%, #f5f9ff 100%);
    border: 1px solid #dbe7f7;
    border-radius: 16px;
    box-shadow: 0 8px 24px rgba(25, 93, 170, .08);
    direction: rtl;
    transition: all .2s ease;
}

.dh-vps-config-card:hover {
    border-color: #8db8ef;
    box-shadow: 0 10px 28px rgba(25, 93, 170, .13);
    transform: translateY(-1px);
}

.dh-vps-config-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 18px;
}

.dh-vps-config-title-wrap {
    display: flex;
    align-items: center;
    gap: 10px;
}

.dh-vps-config-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 42px;
    height: 32px;
    padding: 0 9px;
    border-radius: 9px;
    background: #e8f2ff;
    color: #1769d2;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .4px;
}

.dh-vps-config-title {
    font-size: 16px;
    font-weight: 800;
    color: #18324f;
}

.dh-vps-config-value {
    font-size: 18px;
    color: #1167d8;
    white-space: nowrap;
}

.dh-vps-slider {
    display: block !important;
    width: 100% !important;
    height: 30px !important;
    margin: 10px 0 15px !important;
    padding: 0 !important;
    appearance: auto !important;
    -webkit-appearance: auto !important;
    cursor: pointer !important;
    opacity: 1 !important;
    visibility: visible !important;
}

.dh-vps-slider-meta {
    display: flex;
    justify-content: space-between;
    direction: ltr;
    color: #7b8da3;
    font-size: 11px;
    margin-bottom: 13px;
}

.dh-vps-stepper {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    direction: ltr;
}

.dh-vps-step-btn {
    width: 31px;
    height: 31px;
    border: 1px solid #cfe0f5;
    border-radius: 9px;
    background: #fff;
    color: #126bd5;
    font-size: 20px;
    line-height: 1;
    cursor: pointer;
    transition: all .15s ease;
}

.dh-vps-step-btn:hover {
    background: #eaf4ff;
    border-color: #8db8ef;
}

.dh-vps-step-hint {
    flex: 1;
    text-align: center;
    color: #91a0b2;
    font-size: 11px;
    direction: rtl;
}

.dh-vps-native-select {
    display: none !important;
}

@media (max-width: 767px) {
    .dh-vps-config-card {
        padding: 17px 15px;
    }

    .dh-vps-config-title {
        font-size: 15px;
    }

    .dh-vps-config-value {
        font-size: 16px;
    }
}




</style>

<script>
(function () {

    if (window.__dhVpsConfiguratorLoaded) {
        return;
    }

    window.__dhVpsConfiguratorLoaded = true;

    function getData(slider) {
        var select = document.getElementById(
            "inputConfigOption" + slider.getAttribute("data-config-id")
        );

        var valueBox = document.getElementById(
            "dhVpsValue" + slider.getAttribute("data-config-id")
        );

        if (!select || !valueBox) {
            return null;
        }

        return {
            select: select,
            valueBox: valueBox
        };
    }

    function syncSlider(slider, recalc) {

        var data = getData(slider);

        if (!data) {
            return;
        }

        var index = parseInt(slider.value, 10);

        if (isNaN(index)) {
            index = 0;
        }

        var options = data.select.options;

        if (!options.length) {
            return;
        }

        if (index < 0) {
            index = 0;
        }

        if (index >= options.length) {
            index = options.length - 1;
        }

        slider.value = index;

        var option = options[index];

        if (!option) {
            return;
        }

        data.select.value = option.value;

        data.valueBox.textContent =
            option.textContent.trim();

        var max = parseInt(slider.max, 10) || 1;

        var percent = max > 0
            ? (index / max) * 100
            : 0;

        slider.style.setProperty(
            "--dh-vps-progress",
            percent + "%"
        );

        if (
            recalc &&
            typeof window.recalctotals === "function"
        ) {
            window.recalctotals();
        }
    }

    function initializeSliders() {

        document
            .querySelectorAll(".dh-vps-slider")
            .forEach(function (slider) {

                var data = getData(slider);

                if (!data) {
                    return;
                }

                var selectedIndex = -1;

                for (
                    var i = 0;
                    i < data.select.options.length;
                    i++
                ) {
                    if (
                        data.select.options[i].selected
                    ) {
                        selectedIndex = i;
                        break;
                    }
                }

                if (selectedIndex < 0) {
                    selectedIndex = 0;
                }

                slider.value = selectedIndex;

                syncSlider(slider, false);
            });
    }

    /*
     * Delegated slider event.
     * Works even when WHMCS replaces the configurator HTML.
     */
    document.addEventListener(
        "input",
        function (event) {

            var slider = event.target.closest(
                ".dh-vps-slider"
            );

            if (!slider) {
                return;
            }

            syncSlider(slider, true);
        }
    );

    document.addEventListener(
        "change",
        function (event) {

            var slider = event.target.closest(
                ".dh-vps-slider"
            );

            if (!slider) {
                return;
            }

            syncSlider(slider, true);
        }
    );

    /*
     * Delegated +/- buttons.
     */
    document.addEventListener(
        "click",
        function (event) {

            var button = event.target.closest(
                ".dh-vps-step-btn"
            );

            if (!button) {
                return;
            }

            event.preventDefault();

            var configId =
                button.getAttribute("data-config-id");

            var slider = document.getElementById(
                "dhVpsSlider" + configId
            );

            if (!slider) {
                return;
            }

            var current =
                parseInt(slider.value, 10) || 0;

            if (
                button.getAttribute("data-action") ===
                "plus"
            ) {
                current++;
            } else {
                current--;
            }

            var max = parseInt(slider.max, 10) || 0;
            var min = parseInt(slider.min, 10) || 0;

            if (current < min) {
                current = min;
            }

            if (current > max) {
                current = max;
            }

            slider.value = current;
            syncSlider(slider, true);
        }
    );

    /*
     * Initial load.
     */
    if (
        document.readyState === "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            initializeSliders
        );
    } else {
        initializeSliders();
    }

})();
</script>

