# Availabe plugins

* ``beacon_control-presence_extension``
* ``beacon_control-analytics_extension``
* ``beacon_control-dwell_time_extension``
* ``beacon_control-kontakt_io_extension``

# Using extension gem

* Add extension gem to Gemfile
``gem 'beacon_control-analytics_extension'``
* Run migrations (optional)
``bundle exec rake db:migrate``
* Add gem assets manifest .js, .css files (optional) to:
  * _app/assets/javascripts/application.js_
  ```js
  ...
  // ### Extensions
  //= require analytics_extension
  ...
  ```
  * _app/assets/stylesheets/application.css.less_
  ```css
  ...
  // Extensions
  @import 'analytics_extension.css.less';
  ...
  ```
