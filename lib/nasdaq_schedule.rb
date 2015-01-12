require "nasdaq_schedule/version"
require "nasdaq_schedule/stock_market"
require "nasdaq_schedule/errors"
require 'active_support/all'
require "holidays"

module NasdaqSchedule
  def in_nasdaq_time_zone
    same_zone? ? self : self.in_time_zone(market_zone)
  end

  def nasdaq_holiday?
    !nasdaq_holiday.nil?
  end

  def nasdaq_working_day?
    market_time.send(:weekday?) &&
      !market_time.nasdaq_holiday? &&
      !(market_time.monday? && market_time.yesterday.nasdaq_holiday?) &&
      !(market_time.friday? && market_time.tomorrow.nasdaq_holiday? && !market_time.send(:nasdaq_end_of_accounting_period_on_friday?))
  end

  def nasdaq_open
    nasdaq_working_hours[:open]
  end

  def nasdaq_close
    nasdaq_working_hours[:close]
  end

  def nasdaq_previous_day
    nasdaq_day(:yesterday)
  end

  def nasdaq_next_day
    nasdaq_day(:tomorrow)
  end

  def nasdaq_closest_open
    nasdaq_closest_working_hours[:open]
  end

  def nasdaq_closest_close
    nasdaq_closest_working_hours[:close]
  end

  private
  attr_reader :market_zone

  def nasdaq_day(corresponding_day)
    date = market_time.send(corresponding_day)
    until date.nasdaq_working_day?
      date = date.send(corresponding_day)
    end
    date.in_time_zone(original_zone)
  end

  def nasdaq_working_hours
    must_be_working_day
    {
      open: market_time.change(hour: 9, min: 30).in_time_zone(original_zone),
      close: market_time.change(hour: 16 + close_hours, min: 0).in_time_zone(original_zone)
    }
  end

  def nasdaq_closest_working_hours
    (nasdaq_working_day? ? self : nasdaq_next_day).send(:nasdaq_working_hours)
  end

  def nasdaq_holiday
    holiday_hash = to_date.holidays(:us, :informal).first || {}
    NasdaqSchedule::StockMarket::HOLIDAYS[holiday_hash[:name]]
  end

  def market_zone
    @market_zone ||= NasdaqSchedule::StockMarket::ZONE
  end

  def market_time
    in_nasdaq_time_zone
  end

  def same_zone?
    send(:zone).to_s == self.in_time_zone(market_zone).zone.to_s
  end

  def weekday?
    (1..5).include?(market_time.wday)
  end

  def nasdaq_end_of_accounting_period_on_friday?
    quarter_months = [3, 6, 9, 12]
    if market_time.friday? && quarter_months.include?(market_time.month)
      last_month_days = []
      3.times{ |i| last_month_days << market_time.end_of_month.day - i}
      return true if last_month_days.include?(market_time.day)
    end
    false
  end

  def close_hours
    close_hours = if market_time.nasdaq_working_day?
                    if previous_day = market_time.yesterday.send(:nasdaq_holiday)
                      if !market_time.monday? && previous_day[:day].to_i > 0
                        previous_day[:close_hours]
                      end
                    elsif next_day = market_time.tomorrow.send(:nasdaq_holiday)
                      if !market_time.friday? && next_day[:day].to_i < 0
                        next_day[:close_hours]
                      end
                    end
                  end
    close_hours.to_i
  end

  def must_be_working_day
    raise NasdaqSchedule::Errors::NotWorkingDay unless market_time.nasdaq_working_day?
  end

  def original_zone
    abbreviation_to_zones_mappings[zone]
  end

  # This method is used only to properly handle conversation back to original time zone.
  # This needs to be an instance method in order to properly handle day light savings and return
  # the date in the original time zone.
  def abbreviation_to_zones_mappings
    Hash[ActiveSupport::TimeZone.all.map{ |z| [self.in_time_zone(z).strftime('%Z'), z.name] }]
  end
end

ActiveSupport::TimeWithZone.send :include, NasdaqSchedule
