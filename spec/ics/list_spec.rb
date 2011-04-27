require File.dirname( __FILE__ ) + '/../spec_helper'

ICS_FILE          = File.dirname( __FILE__ ) + '/../support/ics_list.txt'
JAPANESE_HOLIDAYS = 'https://www.google.com/calendar/ical/japanese%40holiday.calendar.google.com/public/basic.ics'

describe Ical2gcal::Ics::List do
  describe 'import' do
    context 'localfile' do
      it {
        Ical2gcal::Ics::List.new( ICS_FILE ).import.class.should be Array
      }
    end
    context 'uri' do
      it {
        Ical2gcal::Ics::List.new( JAPANESE_HOLIDAYS ).import.class.should be Array
      }
    end
    context 'with uri' do
      it {
        Ical2gcal::Ics::List.new.import( ICS_FILE ).class.should be Array
      }
    end
    context 'no data given' do
      it {
        Ical2gcal::Ics::List.new.import.should be_nil
      }
    end
  end

  describe 'list' do
    context 'localfile' do
      it {
        ics = Ical2gcal::Ics::List.new( ICS_FILE )
        ics.import
        ics.list.class.should be Array
      }
    end
    context 'no data given' do
      it {
        ics = Ical2gcal::Ics::List.new
        ics.import
        ics.list.class.should be Array
        ics.list.size == 0
      }
    end
  end

  describe 'with_scheme?' do
    context 'localfile' do
      it {
        Ical2gcal::Ics::List.new( ICS_FILE ).with_scheme?.should be_false
      }
    end
    context 'uri' do
      it {
        Ical2gcal::Ics::List.new( JAPANESE_HOLIDAYS ).with_scheme?.should be_true
      }
    end
  end
end
