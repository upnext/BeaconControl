# New extension

## Generating a new extension gem template

Extension generator is provided by ``beacon_control-base`` gem. There are two ways to create template structure for a new extension: using Rails generator or gem executable script.
To use it within the Rails application context, add ``gem 'beacon_control-base'`` to Gemfile and run the command:
```sh
rails generate beacon_control:base:extension NAME [OPTIONS]
```

Another way is to run a script outside Rails application, with ``beacon_control-base`` gem installed:
```sh
beacon-os generate-extension NAME [options]
```

The available options are:
```sh
    [--skip-namespace], [--no-skip-namespace]  # Skip namespace (affects only isolated applications)
    [--skip-assets], [--no-skip-assets]        # Skips generating .js and .css assets files
-r, [--root-dir=ROOT_DIR]                      # Indicates where to generate gem structure
                                               # Default: vendor/gems
```

This will create a new gem, mountable as Rails engine, with some extra files:
```sh
lib/beacon_control/%extension_name%/engine.rb
config/routes.rb
config/locales/%extension_name%.yml
config/initializers/%extension_name%.rb
app/assets/javascripts/%extension_name%.js
app/assets/stylesheets/%extension_name%.css
```

## Configuration
Each extension can be configured via initializer. Extensions may add as many configuration options as needed.

### Sidebar links
Adding own links to global sidebar section (left side menu). Example:
```ruby
...
config.register :sidebar_links, {
  i18n_key: 'sample_extension.sidebar_links.info',
  path: Proc.new{ beacon_control_sample_extension.info_samples_path },
  icon: 'info'
}
...
```
Where:
* ``i18n_key`` - full key to link label translation in I18n engine
* ``path`` - Ruby Proc that defines link href attribute. It can be a route defined in the gem using ``beacon_control_sample_extension`` prefix, and it can be route path taken from the main application routes (using ``main_app`` prefix). It can also be linked to an external website (passed as string inside a Proc).
* ``icon`` - icon displayed before the link text. It should be a second segment of Font Awesome class. The full list of available icons differs depending on the applied [font-awesome-rails](https://github.com/bokmann/font-awesome-rails) gem version, and can be found [here](http://fortawesome.github.io/Font-Awesome/icons/)

## Setting link
Configuring extension link on application extensions section. Example:
```ruby
...
config.setting_link = Proc.new{ beacon_control_presence_extension.application_presence_path(application_id: @application.id) }
...
```

### Application settings
Each extension can add application configuration options which are shown & editable on the application settings page. Each extension receives a separate form and is handled separately. Example:
```ruby
...
config.register :settings, {
  i18n_key: 'presence_extension.settings.presence',
  key: :presence,
  type: :string,
  validations: Proc.new{ { presence: true, length: { minimum: 3, maximum: 6 } } }
}
...
```
Where:
* ``i18n_key`` - full key to setting name translation in I18n engine
* ``key`` - setting will be accessible by this key name
* ``type`` - type of setting, can be one of:
  * ``:string`` - will produce input type='text'
  * ``:text`` - will produce textarea
  * ``:password`` - will produce input type='password'
  * ``:file``- will produce input type='file'
* ``validations`` - ruby proc applying ActiveRecord validations on setting ``value`` column

### Actions
Registers custom action on activities page, thus allowing to make CRUD operations on it (if extension is enabled for the given application).
Example:
```ruby
...
config.register :actions, {
  i18n_key: 'activities.form.scheme.sample',
  scheme: 'sample',
  permitted_attributes: { examples_attributes: [:id, :name, :_destroy] }
}
...
```
Where:
* ``i18n_key`` - full key to action scheme name translation in I18n engine
* ``scheme`` - name of action scheme(type), will be used to populate ``activities.scheme`` field in DB
* ``permitted_attributes`` - new action type may define new relation. This parameter allows to specify a list of permitted attributes that are passed to activity when performing create / update operations.

Also, additional partial will be rendered within basic activity form. It should be placed in ``app/views/activities/scheme/_SCHEMENAME.html.erb`` and named according to the picked action scheme. Fields for nested attributes may be added here, as long as ``permitted_attributes`` configuration option is provided, and association is defined in ``Activity`` model. To add a new association, an ``app/models/activity.rb`` file should be created. An example of the file's content is as follow:

```ruby
require 'activity' unless defined? Activity
class Activity
  module SampleExtension
    extend ActiveSupport::Concern
    included do
      has_many :examples, class_name: BeaconControl::SampleExtension::Example, dependent: :destroy
      accepts_nested_attributes_for :examples, allow_destroy: true
    end
    class_methods do
      def sample_extension_class_method
      end
    end
  end
end
```

```ruby
# example_extension.rb
auto_include('Activity', 'SampleExtension', 'Activity::SampleExtension')
```

Then, the above file should be added to extension module and included as a file in ``BeaconControl::EXTENSIONNAMEExtension.load_files`` function (located in``lib/beacon_control/EXTENSIONNAME_extension.rb``) to:

```ruby
...
def self.load_files
  [
    "app/models/activity/sample_extension"
  ]
end
...
```

### Action triggers
Adding new type of action trigger type:

```ruby
...
config.register :triggers, {
  key: :sample,
  permitted_attributes: [:sample]
}
...
```

Where:
* ``key`` - value for Trigger ``event_type`` attribute
* ``permitted_attributes`` - new trigger type custom permitted attributes list.

Also, additional partial will be rendered within activity trigger nested form. It should be placed in ``app/views/activities/trigger/_TRIGGERNAME.html.erb`` and named according to the picked trigger type name. Extra trigger attributes fields may be added here, as long as ``permitted_attributes`` configuration option is provided.

### Extension configuration settings
An extension may require global configuration to work properly. The extension will be available to set on edit page, after activating extension from Marketplace. Everything saved here will be lost after deactivating the extension.
Example:
```ruby
...
config.register :configurations, {
  i18n_key: 'samples_extension.settings.api_key',
  key: :api_key
}
...
```
Where:
* ``i18n_key`` - full key to configuration option name translation in I18n engine
* ``key`` - config opton will be accessible by this key name

## Autoloadable
An extension may be activated automatically when a new account is created. To allow this, ``autoloadable`` flag must be set. Moreover, such extension will be activated for test application. Example:
Example:
```ruby
...
config.autoloadable = true
...
```

## Adding an extension functionality

### Models & Migrations

Extension gem, when creating new tables in the database, should name them with ``ext_NAME_`` prefix and place in ``db/migrate`` directory. No further modifications are needed. An example of a table name definition is as follows:
```ruby
create_table :ext_sample_examples do |t|
end
```

All classes (models/services/etc.) should be placed in ``Beacon::NAMEExtension`` module, and located in ``app/(models|services|workers|...)/beacon_control/NAME_extension`` directory, so they will be loaded automatically.
```ruby
module BeaconControl
  module SampleExtension
    class Example < ActiveRecord::Base
      ...
    end
  end
end
```

### Controllers

There are 3 base controllers in ``BeaconControl`` namespace to inherit from when creating new ones:

* ``BeaconControl::ApplicationController`` - very basic parent controller
* ``BeaconControl::AdminController`` - for logged in admin resources
* ``BeaconControl::Api::V1::BaseController`` - for API requests, adds authorization

Additionally `ApplicationController` automatically include `ApplicationController::ParamsExtendable`
which allow extensions add theirs permitted params.

For example:

```ruby
class GreengroceryController < ApplicationController
  extendable :params,
              as: :greengrocery_params
  extend_params :greengrocery_params,
                fetch: :greengrocery,
                permit: [:wheels, :vendor]
end
```

Can be now extended by creating autoloaded module which will add own permitted params:

```ruby
require 'greengrocery_controller' unless defined? GreengroceryController
class GreengroceryController
  module Calories
    extend ActiveSupport::Concern
    included do
      extend_params :greengrocery_params,
                      fetch: :greengrocery,
                      permit: [:calories]
    end
  end
end
GreengroceryController.send :include, GreengroceryController::Calories
```

### Routes

Extension engine may define own routes that are mounted onto the main application automatically. Extra paths should be defined just as in a regular Rails application. The only difference is when accessing them - then, the ``beacon_control_NAME_extension`` prefix should be used.

### Abilities

Extension engine also add interface to manage user ability to access extensions.
User abilites are created using [CanCanCan](https://github.com/CanCanCommunity/cancancan) gem

```ruby
class Ability
  include Ability::ExtensionManageable
  # Even if this extension is disabled or not loaded it will not raise exception
  allow_extension('role') { SampleExtension }
  def initialize(user)
    case user.role
    when 'beacon_manager'
      can :manage, Extension do |extension|
        !disallowed_extension?(user.role, extension)
      end
    when 'user'
      can :read, Extension do |extension|
        allowed_extension?(user.role, extension)
      end
    else false
    end
  end
end
```

### Locales

All I18n translation keys used by extension should be placed in an automatically generated ``config/locales/NAME_extension.yml`` file, under ``NAME_extension`` key. The basic hierarchy for ``sidebar_links, settings`` should be kept.

### Jobs & Workers

An extension can hook into incoming events processing flow. To do so, it needs to define ``Worker`` class within self namespace and respond to ``publish`` method. Example of worker definition is as follows:
```ruby
class Worker
  def initialize(event, worker = WorkerJob)
  end
  def publish
    worker.perform_later(event)
  end
end
```
``publish`` method can execute code asynchroniously, but it is preferred to implement Rails [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html) queuing wrapper. In such a case, a ``WorkerJob`` class should be defined and should inherit from ``BeaconControl::BaseJob``.

### Assets

An extension, when creating new HTML views, may also need to add custom styling and/or javascript functionality. This can be achieved by editing automatically generated files ``#{gem_root_dir}/app/assets/javascripts/#{extension_name}.js`` and ``#{gem_root_dir}/app/assets/stylesheets/#{extension_name}.css``. In order to compile assets, they should also be [required/imported](../plugins.html#using-extension-gem) by main Rails application assets manifests afterwards.
