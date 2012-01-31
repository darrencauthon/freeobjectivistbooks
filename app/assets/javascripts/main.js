(function ($) {
    $.fn.handleAjax = function (handler) {
    	return this.on({
            "ajax:beforeSend" : function () {
                $(this).find('.loading').spin('medium', '#666');
            },
            "ajax:complete" : function () {
                $(this).find('.loading').spin(false);
            },
            "ajax:success" : handler,
            "ajax:error" : function () {
                alert('Sorry, we hit an unexpected error. Try again or email me at jason@rationalegoist.com for help.');
            },
        });
    };
})(jQuery);
