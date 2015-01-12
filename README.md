# NasdaqSchedule [![Build Status](https://travis-ci.org/camol/nasdaq_schedule.svg?branch=master)](https://travis-ci.org/camol/nasdaq_schedule)

ActiveSupport::TimeWithZone extension. Provides a set of set instance methods which return specific time informations according to Nasdaq working schedule and market hours. Nasdaq schedule can be found here http://www.nasdaq.com/about/trading-schedule.aspx . The market timezone is EST/EDT.

## Installation

Add this line to your application's Gemfile:

    gem 'nasdaq_schedule'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nasdaq_schedule

## Usage
```ruby
date = Time.zone.now => Tue, 09 Dec 2014 14:01:10 PST -08:00

# 'in_nasdaq_time_zone' returns time in Nasdaq time zone.
date.in_nasdaq_time_zone
=> Tue, 09 Dec 2014 17:01:10 EST -05:00 

# 'nasdaq_holiday?' returns true if the given date is a Nasdaq holiday,
otherwise false.
date.nasdaq_holiday?
=> false

# 'nasdaq_working_day?' returns true if the given date is Nasdaq working day, otherwise false.
date.nasdaq_working_day?
=> true

# 'nasdaq_open' returns Nasdaq open time in given timezone.
date.nasdaq_open
=> Tue, 09 Dec 2014 06:30:00 PST -08:00 

# 'nasdaq_close' returns Nasdaq close time in given timezone.
date.nasdaq_close
=> Tue, 09 Dec 2014 13:00:00 PST -08:00

# Both will raise NasdaqSchedule::Errors::NotWorkingDay when used on weekends or holidays.

# 'nasdaq_previous_day' returns previous working day for Nasdaq.
date.nasdaq_previous_day
=> Mon, 08 Dec 2014 14:01:10 PST -08:00 

# 'nasdaq_next_day' returns next working day for Nasdaq.
date.nasdaq_next_day
=> Wed, 10 Dec 2014 14:01:10 PST -08:00 

# 'nasdaq_closest_open' returns open time of closest working day.
(date + 4.days)
=> Sat, 13 Dec 2014 14:01:10 PST -08:00

(date + 4.days).nasdaq_closest_open
=> Mon, 15 Dec 2014 06:30:00 PST -08:00

# 'nasdaq_closest_close' returns close time of closest working day.
(date + 4.days).nasdaq_closest_close
 => Mon, 15 Dec 2014 13:00:00 PST -08:00 
```

## Running specs
- Clone the repo
- run `bundle exec rake spec`

## Contributing

1. Fork it ( http://github.com/camol/nasdaq_schedule/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
