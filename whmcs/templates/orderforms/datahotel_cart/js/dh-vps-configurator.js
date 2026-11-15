(function ($) {
    'use strict';

    function labelFor(configId, value) {
        var slider = $('#dhVpsSlider' + configId);
        var name = slider.attr('data-option-name') || '';

        if (name === 'CPU') {
            return value + ' Core';
        }

        return value + ' GB';
    }

    function updateVpsOption(configId, value, recalc) {
        var slider = $('#dhVpsSlider' + configId);
        var input = $('#inputConfigOption' + configId);
        var valueBox = $('#dhVpsValue' + configId);

        if (!slider.length || !input.length) {
            return;
        }

        var min = parseInt(slider.attr('min'), 10);
        var max = parseInt(slider.attr('max'), 10);
        var current = parseInt(value, 10);

        if (isNaN(min)) min = 0;
        if (isNaN(max)) max = min;
        if (isNaN(current)) current = min;

        current = Math.max(min, Math.min(max, current));

        slider.val(current);
        input.val(current);

        if (valueBox.length) {
            valueBox.text(labelFor(configId, current));
        }

        var range = max - min;
        var percent = range > 0
            ? ((current - min) / range) * 100
            : 0;

        slider.css('--dh-vps-progress', percent + '%');

        if (recalc && typeof window.recalctotals === 'function') {
            window.recalctotals();
        }
    }

    function initVpsSliders() {
        $('.dh-vps-slider').each(function () {
            var slider = $(this);
            var configId = slider.attr('data-config-id');
            var input = $('#inputConfigOption' + configId);

            var value = input.length
                ? input.val()
                : slider.val();

            updateVpsOption(configId, value, false);
        });
    }

    $(document).on('input change', '.dh-vps-slider', function () {
        var slider = $(this);
        updateVpsOption(
            slider.attr('data-config-id'),
            slider.val(),
            true
        );
    });

    $(document).on('click', '.dh-vps-step-btn', function (e) {
        e.preventDefault();

        var button = $(this);
        var configId = button.attr('data-config-id');
        var slider = $('#dhVpsSlider' + configId);

        if (!slider.length) {
            return;
        }

        var current = parseInt(slider.val(), 10);
        var min = parseInt(slider.attr('min'), 10);
        var max = parseInt(slider.attr('max'), 10);

        if (isNaN(current)) current = min;
        if (isNaN(min)) min = 0;
        if (isNaN(max)) max = min;

        if (button.attr('data-action') === 'plus') {
            current++;
        } else if (button.attr('data-action') === 'minus') {
            current--;
        }

        updateVpsOption(configId, current, true);
    });

    $(document).ready(function () {
        initVpsSliders();
    });

    $(document).on('change', '#inputConfigOption1, #inputConfigOption2, #inputConfigOption3', function () {
        var id = this.id.replace('inputConfigOption', '');
        updateVpsOption(id, this.value, true);
    });

})(jQuery);
