# BeaconControl

BeaconControl is an open source platform to setup and manage beacon deployments built with Ruby on Rails.
BeaconControl includes **BeaconControl Admin Panel** which is used to manage beacons, applications and add-ons through the web panel,
**API** to authenticate a client, get beacons configuration and send events about beacons to server and
**S2S API** to manage beacons, applications and add-ons through API (this requires to setup own BeaconControl server).
More information about BeaconControl Admin Panel and APIs can be found at https://beaconcontrol.io/dev/backend-docs

You can check working BeaconControl service at https://admin.beaconcontrol.io

### Deployment

Setup your own BeaconControl server (e.g to extend its functionality or to use `S2S API`) is simple.

The easiest way to deploy own BeaconControl server is to deploy BeaconControl to Heroku using Heroku Button.
Just click on the button bellow and you will be passed through application setup flow on Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/upnext/BeaconControl/tree/master)


If you prefer to start development on your local machine just you use the following command:
```bash
bin/setup
```

For Ubuntu I recommend to execute to begin with:
```bash
./ubuntu.sh
```


It will take care of a few things:
- check Ruby version
- create `config/database.yml` database configuration file
  - ask which database adapter to use: Mysql/PostgreSQL
  - ask for database connection settings
- check Redis & Mysql/PostgreSQL client presence in the system and minimum required version
- create `config/config.yml` application configuration file
  - ask for Redis connection settings
  - ask for mailer URLs settings
  - ask for mailer SMTP settings
  - ask which extensions should be autoloadable
- create `config/sidekiq.yml` Sidekiq configuration file
- run `bundle install`
- verify connection to Redis and Mysql/PostgreSQL server
- create empty database and run migrations
- seed database with initial data
- create admin account and send confirmation email
- start application


### Documentation

Documentation of BeaconControl can be found at:

https://beaconcontrol.io/dev/backend-docs
