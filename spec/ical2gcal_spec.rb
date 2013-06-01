require File.dirname(__FILE__) + "/spec_helper"

describe Ical2gcal::App do
  describe '#pit_get_google' do
    context 'has google conf' do
      before {
        Pit.stub(:get) { {'username' => 'foo'} }
      }
      subject {
        Ical2gcal::App.new.pit_get_google.class
      }
      it {
        should == Hash
      }
    end
    context 'doen\'t have google conf' do
      before {
        Pit.stub(:get) { {} }
      }
      it {
        expect{
          Ical2gcal::App.new.pit_get_google.class
        }.to raise_error(Ical2gcal::MissingPitConfigOfGoogleAccount)
      }
    end
  end
end
