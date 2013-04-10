Hobo 2.0 Changes
{: .document-title}

Documents the changes made in Hobo 2.0 and the changes required to
migrate applications to Hobo 2.0

Contents
{: .contents-heading}

- contents
{:toc}

# Installation

    Meta tags:  note for collaborators.   A meta-tag looks like this {.done}.   It's added after a paragraph with no blank spaces.   The tags that we support are:  {.ruby} {.javascript} {.dryml} and {.diff} for code highlighting.   {.todo}, {.done}, {.check}, {.part} and {.nomove} indicate documentation progress moving into the Hobo manuals.  {.check} means that it's probably done.  {.part} means that it's partly done.  {.nomove} means that this section only needs to exist in this CHANGES document.   Finally, {.hidden} is used for paragraphs like this one that shouldn't show up on the website.
{.hidden}

## Creating a new application
{.part}

Final hobo 2.0 gems have not yet been released, so the standard instructions
of "gem install hobo; hobo new foo" do not yet work.

If you're on Linux you'll have to install a javascript runtime.
On Ubuntu 11.10 you can get one by typing `apt-get install
nodejs-dev`.  Other Linuxes should be similar.  Windows & OS X users
should already have a javascript scripting host installed.  The list
of compatible javascript runtimes is
[here](https://github.com/sstephenson/execjs).

To install prerelease versions of Hobo, you have three options: gems
from rubygems, gems from source or pointing your Gemfile at hobo
source.

### Via gems from rubygems.org

    gem install hobo --pre
    hobo new foo

### Via gems from source

    git clone git://github.com/tablatom/hobo
    cd hobo
    rake gems[install]
    cd wherever-you-want-to-generate-your-app
    hobo new foo

Once you've generated an app, you may wish to go in and replace the
version strings for the hobo_* gems with `:git => "git://github.com/tablatom/hobo"`

### Via source path

(This won't work on Windows)

    git clone git://github.com/tablatom/hobo
    export HOBODEV=`pwd`/hobo
    cd wherever-you-want-to-generate-your-app
    $HOBODEV/hobo/bin/hobo new foo

## Updating a Hobo 1.3 application
{.nomove}

Many of the changes required in upgrading a Hobo 1.3 application are necessitated by the switch from Rails 3.0 to 3.2.  [Railscasts has a good guide to upgrading to Rails 3.1](railscasts.com/episodes/282-upgrading-to-rails-3-1).

There are several changes that need to be made to your application to
upgrade from Hobo 1.3 to Hobo 2.0.   Most of these changes are
required by the addition of the asset pipeline which was introduced in
Rails 3.1.

Follow the asset pipeline upgrade steps outlined here:
http://guides.rubyonrails.org/asset_pipeline.html#upgrading-from-old-versions-of-rails

The easiest way to upgrade an existing Hobo 1.3 application is to
generate a new Hobo 2.0 application and copy differences from the new
app into your existing app.

### Gemfile

You'll need to add the gems required for the asset pipeline, add the
jquery-rails and jquery-ui-themes gem, and adjust the version numbers
for rails, hobo and perhaps others.

Hobo has also gained several additional gems, so you will have to add
dependencies for those.  hobo_rapid is the Hobo tag library,
hobo_jquery is the javascript for hobo_rapid, and hobo_clean is the
default theme.   Instead of or as well as hobo_clean you can use
hobo_clean_admin or hobo_clean_sidemenu or hobo_bootstrap.

You will also have to ensure that you are using Hobo's fork of will_paginate:

    gem "will_paginate", :git => "git://github.com/Hobo/will_paginate.git"

### config/

Most the changes in config/ are due to the assets pipeline.  See
http://guides.rubyonrails.org/asset_pipeline.html#upgrading-from-old-versions-of-rails

In addition, you will probably want to add:

    config.hobo.dont_emit_deprecated_routes = true

to your config/application.rb.   See the [named routes section in this document](#named_routes_names_changed_to_use_standard_rails_names) for more details.

You will also want to add

    config.watchable_dirs[File.join(config.root, 'app/view')] = ['dryml']

to your config/environments/development.rb

### application.dryml or front_site.dryml

Replace

    <set-theme name="clean"/>
{.dryml}

with

    <include gem='hobo_rapid'/>
    <include gem='hobo_jquery'/>
    <include gem='hobo_jquery_ui'/>
    <include gem='hobo_clean'/>
{.dryml}

Note that the default Hobo generation now always creates both a
front_site.dryml and an application.dryml, even if you don't create
any subsites.

Also be aware that application.dryml is no longer loaded automatically
if you have a front_site.dryml.    Add

    <include src="application" />
{.dryml}

to your front_site.dryml, your admin_site.dryml, et cetera.

### move public/ to app/assets/
{.todo}

In Rails 3.1, images, javascripts and stylesheets are loaded from
app/assets/ rather than from public/ so you'll have to move them.
Note that the following are Rails and/or Hobo assets that are now
included via the pipeline and can be deleted rather than moved:

    images/rails.png
    hobothemes/**
    javascripts/controls.js,dryml-support.js,hobo-rapid.js,ie7-recalc.js,prototype.js,blank.gif,dragdrop.js,effects.js,IE7.js,lowpro.js,rails.js
    stylesheets/reset.css,hobo-rapid.css

You can organize your app/assets directory however you like, but you
probably should arrange it the way Hobo does, the install_plugin
generator expects it.

If you generate a new Hobo 2.0 application with the front site named "front" and an additional admin subsite named admin, it will put these in app/assets/javascripts:

    application.js
    application/
    front.js
    front/
    admin.js
    admin/

Application.js loads any rails plugins and then everything in the
application/ directory. Front.js loads application.js, then any hobo
plugins you've installed and then everything in the front/ directory.
Admin.js behaves similarly. Hobo views in the front subsite load
front.js and Hobo views in the admin subsite load admin.js.

app/assets/stylesheets is organized in a similar manner.

# Changes from Hobo 1.3 & hobo-jquery 1.3

## Javascript framework changed to jQuery
{.nomove}

Hobo 1.3 and earlier versions used prototype.js for its Ajax support.
In Hobo 2.0 all of our javascript code has been rewritten to use
jQuery instead of prototype.js.

In the process of rewriting the code many tags have been updated to
add AJAX support, and tags that used non-standard AJAX mechanisms have
been updated to use standard Hobo form AJAX.   The most visible of
these changes have been to the editors.

## The Asset Pipeline
{.todo}

we should create a (small) chapter on the Hobo asset pipeline layout.  see above (move public/ to app/assets/)
{.hidden}

Hobo 2.0 uses the asset pipeline features introduced in Rails 3.1.
Hobo 2.0 does not work out of the box with the asset pipeline turned
off.  It'd certainly be possible to copy all Hobo assets into public/,
but you would have to do so manually, there are no longer any rake
tasks to do this for you.

## application.dryml is no longer loaded automatically
{.todo}

Hobo 1.3 loaded application.dryml and then X_site.dryml, where X was
front or admin or the name of the current subsite.  Hobo 2.0 only
loads X_site.dryml.   If that fails, it loads application.dryml
instead.

A new application generated by Hobo 2.0 will have `<include
src="application"/>` in X_site.dryml so that application.dryml is
still loaded.   When it is loaded is now controlled by the the author
rather than always loading first.

## :inverse_of recommended
{.todo}

For correct behaviour, please ensure that all accessible associations
have their :inverse_of option set in both directions.

## set-theme deprecated
{.nomove}

The old Hobo theme support has never worked well, and has been
replaced.   Themes are now Hobo plugins and work like every other Hobo
2.0 plugin.

Replace:

    <set-theme name="clean"/>
{.dryml}

with

    <include gem="hobo_clean"/>
{.dryml}

and add

    *= require hobo_clean

to your app/assets/stylesheets/front.css.  Some themes may also
include javascript which would require them to be added to front.js as
well.

## default doctype changed
{.nomove}

The default doctype has been changed from `XHTML 1.0 TRANSITIONAL` to
`html`, also known as "standards mode" in Internet Explorer 8 and 9
and "html5" in other browsers.

## named routes' names changed to use standard Rails names
{.nomove}

The names of named routes generated by Hobo have changed to more
closely match the default names generated by the Rails REST route
generator. The standard 7 REST routes have not changed, but some
additional routes such as nested routes and lifecycle routes have been
renamed.

For the moment you can ask Hobo to emit both the new style and old
style routes by not defining
`config.hobo.dont_emit_deprecated_routes`.

Note that paths and method names have not changed, only the named
route has changed, so this change should not be visible to the user or
impact controller code.

The route name is leftmost column in `rake routes`.

Here are some example changes:

    create_task_path           => create_tasks_path       # tasks#create
    create_task_for_story_path => create_story_tasks_path # tasks#create_for_story
    foo_transition_path        => transition_foo_path     # foos lifecycle transition
    foo_show2_path             => show2_foo_path          # show_action :show2 in foos_controller

Note that in the second example, create_story_tasks_path, the
controller method name is `create_for_story`. This is the same method
name that Hobo 1.0 and 1.3 use; the default Rails method name would be
just plain `create`.

There are several named routes used in the user_mailer views generated
in a new application. These must be fixed up when upgrading an old
application. For instance, user_activate_url must be changed to
activate_user_url in activation.erb.

In exchange for the pain of updating some of your named routes, we
receive the following benefits:

- polymorphic_url works with nested routes and in more situations

- url_for will work in more situations

- the `<a>` tag and the many tags which use it now accept all the
  `url_for` options, such as host and port.

- hobo_routes.rb is easier to read and understand

- code reduction in Hobo

## `remote-method-button` and `update-button` AJAX functionality removed
{.nomove}

`remote-method-button`, `update-button` and similar buttons such as
`delete-button` were written early in the history of Hobo, before
standard form/part ajax was supported. These tags are easy to replace
with the much more flexible forms.

For backwards compatibility, most of these buttons have been updated
to 2.0. However, the little used `remote-method-button` and
`update-button` have not been converted to support Hobo 2.0 AJAX.

## default field-list changed
{.nomove}

The default for `<field-list>` has changed to `<feckless-fieldset>`.
The old behaviour is still available in `<field-list-v1>`.

## Chronic patches removed.

HoboSupport's patches to Chronic have been removed because they are not
supported in Ruby 2.0.0.

## rapid_summary tags removed

The rapid\_summary tags have been moved out of core Hobo into their own plugin, https://github.com/Hobo/hobo_summary, which is not yet in a working state

## Helper rearrangement
{.todo}

In previous versions of Hobo, all Hobo helpers were available in both
the controllers and the views.   In this version, some helpers are
only available in the views.   If there is a helper function that you
need to access in your controller, you can call in your controller:

    HoboTypeHelper.add_to_controller(self)

Other Helper classes not included in the controller by default are
HoboDebugHelper, HoboDeprecatedHelper and HoboViewHintHelper.

Several helpers have been moved into
app/helpers/hobo_deprecated_helper.rb

If your application depends on any of these, you can set
config.hobo.include_deprecated_helper.

## Rails 3.2 required

Hobo 2.0 currently requires Rails 3.2 for operation.

## Editors
{.todo}

Editors are no longer special-cased, they now use the standard DRYML
part mechanism.

There are two types of editors: `<click-editor>` and `<live-editor>`.
click-editor is the click-to-edit type of control similar to what
Rapid currently uses for a string, and live-editor always renders the
input, and is similar to what Rapid currently uses for Boolean's and
enum-strings.

Please refer to the documentation for `click-editor` and `live-editor`
for more details.

`<editor>` is now a polymorphic input that uses either `<click-editor>` or
`<live-editor>`.

TBD: Right now live-editor and click-editor use `<formlet>`.  The
major advantage of formlet is that it is safe to use inside of a form.
I can't think of any good use cases for that behaviour, but it does
seem like something people might do by accident.

The alternative is to use `<form>`.   Since this implementation of
editor starts with an input and switches to a view via Javascript,
using a form would allow reasonable javascript-disabled behaviour.

## Attribute Whitelist
{.todo}

Rails 3.2.3 and later changed the default for config.whitelist_attributes to true, so any newly generated Hobo apps will have this feature turned on.  Hobo heavily depends on mass attribute assignation, so this may cause inconveniences.

Mass assignment protection is redundant in Hobo: your primary protection should come through the edit_permitted? function.   If all of your models have properly defined edit_permitted? then it is safe to turn off config.whitelist_attributes.

If you choose not to turn off config.whitelist_attributes, any fields that are not in your attr_accessible declaration will not be available in forms.   Hobo's generators will now assist in the creation of attr_accessible declarations.

## Enhancements

### Nested caching
{.done}

See the docs for `<nested-cache>` and the [caching-tutorial](/tutorials/caching).

### push-state
{.done}

AJAX now supports a new AJAX option 'push-state' if you have
History.js installed.   It was inspired by [this
post](http://37signals.com/svn/posts/3112-how-basecamp-next-got-to-be-so-damn-fast-without-using-much-client-side-ui)
which uses push-state and fragment caching to create a very responsive
rails application.    Hobo has always supported fragment caching
through Rails, but push-state support is new.

The easiest way to install History.js is to use the [jquery-historyjs](https://github.com/wweidendorf/jquery-historyjs)
gem.  Follow the instructions in the [README at the
link](https://github.com/wweidendorf/jquery-historyjs).

push-state blurs the line between AJAX and non-AJAX techniques,
bringing the advantages of both to the table.   It's considerably more
responsive than a page refresh, yet provides allows browser bookmarks
and history navigation to work correctly.

For example, if the foos and the bars pages have exactly the same
headers but different content, you can speed up links between the
pages by only refreshing the content:

    <%# foos/index.dryml %>
    <index-page>
      <content:>
        <do part="content">
          <a href="&bars_page" ajax push-state new-title="Bars">Bars</a>
          ...
        </do>
      </content:>
    <index-page>

Note to Hobo 1.3 users: We're using the new `ajax` attribute instead of
`update="content"` because the link is inside the part.  Outside of the
part we'd use `update="content"` instead of `ajax`.

The `new-title` attribute may be used with push state to update the
title.  If you want to update any other section in your headers, you
can put that into a part and list it in the update list as well.
However the new page cannot have new javascript or stylesheets.
Avoiding the refresh of these assets is one of the major reasons to
use push-state!

push-state is well suited for tasks that refreshed the current page
with new query parameters in Hobo 1.3, like `filter-menu`, pagination and
sorting on a `table-plus`.  Thus these tags have been updated to
support all of the standard ajax attributes.

Of course, ajax requests that update only a small portion of the page
will update faster than those that update most of the page.   However,
a small update may mean that a change to the URL is warranted, so you
may want to use standard Ajax rather than push-state in those cases.
Also, push-state generally should not be used for requests that modify
state

push-state works best in an HTML5 browser.  It works in older browsers
such as IE8, IE9 or Firefox 3, but results in strange looking URL's.   See
the README for History.js for more details on that behaviour.

### turbolinks support

[turbolinks](https://github.com/rails/turbolinks) provides capabilities similar to the push-state fragment Ajax described above.  However, rather than updating fragments, it updates the entire page.   This makes it slightly slower but does not require any code modification.

Turbolinks is not compatible with the [bottom-load-javascript](http://cookbook-1.4.hobocentral.net/manual/changes20#bottomloading_javascript) option.

### plugin generators
{.part}

Hobo has gained two new generators.

`hobo generate install_plugin` may be used from inside a Hobo
application to install a Hobo plugin.   It modifies the Gemfile,
application.dryml or X_site.dryml and adds the plugin to
app/assets/javascripts and app/assets/stylesheets.

`hobo plugin` is used from outside of a Hobo application to create the
skeleton for a new plugin.   See [the plugin manual page](FIXME) for
more details.

### multiple parts
{.todo}

I've updated DRYML so that it emits a different DOM ID if you
re-instantiate a part.  (The first use of a part retains the DOM
ID=partname convention for backwards compatibility) "update=" requires
a DOM ID, so I've also added 2 new AJAX attributes that can be used
instead of "update=".

The first one is "updates=".  Instead of a comma separated list of DOM
ID's, it takes a CSS selector.

The other one is "ajax".  If used inside of a part, it indicates that
the containing part should be updated.  If used outside of a part,
AJAX will be used but no parts will be updated.

These three Ajax attributes may be used simultaneously.

Example:

    <collection:stories>
       <div part="inner">
          <form ajax>
             <input:title/>
          </form>
       </div>
     </collection>

### Bottom-loading Javascript
{.todo}

The `<page>` tag has a new attribute: `bottom-load-javascript`. If
set, Javascript is loaded via a deferred load at the bottom of the
body rather than being loaded conventionally in the head.

You probably want to enable this globally in your application by
adding this to your application.dryml:

    <extend tag="page">
      <old-page bottom-load-javascript merge/>
    </extend>

Note that if this option is set, the custom-scripts parameter is no
longer available. There is a new parameter called custom-javascript
that can be used instead, though.

Replace:

    <custom-scripts:>
      <script type="text/javascript">
        $(document).ready(function() {
          alert('hi');
        });
      </script>
    </custom-scripts:>

with:

    <custom-javascript:>
      alert('hi');
    </custom-javascript:>

If you wish to be compatible with both top & bottom loading use:

    <custom-javascript:>
      $(document).read(function() {
        alert('hi');
      })
    </custom-javascript:>

If you were previously loading files via custom-scripts, use the asset
pipeline instead.

Turning on bottom-load will prevent Rails from splitting front.js into
multiple files even if you enable config.assets.debug in your
environment.

bottom-load-javascript is incompatible with turbolinks.

### allowing errors in parts
{.done}

Older versions of Hobo did not render a part update if the update did
not pass validation.

This behaviour may now be overridden by using the 'errors-ok'
attribute on your form.  (or formlet or whatever other tag initiates
the Ajax call).

The 'errors-ok' attribute is processed in update_response.  If you
render or redirect inside a block to hobo_update you will be
responsible for implementing this functionality yourself, or calling
update_response to do it for you.

### AJAX file uploads
{.todo}

If you have malsup's form plugin installed, Ajax file uploads should
"just work", as long as you don't have debug_rjs turned on in your
config/initializers/development.rb.

Make sure you're form uses multipart encoding:

     <form multipart ajax/>

### AJAX events
{.todo}

The standard 'before', 'success', 'done' and 'error' callbacks may
still be used.   Additionally, the AJAX code now triggers
'rapid:ajax:before', 'rapid:ajax:success', 'rapid:ajax:done' and
'rapid:ajax:error' events to enable you to code more unobtrusively.

If your form is inside of a part, it's quite likely that the form will
be replaced before the rapid:ajax:success and rapid:ajax:done events
fire.  To prevent memory leaks, jQuery removes event handlers from all
removed elements, making it impossible to catch these events.
If this is the case, hobo-jquery triggers these events on the document
itself, and passes the element as an argument.

      $(document).ready(function() {
         jQuery(document).on("rapid:ajax:success", function(event, el) {
            // `this` is the document and `el` is the form
            alert('success');
         });
      });

### remove-class

`remove-class` is a new attribute that can be used if you're extending or parameterizing a part to remove a class or several classes from the element you're extending or parameterizing.

     <new-page>
         <form: remove-class="form-horizontal"/>
     </new-page>

### before callback
{.done}

A new callback has been added to the list of Ajax Callbacks: before.
This callback fires before any Ajax is done.   If you return false
from this, the Ajax is cancelled.  So you should probably ensure you
explicitly return true if you use it and don't want your ajax
cancelled.

### callbacks
{.done}

Normally in HTML you can attach either a snippet of javascript or a
function to a callback.

    <button onclick=fbar/>

This doesn't work in DRYML because the function is not defined in
Ruby, it's only defined in Javascript.

In Hobo 1.3 you would thus be forced to do this to get equivalent behaviour:

    <form update="foo" success="return fbar.call(this);"/>

Now you can just return the function name:

    <form ajax success="fbar"/>

### `hide` and `show` ajax options
{.done}

There are two new ajax options: `hide` and `show`.  These are passed
directly to the jQuery-UI `hide` and `show` functions.  See
[here](http://jqueryui.com/demos/show/) and
[here](http://docs.jquery.com/UI/Effects) for more documentation on
these two functions.  Due to ruby to javascript translation
difficulties, you may not drop optional middle parameters.

Examples:

     <form ajax hide="puff,,slow" show="&['slide', {:direction => :up}, 'fast', 'myFunctionName']/>

     <form ajax hide="drop" show="&['slide', nil, 1000, 'alert(done);']"/>

These default effect is "no effect".  They may be overridden by passing options to the page-script parameter of `<page>`:

     <extend tag="page">
       <old-page merge>
         <page-scripts: hide="&['slide',{:direction => :up}, 'fast']" show="&['slide',{:direction => :up},'fast']"/>
       </old-page>
     </extend>

If, after changing the default you wish to disable effects on one specific ajax element, pass false:

     <form ajax hide="&false" show="&false" ...

Note that these effects require jQuery-UI.  You will get Javascript errors if you attempt to use effects and do not have jQuery-UI installed.

### spinner options
{.done}

By default, the spinner is now displayed next to the element being
updated.  Besides the old `spinner-next-to` option, there are a number
of new options that control how the spinner is displayed.

- spinner-next-to: DOM id of the element to place the spinner next to.
- spinner-at: CSS selector for the element to place the spinner next to.
- no-spinner: if set, the spinner is not displayed.
- spinner-options: passed to [jQuery-UI's position](http://jqueryui.com/demos/position/).   Defaults are `{my: 'right bottom', at: 'left top'}`
- message: the message to display inside the spinner

The above attributes may be added to most tags that accept the standard ajax attributes.

These options may be overridden globally by adding them as attributes to the `page-scripts` parameter for the page.

     <extend tag="page">
       <old-page merge>
         <page-scripts: spinner-at="#header" spinner-options="&{:my => 'left top', :at => 'left top'}" />
       </old-page>
     </extend>

### hjq-datepicker
{.done}

hjq-datepicker now automatically sets dateFormat to the value
specified in your translations:  (I18n.t :"date.formats.default").

### sortable-collection
{.done}

sortable-collection now supports the standard Ajax callbacks

### delete-button
{.done}

The new `delete-button` behaviour is not as much different from the
old `delete-button` as a comparison of the documentation would have
you believe, however its Ajax triggering behaviour has changed slightly.

The `fade` attribute is no longer supported.   Instead use the new
standard ajax attribute `hide`.

### autocomplete
{.done}

`hjq-autocomplete` has been renamed to `autocomplete`.  It has gained
the attribute `nil-value` and the ability to work with the standard
Hobo autocomplete and hobo_completions controller actions.

`name-one` is now a simple backwards-compatibility wrapper around
`autocomplete`.

### input-many
{.done}

`hjq-input-many` and `input-many` have been merged into `input-many`.
The new standard ajax attributes `hide` and `show` are also now
supported.

Differences from old `input-many`:

- supports hobo-jquery delayed initialization.
- new attributes: add-hook, remove-hook, hide, show

Differences from `hjq-input-many`:

- name of the main parameter is `default` rather than `item`.
- rapid:add, rapid:change and rapid:remove events added.
- new attributes: hide, show

### filter-menu
{.done}

filter-menu now accepts AJAX attributes.

### a
{.done}

the a tag now accepts AJAX attributes.  This is especially useful with
the new 'push-state' option.

### dialog-box
{.done}

`hjq-dialog` has been renamed to `dialog-box`.  (`dialog` has already
been taken in HTML5).

The helper functions have been renamed.   For instance,
`hjq.dialog.formletSubmit` has been renamed to
`hjq_dialog_box.submit`.

Dialog positioning has been updated and should work better now.   See
the documentation for more details.

### search-filter
{.done}

The table-plus search filter has been extracted into its own tag for
use outside of table-plus. It has also gained a "clear" button.

### live-search
{.part}

`live-search` works in a substantially different fashion now, it has
almost completely lost its magic, instead using standard ajax forms
and parts.   It should now be possible to customize using standard
Hobo techniques.   See the documentation for `<live-search>` and
`<search-results>` for more details.

`live-search` has temporarily lost it's live-ness.  Currently you have
to press 'return' to initiate the search.  This should be easy to fix
in hjq-live-search.js -- the hard part will probably be in doing it in
a way that works in all possible browsers.

`live-search` requires an implementation of
`<search-results-container>`.  Both hobo-jquery-ui and
hobo-bootstrap-ui provide implementations of
`<search-results-container>`.

### hot-input
{.done}

see tag documentation

### page-nav
{.done}

The params attribute now defaults to
recognize_page_path.slice(:controller,:action,:id).

Standard form ajax attributes are now also supported, and behave
similar to `<a>`.

### query_params
{.todo}

The old query_params helper has been removed.   You can use
Rails (request.query_parameters | request.request_parameters) instead
if you still need it.

There's a new helper function called query_parameters_filtered that
returns query parameters with the ajax parameters removed.

### parse_sort_param
{.done}

The controller function parse_sort_param has been updated so that it
can take a hash instead of or as well as an argument list.  The key of
the hash is the field name and the value is the column name.
Example:

     Book.include(:authors).order(parse_sort_param(:title, :authors => "authors.last_name")

parse_sort_param now also pluralizes table names. For example, if the
field is named "project.title", parse_sort_param will sort on the
column "projects.title".

### controller actions
{.done}

Hobo no longer attempts to perform its part-based AJAX actions when
sent an xhr request. Instead, Hobo performs part-based AJAX when
`params[:render]` is set.

The signature for the function update_response, index_response and friends have changed.   This should make it useful for use in your application.  update_response is called automatically by hobo_update if you don't render or redirect inside of the block parameter hobo_update.

### default controller actions now use respond_with

All Hobo model controller actions now use [respond_with](http://apidock.com/rails/ActionController/MimeResponds/respond_with) where appropriate.   This means that you can create an API interface for a controller simply by adding:

    respond_to :html, :json, :xml

See [respond_to](http://apidock.com/rails/ActionController/MimeResponds/ClassMethods/respond_to) and Google for "respond_with" for more information.

Note that the JSON and XML interfaces will only use coarse grained
model-level permission checking rather than fine grained attribute
level permission checking.

### custom alternate formats

Hobo no longer executes an arity zero block passed to hobo controller actions inside of a respond_to block.  This means that you can render formats other than html inside of an arity zero block.

    hobo_show do
      render something if request.format.pdf?
    end

Any formats that you do not render or redirect inside the block will be handled by hobo_show via respond_with.

If your block has a parameter, the block continues to be executed inside of a respond_to.

    hobo_show do |format|
      format.pdf do { render something }
    end

Because this is a respond_to block any formats you do not render will fall through and be handled by hobo_show's respond_with block.

### before-unload
{.check}

`<form>` has gained a new option, before-unload, which adds an
onbeforeunload helper to the page.

## Changes behind the scenes

### reloading of part context
{.todo}

[This change](https://github.com/tablatom/hobo/commit/6048925) ensures that
DRYML does not reload the part context if it is already in `this`.

### i18n
{.todo}

These commits will require translation updates for languages other
than English.  (Presumably this list will get larger because right now
the change is one I could do myself...)

- https://github.com/tablatom/hobo/commit/e9460d336ef85388af859e5082763bfae0ad01f5

### controller changes
{.done}

Due to limitations on Ajax file uploads, multipart forms are not sent with the proper Ajax headers.   If your controller action may receive multipart forms, rather than using:

    respond_to do |wants|
      wants.js { hobo_ajax_response }
      wants.html {...}
    end

use

    if request.params[:render]
      hobo_ajax_response
    else
      ....
    end

for more information see http://jquery.malsup.com/form/#file-upload

### hobo_ajax_response
{.done}

the `hobo_ajax_response` function now has a different signature.
Standard usage doesn't supply any arguments to hobo_ajax_response.
This use case has not changed.

However, if you have code that supplied arguments to
hobo_ajax_response, that code likely will need to be updated for 2.0.

FIXME: pointer to AJAX background documentation.

### Dryml.render
{.todo}

Dryml.render now has an additional argument: imports.   The template
environment no longer automatically imports ActionView::Helpers.

### View helpers imported

All application helpers are now available in the template
environment.

### MarkdownString

 MarkdownString will now use Kramdown, RDiscount or Maruku in preference to Bluecloth if they are availble in your bundle.

# jQuery rewrite

FIXME: pull into separate document, along with interface specs

## Framework Agnosticism
{.dontmove}

jQuery support is being written in a manner that should make it easier to support other frameworks if we ever decide to do so.   Basically all this means is that we're annotating our HTML and the javascript is picking up the information from the annotations rather than calling functions or setting variables.

## Unobtrusiveness
{.todo}

The agnosticism is a side benefit -- really the main reason its written this way is so that we're coding using "unobtrusive javascript" techniques.

Hobo currently many different mechanisms to pass data to javascript:

- classdata ex class="model::story:2"
- non-HTML5-compliant element attributes: ex hobo-blank-message="(click to edit)"
- variable assignment: ex hoboParts = ...;
- function calls: ex onclick="Hobo.ajaxRequest(url, {spinnerNextTo: 'foo'})"

hobo-jquery currently uses JSON inside of comments:

    <!-- json_annotation ({"tag":"datepicker","options":{},"events":{}}); -->

We are switching all 5 of these mechanisms to use HTML5 data
attributes.  HTML5 data attributes are technically illegal in HTML4
but work in all browsers future and past (even IE6).  The illegality
of them is the reason that I didn't choose them in Hobo-jQuery, but
it's now 2011.

We mostly use a single attribute: `data-rapid`.  This is a JSON hash
where the keys are the tag names and the values are options hashes.
DRYML has been modified to appropriately merge this tag in a fashion
similar to what it currently does for the `class` tag.  For example,
live-search will have the attribute
`data-rapid='{"live-search":{"foo": 17}}'`.  When hobo-jquery
initializes, it will then attempt to initialize a jQuery plugin named
`hjq_live_search`, which we provide in
public/javascripts/hobo-jquery/hjq-live-search.js.   The plugin will
get passed the options hash {"foo": 17}.

`data-rapid-page-data` contains data required by the javascript
library, such as the part information.

One last attribute that may be set is `data-rapid-context`.  This
contains a typed_id of the current context.  This is used to assist
tags like `delete-button` with DOM manipulation.

## Compatibility
{.dontmove}

Obviously compatibility with hobo-rapid.js is not going to be
maintained, since that's written in prototype.

The internal structure of hobo-jquery has changed completely.  We have
switched to using a more standard jQuery plugin style.

# Running the integration tests:

see https://github.com/tablatom/hobo/integration_tests/agility/README
