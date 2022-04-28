# frozen_string_literal: true

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

    # Returns the percentage of time that's elapsed between the previous due date and the next due date.
    # @param now [Time] The current time
    # @return [Float] The percentage as a fraction of 1.0
    def percent_elapsed(now = Time.zone.now)
      time_elapsed(1.second, now) / seconds_in_cycle(now)
    end

    # Returns the percentage of time that's remaining between the previous due date and the next due date.
    # @param now [Time] The current time
    # @return [Float] The percentage as a fraction of 1.0
    def percent_remaining(now = Time.zone.now)
      time_remaining(1.second, now) / seconds_in_cycle(now)
    end

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

    # Returns the time elapsed since the previous due date.
    # @param interval [ActiveSupport::Duration] The duration
    # @param now [Time] The current time
    # @return [Float] The number of intervals since the previous due date
    def time_elapsed(interval = 1.second, now = Time.zone.now)
      (now - previous_due_at(now)) / interval
    end

    # Returns the time remaining until the next due date.
    # @param now [Time] The current time
    # @return [Float] The number of intervals until the next due date
    def time_remaining(interval = 1.second, now = Time.zone.now)
      (next_due_at(now) - now) / interval
    end

    private

    # Calculate the due date based on number of billing cycles since
    # or before the date/time the subscription was created.
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
    # @param now [Time] The current time
    # @return [Integer]
    def number_of_cycles_since_created(now)
      (interval_value * ((now - created_at).to_i / interval)).to_i
    end

    # Returns the total number of seconds in the current billing cycle.
    # @param now [Time] The current time
    # @return [Float]
    def seconds_in_cycle(now)
      next_due_at(now) - previous_due_at(now)
    end
  end
end
