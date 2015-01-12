module NasdaqSchedule
  module StockMarket
    ZONE = "Eastern Time (US & Canada)"

    HOLIDAYS = {
      "New Year's Day" => {},
      "Martin Luther King, Jr. Day" => {},
      "Presidents' Day" => {},
      "Good Friday" => {},
      "Memorial Day" => {},
      "Independence Day" => { day: -1, close_hours: -3 },
      "Labor Day" => {},
      "Thanksgiving" => { day: 1, close_hours: -3 },
      "Christmas Day" => { day: -1, close_hours: -3 }
    }
  end
end
