require "active_support"
require "active_support/core_ext/integer"
require "active_support/time_with_zone"

module BillingCycle
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
      # The next billing date is always the original date if "now" is earlier than the original date
      return created_at if now <= created_at

      number_of_cycles = number_of_cycles_since_created(now)
      next_due_at = calculate_due_at(number_of_cycles)

      # The number of cycles since the billing cycle was created only gets us to "now"
      # so we need probably need to add another cycle to get the next billing date.
      while next_due_at < now
        number_of_cycles += interval_value
        next_due_at = calculate_due_at(number_of_cycles)
      end

      next_due_at
    end

    # RETURN NIL IF BEFORE THE CREATED AT

    # Returns the previous billing date based on the subscription
    # @param now [Time] The current time
    # @return [Time] The previous billing date/time
    def previous_due_at(now = Time.zone.now)
      # There was no previous billing date before the original billing date
      return nil if now <= created_at

      number_of_cycles = number_of_cycles_since_created(now) + interval_value
      previous_due_at = calculate_due_at(number_of_cycles)

      # The number of cycles since the billing cycle was created gets us to "now",
      # and if now matches a billing date exactly, we want the previous billing date.
      while previous_due_at >= now
        number_of_cycles -= interval_value
        previous_due_at = calculate_due_at(number_of_cycles)
      end

      previous_due_at
    end

    private

    # Calculate the due date based on number of billing cycles since
    # or before  the date/time the subscription was created.
    # @param number_of_cycles [Integer]
    # @return [Time]
    def calculate_due_at(number_of_cycles)
      number_of_cycles.send(interval_units).from_now(created_at)
    end

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
end
