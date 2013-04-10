Additional UI tags for the [hobo_bootstrap theme](https://github.com/Hobo/hobo_bootstrap).  Some of these tags are wrappers for the [bootstrap javascript components](twitter.github.com/bootstrap/javascript.html).  Others are useful tags that are built on top of those javascript components.   It pulls in the [bootstrap-datepicker-rails gem](https://github.com/Nerian/bootstrap-datepicker-rails), and can augment or replace the [hobo_jquery_ui](/plugins/hobo_jquery_ui) theme.

## Installation

    rails generate hobo:install_plugin hobo_bootstrap_ui git://github.com/Hobo/hobo_bootstrap_ui.git

## Documentation

[Tag documentation](http://cookbook.hobocentral.net/api_plugins/hobo_bootstrap_ui)

## Versus hobo_jquery_ui

You can use hobo_bootstrap_ui instead of hobo_jquery_ui if you don't mind the loss of tags such as `<sortable-collection>`.

Alternatively, hobo_bootstrap_ui and hobo_jquery_ui may both be used in the same Hobo application.  In the case of overlap, the plugin loaded last will be used.  Both plugins provide implementations of `<search-results-container>`, `<name-one>` and `<input for="Date">`.  Both plugins have these tags available with non-shadowed names:  `<name-one-bootstrap>` and `<bootstrap-datepicker>` for this gem.

If you use hobo_bootstrap_ui without hobo_jquery_ui, you can also remove jQuery-UI from your `app/assets/javascripts/application.js` as well as associated stylesheets.  If you do this you will lose the ability to position the AJAX spinner and to use hide and show effects during part AJAX.

  [1]: https://github.com/Hobo/hobo_bootstrap_ui/raw/master/screenshots/select_one_or_new.png
