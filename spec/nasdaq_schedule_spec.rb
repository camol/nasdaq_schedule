# encoding: utf-8
require 'spec_helper'

describe NasdaqSchedule do
  let(:test_zone) { "Pacific Time (US & Canada)" }
  let(:market_zone) { NasdaqSchedule::StockMarket::ZONE }
  let(:workweek_day) { Time.zone.parse("13/08/2014 10:00") }
  let(:weekend) { [Time.zone.parse("16/08/2014 10:00"), Time.zone.parse("17/08/2014 10:00")] }
  let(:holidays) do
    Hash[(workweek_day.beginning_of_year.to_date..workweek_day.end_of_year.to_date).map do |d|
      holiday = d.holidays(:us, :informal).first
      if holiday.present? && NasdaqSchedule::StockMarket::HOLIDAYS.keys.include?(holiday[:name])
        [holiday[:name], holiday[:date].in_time_zone(test_zone)]
      end
    end.compact]
  end
  let(:independance_day) { holidays["Independence Day"] }
  let(:christmas_day) { holidays["Christmas Day"] }
  let(:thanksgiving) { holidays["Thanksgiving"] }

  before(:each) do
    Time.zone = test_zone
  end

  describe '#in_nasdaq_time_zone' do
    context "workweek day" do
      it "returns time in market time zone" do
        expect(workweek_day.in_nasdaq_time_zone.zone).to eql workweek_day.in_time_zone(market_zone).zone
      end

      it "returns self if same time zone" do
        market_week_day = workweek_day.in_time_zone(market_zone)
        expect(market_week_day.in_nasdaq_time_zone).to be market_week_day
      end
    end
  end

  describe '#nasdaq_holiday?' do
    context "workweek day" do
      it { expect(workweek_day.nasdaq_holiday?).to be_falsey }
    end
    context "weekend" do
      it { expect(weekend.map(&:nasdaq_holiday?)).to all(be_falsey) }
    end
     context "holidays" do
       it { expect(holidays.values.map(&:nasdaq_holiday?)).to all(be_truthy) }
     end
  end

  describe "#nasdaq_working_day?" do
    context "workweek day" do
      it { expect(workweek_day.nasdaq_working_day?).to be_truthy }
    end
    context "weekend" do
      it { expect(weekend.map(&:nasdaq_working_day?)).to all(be_falsey) }
    end
    context "holidays" do
      it { expect(holidays.values.map(&:nasdaq_working_day?)).to all(be_falsey) }
    end
    context "holidays on weekend" do
      # Independence Day
      it "returns false for monday if holiday was on sunday" do
        expect(workweek_day.change(day: 5, month: 7, year: 2010).nasdaq_working_day?).to be_falsey
      end
      it "returns false for friday if holiday was on sunday" do
        expect(workweek_day.change(day: 3, month: 7, year: 2009).nasdaq_working_day?).to be_falsey
      end
    end
  end

  describe '#nasdaq_open' do
    context "workweek day" do
      it "returns time object with market open hour" do
        expect(workweek_day.nasdaq_open).to eql workweek_day.change(hour: 6, min: 30)
      end
    end
    context "weekend and holidays" do
      it "raises NasdaqSchedule::Errors::NotWorkingDay" do
        (weekend + holidays.values).each{ |d| expect{ d.nasdaq_open }.to raise_error(NasdaqSchedule::Errors::NotWorkingDay) }
      end
    end
  end

  describe '#nasdaq_close' do
    context "workweek day" do
      it "returns time object with market open hour" do
        expect(workweek_day.nasdaq_close).to eql workweek_day.change(hour: 13, min: 0)
      end
    end
    context "weekend and holidays" do
      it "raises NasdaqSchedule::Errors::NotWorkingDay" do
        (weekend + holidays.values).each{ |d| expect{ d.nasdaq_close }.to raise_error(NasdaqSchedule::Errors::NotWorkingDay) }
      end
    end
    context "around some holidays returns 3 hours earlier closing time for" do
      it "day before Independence Day" do
        before_independance_day = independance_day - 1.day
        expect(before_independance_day.nasdaq_close).to eql before_independance_day.change(hour: 10, min: 0)
      end
      it "day before Christmas Day" do
        before_christmas_day = christmas_day - 1.day
        expect(before_christmas_day.nasdaq_close).to eql before_christmas_day.change(hour: 10, min: 0)
      end
      it "day after Thanksgiving" do
        after_thanksgiving = thanksgiving + 1.day
        expect(after_thanksgiving.nasdaq_close).to eql after_thanksgiving.change(hour: 10, min: 0)
      end
    end
  end

  describe "#nasdaq_previous_day" do
    context "workweek day" do
      it "returns tuesday for wednesday" do
        expect(workweek_day.nasdaq_previous_day.tuesday?).to be_truthy
      end
      it "returns friday for monday" do
        expect((workweek_day - 3.days).nasdaq_previous_day.friday?).to be_truthy
      end
    end
  end

  describe "#nasdaq_next_day" do
    context "workweek day" do
      it "returns thursday for wednesday" do
        expect(workweek_day.nasdaq_next_day.thursday?).to be_truthy
      end
      it "returns monday for friday" do
        expect((workweek_day + 3.days).nasdaq_next_day.monday?).to be_truthy
      end
    end
  end

  describe "#nasdaq_closest_open" do
    context "workweek day" do
      it "returns same day with open time in zone" do
        expect(workweek_day.nasdaq_closest_open).to eql workweek_day.change(hour: 6, min: 30)
      end
    end
    context "weekend" do
      it "returns monday with open in time zone" do
        weekend.each{ |w| expect(w.nasdaq_closest_open).to eql Time.zone.parse("18/08/2014 6:30") }
      end
    end
  end

  describe "#nasdaq_closest_close" do
    context "workweek day" do
      it "returns same day with open time in zone" do
        expect(workweek_day.nasdaq_closest_close).to eql workweek_day.change(hour: 13, min: 00)
      end
    end
    context "weekend" do
      it "returns monday with open in time zone" do
        weekend.each{ |w| expect(w.nasdaq_closest_close).to eql Time.zone.parse("18/08/2014 13:00") }
      end
    end
    context "holidays" do
      it "Independence Day" do
        expect(independance_day.nasdaq_closest_close).to eql (independance_day + 3.days).change(hour: 13, min: 0)
      end
      it "Christmas Day" do
        expect(christmas_day.nasdaq_closest_close).to eql (christmas_day + 1.day).change(hour: 13, min: 0)
      end
      it "day after Thanksgiving" do
        expect(thanksgiving.nasdaq_closest_close).to eql (thanksgiving + 1.day).change(hour: 10, min: 0)
      end
    end
  end
end
