<div class="sidebar-collapsed">

    {foreach $secondarySidebar as $panel}
        <div class="panel card{if $panel->getClass()}{$panel->getClass()}{else} panel-default{/if}">
            {include file="orderforms/standard_cart/sidebar-categories-selector.tpl"}
        </div>
    {/foreach}


</div>
