require "active_support"
require "active_support/core_ext/integer"
require "active_support/time_with_zone"

# Utility class for calculating the next billing date for a subscription.
class BillingCycle
  attr_accessor :created_at, :interval

  # Initialize a billing cycle.
  # @param created_at [Time] The date/time the subscription was created
  # @param interval [ActiveSupport::Duration] The interval the subscription is paid
  def initialize(created_at, interval)
    @created_at = created_at
    @interval = interval
  end

  # Returns the next billing date based on the subscription
  # @param now [Time] The current time
  # @return [Time] The next billing date/time
  def next_due_at(now = Time.zone.now)
    number_of_cycles = number_of_cycles_since_created(now)
    next_due_at = number_of_cycles.send(interval_units).from_now(created_at)

    # The number of cycles since the billing cycle was created only gets us to "now"
    # so we need probably need to add another cycle to get the next billing date.
    while next_due_at < now
      number_of_cycles += interval_value
      next_due_at = number_of_cycles.send(interval_units).from_now(created_at)
    end

    next_due_at
  end

  private

  # Returns the number from the interval's duration.
  # @return [Integer] `6` for a duration of `6.months`
  def interval_value
    if interval.parts.is_a? Array
      interval.parts[0][1]
    else
      interval.parts.values[0]
    end
  end

  # Returns the interval type from the interval's duration.
  # @return [Symbol] `:month` for a duration of `1.month`
  def interval_units
    if interval.parts.is_a? Array
      interval.parts[0][0]
    else
      interval.parts.keys[0]
    end
  end

  # Returns the number billing cycles that have occurred between the created date and "now".
  # @return [Integer]
  def number_of_cycles_since_created(now)
    (interval_value * ((now - created_at).to_i / interval)).to_i
  end
end
