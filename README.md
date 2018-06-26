# Billing Cycle

Billing Cycle is a gem used to calculate the next billing date for a recurring subscription.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "billing_cycle"
```

And then execute:

```bash
$ bundle
```

## Usage

```ruby
subscription_created_at = Time.zone.parse("2018-01-31 08:00:00")
subscription_interval = 1.month
billing_cycle = BillingCycle.new(subscription_created_at, subscription_interval)
billing_cycle.next_due_at(now = Time.zone.now)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
