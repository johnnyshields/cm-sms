# CM Messaging

[![Build Status](https://img.shields.io/travis/HitFox/cm-sms.svg?style=flat-square)](https://travis-ci.org/HitFox/cm-sms)
[![Gem](https://img.shields.io/gem/dt/cm-sms.svg?style=flat-square)](https://rubygems.org/gems/cm-sms)
[![Code Climate](https://img.shields.io/codeclimate/github/HitFox/cm-sms.svg?style=flat-square)](https://codeclimate.com/github/HitFox/cm-sms)
[![Coverage](https://img.shields.io/coveralls/HitFox/cm-sms.svg?style=flat-square)](https://coveralls.io/github/HitFox/cm-sms)

Send text messages via [CM Telecom's Business Messaging API](https://www.cm.com/en-en/app/docs/api/business-messaging-api/1.0/index/).

## Usage

First, configure the app, e.g. in an initializer:

```ruby
CmSms.configure do |config|
  config.product_token = 'YOUR-PRODUCT-TOKEN'
end
```

Then create a `CmSms::Message` and deliver it:

```ruby
msg = CmSms::Message.new(from: 'ACME',
                         to: '+41 44 111 22 33',
                         body: 'Lorem ipsum dolor sit amet.',
                         reference: 'Ref:123')
response = msg.deliver
```

### DCS Detection

This gem will automatically detect your DCS (Data Coding Scheme).
It will use GSM (160-char max length) if possible, otherwise it will
fallback to UCS2 (70-char max length). Moreover, it will set the
number of parts automatically on the API call, so that you don't have to worry
about rejections due to message length.

If you prefer to manage these aspects manually, you can do so on the Message object:

```
CmSms::Message.new(...
                   dcs: 8,
                   min_parts: 3,
                   max_parts: 5)
```

### Optional Number Validation

Cm-Sms will look for the presence of either [Phony](https://github.com/floere/phony)
or [Phonelib](https://github.com/daddyz/phonelib) and use one of these libraries
to perform a basic check of receiver number. This check does not consider whether the
number is a mobile number.

## Installation

If you user bundler, then just add 

```ruby
$ gem 'cm-sms'
```

to your Gemfile and execute

```
$ bundle install
```

or without bundler

```
$ gem install cms-sms
```

### Upgrade

```
$ bundle update cms-sms
```

or without bundler

```
$ gem update cms-sms
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HitFox/cm-sms. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
