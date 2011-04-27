require File.dirname( __FILE__ ) + '/../spec_helper'

HOLIDAYS = File.dirname( __FILE__ ) + '/../support/japanese_holidays.ics'

describe Ical2gcal::Ics::Events do
  describe 'get' do
    it {
      events = Ical2gcal::Ics::Events.new( HOLIDAYS ).get
      events.class.should be Array
      events.size.should > 0
      events.each { |e|
        e.class.should be RiCal::Component::Event
      }
    }
  end

  describe 'each' do
    it {
      count = 0
      Ical2gcal::Ics::Events.new( HOLIDAYS ).each { |e|
        e.class.should be RiCal::Component::Event
        count += 1
      }
      count.should > 0
    }
  end
end
