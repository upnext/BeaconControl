# Configuration

Application is configured via standard Rails YAML files along with ApplicationConfig class. Configuration options can be changed from their default values
by copying & editing the file ``config/config.yml.example`` to ``config/config.yml``. An example of the file's content is as follow:

```yaml
default: &default
  config:
    secret_key_base:
    registerable: true
    confirmable: false
    mailer_sender: noreply@beacon-os.com
    mailer_url_options:
      host: localhost
      port: 3000
    smtp_settings:
      address: smtp.gmail.com
      port: 587
      domain: beacon-os.com
      user_name: noreply@beacon-os.com
      password:
      authentication: plain
      enable_starttls_auto: false
    system_mailer_receiver: noreply@beacon-os.com
    redis_url: redis://localhost:6379
    create_test_app_on_new_account: true
    autoload_extensions:
      "Analytics":  false
      "DwellTime":  false
      "Kontakt.io": false
      "Presence":   true

development:
   &lt;&lt;: *default

test:
   &lt;&lt;: *default

production:
   &lt;&lt;: *default
```

## Keys explanation

* ``secret_key_base`` - Rails [secret key](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#config-secrets-yml) for ``config/secrets.yml``
* ``registerable`` - ``true/false``, should new account registration be possible. Disabling will hide relevant links from homepage
* ``confirmable`` - ``true/false``, should new admin account confirmation be required (and will send confirmation email)
* ``mailer_sender`` - Sender email address (FROM:) of all [Devise](https://github.com/plataformatec/devise) messages
* ``mailer_url_options`` - Configures host & port of URLs incuded into emails body. Port value can be omitted.
* ``smtp_settings`` - Allows detailed configuration for [:smtp](http://edgeguides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail) delivery method
* ``system_mailer_receiver`` - Email address of all system messages receiver
* ``redis_url`` - URL to Redis server storing ``Sidekiq`` tasks
* ``create_test_app_on_new_account`` - ``true/false``, should new account creation also include test application setup
* ``autoload_extensions`` - Configures which extensions should be activated for account and test application (if present) on account creation
