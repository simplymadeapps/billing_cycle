# frozen_string_literal: true

require "spec_helper"

describe BillingCycle::BillingCycle, type: :model do
  let(:billing_cycle) { BillingCycle::BillingCycle.new(created_at, interval) }
  let(:created_at) { Time.zone.parse("2018-07-31 00:00:00") }
  let(:interval) { 1.month }

  describe "initialize" do
    it "sets the created_at and interval" do
      expect(billing_cycle.created_at).to eq(created_at)
      expect(billing_cycle.interval).to eq(interval)
    end
  end

  describe "next_due_at" do
    it "returns the next date/time in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2018-08-20 00:00:00") do
        expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-31 00:00:00"))
      end
    end

    it "returns the next date/time in the billing cycle based on a given date/time" do
      now = Time.zone.parse("2018-09-01 00:00:00")
      expect(billing_cycle.next_due_at(now)).to eq(Time.zone.parse("2018-09-30 00:00:00"))
    end

    it "returns the current date/time if it matches the a billing date exactly" do
      travel_to Time.zone.parse("2018-08-31 00:00:00") do
        expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-31 00:00:00"))
      end
    end

    it "returns the created_at date if 'now' is earlier than the original billing date" do
      travel_to Time.zone.parse("2000-01-01 00:00:00") do
        expect(billing_cycle.next_due_at).to eq(created_at)
      end
    end

    context "when the interval is every year" do
      let(:interval) { 1.year }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2019-07-31 00:00:00"))
        end
      end
    end

    context "when the interval is every other year" do
      let(:interval) { 2.years }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2020-07-31 00:00:00"))
        end
      end
    end

    context "when the interval is every week" do
      let(:interval) { 1.week }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-21 00:00:00"))
        end
      end
    end

    context "when the interval is every other week" do
      let(:interval) { 2.weeks }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-28 00:00:00"))
        end
      end
    end

    context "when the interval is every day" do
      let(:interval) { 1.day }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:01") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-16 00:00:00"))
        end
      end
    end

    context "when the interval is every 5th day" do
      let(:interval) { 5.days }

      it "returns the next billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:01") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-20 00:00:00"))
        end
      end
    end

    context "when the billing cycle starts on the 31st" do
      let(:created_at) { Time.zone.parse("2018-01-31 00:00:00") }
      let(:interval) { 1.month }

      it "returns the last day of each month" do
        travel_to Time.zone.parse("2018-02-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-02-28 00:00:00"))
        end

        travel_to Time.zone.parse("2018-03-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-03-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-04-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-04-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-05-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-05-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-06-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-06-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-07-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-07-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-08-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-08-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-09-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-09-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-10-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-10-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-11-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-11-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-12-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2018-12-31 00:00:00"))
        end

        travel_to Time.zone.parse("2019-01-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2019-01-31 00:00:00"))
        end

        # Leap year
        travel_to Time.zone.parse("2020-02-01 00:00:00") do
          expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2020-02-29 00:00:00"))
        end
      end

      context "when the billing cycle starts on February 29th" do
        let(:created_at) { Time.zone.parse("2020-02-29 00:00:00") }
        let(:interval) { 1.year }

        it "returns the last day of February for each year" do
          travel_to Time.zone.parse("2021-02-01 00:00:00") do
            expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2021-02-28 00:00:00"))
          end

          travel_to Time.zone.parse("2024-02-01 00:00:00") do
            expect(billing_cycle.next_due_at).to eq(Time.zone.parse("2024-02-29 00:00:00"))
          end
        end
      end
    end
  end

  describe "percent_elapsed" do
    let(:created_at) { Time.zone.parse("2019-06-01 00:00:00") }

    it "returns the percentage of time that's elapsed in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.percent_elapsed).to eq(0.5)
      end
    end

    it "returns the percentage of time that's elapsed in the billing cycle based on a given date/time" do
      now = Time.zone.parse("2019-06-07 00:00:00")
      expect(billing_cycle.percent_elapsed(now)).to eq(0.2)
    end
  end

  describe "percent_remaining" do
    let(:created_at) { Time.zone.parse("2019-06-01 00:00:00") }

    it "returns the percentage of time that's remaining in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.percent_remaining).to eq(0.5)
      end
    end

    it "returns the percentage of time that's remaining in the billing cycle based on a given date/time" do
      now = Time.zone.parse("2019-06-07 00:00:00")
      expect(billing_cycle.percent_remaining(now)).to eq(0.8)
    end
  end

  describe "previous_due_at" do
    it "returns the previous date/time in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2018-08-20 00:00:00") do
        expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-07-31 00:00:00"))
      end
    end

    it "returns the previous date/time in the billing cycle based on a given date/time" do
      now = Time.zone.parse("2018-09-01 00:00:00")
      expect(billing_cycle.previous_due_at(now)).to eq(Time.zone.parse("2018-08-31 00:00:00"))
    end

    it "returns the previous date/time if the current date/time matches the a billing date exactly" do
      travel_to Time.zone.parse("2018-08-31 00:00:00") do
        expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-07-31 00:00:00"))
      end
    end

    it "returns `nil` if 'now' is earlier than the original billing date" do
      travel_to Time.zone.parse("2000-01-01 00:00:00") do
        expect(billing_cycle.previous_due_at).to eq(nil)
      end
    end

    context "when the interval is every year" do
      let(:interval) { 1.year }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-07-31 00:00:00"))
        end
      end
    end

    context "when the interval is every other year" do
      let(:interval) { 2.years }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2020-08-15 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2020-07-31 00:00:00"))
        end
      end
    end

    context "when the interval is every week" do
      let(:interval) { 1.week }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-08-14 00:00:00"))
        end
      end
    end

    context "when the interval is every other week" do
      let(:interval) { 2.weeks }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2018-08-22 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-08-14 00:00:00"))
        end
      end
    end

    context "when the interval is every day" do
      let(:interval) { 1.day }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-08-14 00:00:00"))
        end
      end
    end

    context "when the interval is every 5th day" do
      let(:interval) { 5.days }

      it "returns the previous billing date" do
        travel_to Time.zone.parse("2018-08-15 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-08-10 00:00:00"))
        end
      end
    end

    context "when the billing cycle starts on the 31st" do
      let(:created_at) { Time.zone.parse("2018-01-31 00:00:00") }
      let(:interval) { 1.month }

      it "returns the last day of each month" do
        travel_to Time.zone.parse("2018-02-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-01-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-03-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-02-28 00:00:00"))
        end

        travel_to Time.zone.parse("2018-04-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-03-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-05-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-04-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-06-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-05-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-07-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-06-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-08-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-07-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-09-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-08-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-10-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-09-30 00:00:00"))
        end

        travel_to Time.zone.parse("2018-11-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-10-31 00:00:00"))
        end

        travel_to Time.zone.parse("2018-12-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-11-30 00:00:00"))
        end

        travel_to Time.zone.parse("2019-01-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2018-12-31 00:00:00"))
        end

        # Leap year
        travel_to Time.zone.parse("2020-03-01 00:00:00") do
          expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2020-02-29 00:00:00"))
        end
      end

      context "when the billing cycle starts on February 29th" do
        let(:created_at) { Time.zone.parse("2020-02-29 00:00:00") }
        let(:interval) { 1.year }

        it "returns the last day of February for each year" do
          travel_to Time.zone.parse("2021-03-01 00:00:00") do
            expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2021-02-28 00:00:00"))
          end

          travel_to Time.zone.parse("2024-03-01 00:00:00") do
            expect(billing_cycle.previous_due_at).to eq(Time.zone.parse("2024-02-29 00:00:00"))
          end
        end
      end
    end
  end

  describe "time_elapsed" do
    let(:created_at) { Time.zone.parse("2019-06-01 00:00:00") }

    it "returns the number of seconds elapsed in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.time_elapsed).to eq(1_296_000.0)
      end
    end

    it "returns the number of intervals elapsed in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.time_elapsed(1.day)).to eq(15.0)
      end
    end

    it "returns the number of intervals elapsed in the billing cycle based on a given current date/time" do
      now = Time.zone.parse("2019-06-07 00:00:00")
      expect(billing_cycle.time_elapsed(1.day, now)).to eq(6.0)
    end
  end

  describe "time_remaining" do
    let(:created_at) { Time.zone.parse("2019-06-01 00:00:00") }

    it "returns the number of seconds remaining in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.time_remaining).to eq(1_296_000.0)
      end
    end

    it "returns the number of intervals remaining in the billing cycle based on the current date/time" do
      travel_to Time.zone.parse("2019-06-16 00:00:00") do
        expect(billing_cycle.time_remaining(1.day)).to eq(15.0)
      end
    end

    it "returns the number of intervals remaining in the billing cycle based on a given current date/time" do
      now = Time.zone.parse("2019-06-07 00:00:00")
      expect(billing_cycle.time_remaining(1.day, now)).to eq(24.0)
    end
  end

  describe "interval_units" do
    context "when the interval is a duration from ActiveSupport 4" do
      let(:interval) { double("ActiveSupport::Duration", parts: parts) }
      let(:parts) { [[:weeks, 5]] }

      it "returns the interval units" do
        expect(billing_cycle.send(:interval_units)).to eq(:weeks)
      end
    end

    context "when the interval is a duration from ActiveSupport 5" do
      let(:interval) { double("ActiveSupport::Duration", parts: parts) }
      let(:parts) { { weeks: 5 } }

      it "returns the interval units" do
        expect(billing_cycle.send(:interval_units)).to eq(:weeks)
      end
    end
  end

  describe "interval_value" do
    context "when the interval is a duration from ActiveSupport 4" do
      let(:interval) { double("ActiveSupport::Duration", parts: parts) }
      let(:parts) { [[:weeks, 5]] }

      it "returns the interval value" do
        expect(billing_cycle.send(:interval_value)).to eq(5)
      end
    end

    context "when the interval is a duration from ActiveSupport 5" do
      let(:interval) { double("ActiveSupport::Duration", parts: parts) }
      let(:parts) { { weeks: 5 } }

      it "returns the interval value" do
        expect(billing_cycle.send(:interval_value)).to eq(5)
      end
    end
  end
end
