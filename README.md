# SolidusShipwire

[![Build Status](https://travis-ci.org/solidusio-contrib/solidus_shipwire.svg)](https://travis-ci.org/solidusio-contrib/solidus_shipwire)

solidus and shipwire connect manager.

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
bundle exec rake solidus_shipwire:install:migrations
bundle exec rake db:migrate
```

## Configuration

Basic configuration

```
# config/initializers/spree.rb
Spree::ShipwireConfig.configure do |config|
  config.username = "<%= ENV['SHIPWIRE_USERNAME'] %>"
  config.password = "<%= ENV['SHIPWIRE_PASSWORD'] %>"
end
```

## Sync shipwire

Sync all variants to shipwire

```
bundle exec rake solidus_shipwire:sync_variants
```

If you already have your variants in shipwire, you can create variants with same
sku on solidus and run:

```
bundle exec rake solidus_shipwire:link_shipwire_product
```

Example
=============

The orders are put in shipwire when they become in a complete state

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

To record new cassettes you have to use a shipwire beta environment.
Put your credentials in spec/support/shipwire.rb . Don't forget to remove them
before commit. Don't care about the security because they are filter (
spec/support/tools.rb) .

Copyright (c) 2016 [Daniele Palombo], released under the New BSD License
