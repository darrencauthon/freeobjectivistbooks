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
            "ajax:error" : function (event, request, status, error) {
                var message = 'Sorry, we hit an unexpected error. Try again or email me at jason@rationalegoist.com for help.';
                if (request.getResponseHeader("Content-Type").match("application/json")) {
                    response = JSON.parse(request.responseText);
                    if (response.message) {
                        message = response.message;
                    }
                }
                alert(message);
            }
        });
    };

    $.fn.fadeAndSlide = function (duration) {
        duration = duration || 600
        return this.animate({height: 'toggle', opacity: 'toggle', 'padding-top': 'toggle', 'padding-bottom': 'toggle'}, {duration: duration});
    };
})(jQuery);
