Text field instavalidate | Spencer Tipping
Licensed under the terms of the MIT source code license

# Introduction

This plugin gives you really easy validation for text fields. For example:

    $('input.zip').instavalidate(/\d{5}(\d{4})?/);
    $('input.name').instavalidate(function (value) {return name.charAt(0) === name.charAt(0).toUpperCase()});

You can also do asynchronous validation:

    $('input.name').instavalidate(function (value, callback) {
      $.getJSON('/names', function (names) {
        callback(names.indexOf(value) > -1);
      });
    });

There aren't race conditions if you do it the asynchronous way; that is, if AJAX call 2 returns before AJAX call 1, AJAX call 1's callback won't overwrite AJAX call 2's validation. (Basically, this
works the way you'd want it to.) Whether or not the component is validated asynchronously, the validator is called with `this` set to the element whose value is being considered.

# Configuration

There are a few options you can set:

    1. className: The CSS class to use to mark a field as invalid. Defaults to 'invalid'.
    2. invalid: A function to be called when the field transitions from valid to invalid. Defaults to null.
    3. valid: A function to be called when the field transitions from invalid to valid. Defaults to null.
    4. delay: How many milliseconds to wait after the last keystroke before validating. Defaults to 0.
    5. immediate: Whether to update on each keystroke. If false, the validation status will be updated only on blur. Defaults to true.

You should use a delay when validating asynchronously; otherwise multiple asynchronous calls will be made concurrently.

    (function ($, undefined) {
      var defaults = {className: 'invalid', invalid: null, valid: null, delay: 0, immediate: true};

      $.fn.instavalidate = function (validator, options) {
        var validate_function = validator.constructor === RegExp ? function (value) {return validator.test(value)} : validator;
        options = $.extend({}, defaults, options || {});

        return this.each(function () {
          var timeout = null, presently_valid = true, asynchronous_counter = 0;
          var validator = function () {
            var self = this, $self = $(this);

            timeout && clearTimeout(timeout);
            timeout = setTimeout(function () {
              timeout = null;

              var asynchronous_id = ++asynchronous_counter;
              var callback        = function (valid) {
                if (asynchronous_id === asynchronous_counter && presently_valid !== (presently_valid = valid))
                  if (presently_valid) {
                    $self.removeClass(options.className);
                    options.valid && options.valid.call(self);
                  } else {
                    $self.addClass(options.className);
                    options.invalid && options.invalid.call(self);
                  }
              };

              var result = validate_function.call(self, $self.val(), callback);
              result === undefined || callback(result);
            }, options.delay);
          };

          var self = $(this);
          self.blur(validator);
          options.immediate && self.keyup(validator);
          options.immediate && validator.call(this);
        });
      };
    })(jQuery);
