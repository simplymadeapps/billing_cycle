# Billing Cycle

[![Build Status](https://travis-ci.org/simplymadeapps/billing_cycle.svg?branch=master)](https://travis-ci.org/simplymadeapps/billing_cycle)
[![Code Climate](https://codeclimate.com/github/simplymadeapps/billing_cycle/badges/gpa.svg)](https://codeclimate.com/github/simplymadeapps/billing_cycle)
[![Test Coverage](https://codeclimate.com/github/simplymadeapps/billing_cycle/badges/coverage.svg)](https://codeclimate.com/github/simplymadeapps/billing_cycle/coverage)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/simplymadeapps/billing_cycle/)

Billing Cycle is a gem used to calculate the billing due dates and time elapsed/remaining in
a recurring subscription's billing cycle.

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

### Due Dates

Calculating due dates requires the original billing date as an anchor to determine due dates
in the future. `BillingCycle::BillingCycle` does the work to handle edge cases like having
a monthly subscription that started on the 31st when there's not 31 days in every month.

```ruby
original_billing_date = Time.zone.parse("2018-01-31 00:00:00")
billing_interval = 1.month
billing_cycle = BillingCycle::BillingCycle.new(original_billing_date, billing_interval)

Time.zone.now
# => Tue, 26 Jun 2018 00:00:00 CDT -05:00

billing_cycle.next_due_at
# => Sat, 30 Jun 2018 00:00:00 CDT -05:00

# A time can be passed in as "now" instead of implicitly using the current time
billing_cycle.next_due_at(Time.zone.parse("2020-02-01 00:00:00")
# => Sat, 29 Feb 2020 00:00:00 CST -06:00

billing_cycle.previous_due_at
# => Thu, 31 May 2018 00:00:00 CDT -05:00

# A time can be passed in as "now" instead of implicitly using the current time
billing_cycle.previous_due_at(Time.zone.parse("2020-02-01 00:00:00")
# => Fri, 31 Jan 2020 00:00:00 CST -06:00
```

If the original billing date is in the future, the `next_due_at` will always be the
original billing date, and the `previous_due_at` will be `nil`.

```ruby
original_billing_date = Time.zone.parse("9999-12-31 00:00:00")
billing_interval = 1.month
billing_cycle = BillingCycle::BillingCycle.new(original_billing_date, billing_interval)

billing_cycle.next_due_at
# => Fri, 31 Dec 9999 00:00:00 CST -06:00

billing_cycle.previous_due_at
# => nil
```

### Time Elapsed and Remaining

The time elapsed and remaining can be used for displaying how much time has been used
and how much time is left in a billing cycle.

```ruby
original_billing_date = Time.zone.parse("2019-06-01 00:00:00")
billing_interval = 1.month
billing_cycle = BillingCycle::BillingCycle.new(original_billing_date, billing_interval)

Time.zone.now
# => Sun, 16 Jun 2019 00:00:00 CDT -05:00

billing_cycle.time_elapsed
# => 1296000.0 (seconds)

# An interval and time can be passed in as "now" instead of implicitly using seconds and the current time
billing_cycle.time_elapsed(1.day, Time.zone.parse("2019-06-07 00:00:00"))
# => 6.0 (days)

billing_cycle.time_remaining
# => 1296000.0 (seconds)

# An interval and time can be passed in as "now" instead of implicitly using seconds and the current time
billing_cycle.time_remaining(1.day, Time.zone.parse("2019-06-07 00:00:00"))
# => 24.0 (days)
```

### Percent Elapsed and Remaining

The percent elapsed and remaining can be used for calculating subscription pricing when charging
or refunding for a partial billing cycle. The percentages are returned as a fraction of 1.0.

```ruby
original_billing_date = Time.zone.parse("2019-06-01 00:00:00")
billing_interval = 1.month
billing_cycle = BillingCycle::BillingCycle.new(original_billing_date, billing_interval)

Time.zone.now
# => Sun, 16 Jun 2019 00:00:00 CDT -05:00

billing_cycle.percent_elapsed
# => 0.5

# A time can be passed in as "now" instead of implicitly using the current time
billing_cycle.percent_elapsed(Time.zone.parse("2019-06-07 00:00:00"))
# => 0.2

billing_cycle.percent_remaining
# => 0.5

# A time can be passed in as "now" instead of implicitly using the current time
billing_cycle.percent_remaining(Time.zone.parse("2019-06-07 00:00:00"))
# => 0.8
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
