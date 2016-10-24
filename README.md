SolidusShipwire
=============

Introduction goes here.

## Installation

Add this line to your application's Gemfile:

```
gem 'solidus_shipwire'
```

Run the bundle command:

```
bundle install
```

After that's done, you can install and run the necessary migrations, then seed the database:

```
bundle exec rake solidus_auth:install:migrations
bundle exec rake db:migrate
bundle exec rake db:seed
```

## Configuration

Basic configuration

```
Shipwire.configure do |config|
  config.username = "<%= ENV['SHIPWIRE_USERNAME'] %>"
  config.password = "<%= ENV['SHIPWIRE_PASSWORD'] %>"
end
```

refer to [Shipwire gem](https://github.com/billr578/shipwire)

Example
=======

Example goes here.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2016 [name of extension creator], released under the New BSD License
