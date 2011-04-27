require 'rubygems' unless defined? ::Gem
require File.dirname( __FILE__ ) + '/ics'
require File.dirname( __FILE__ ) + '/google_calendar'

require 'optparse'
require 'pit'

module Ical2gcal
  class App
    def initialize
      @ics       = nil
      @list      = nil
      @calendars = nil
      @target    = nil
    end

    def run
      opts.parse( ARGV )

      opts = ::Pit.get('google')
      opts.merge!( {'calendar' => {'name' => @target}} ) if @target
      if ( Ical2gcal::GoogleCalendar.authenticated? )
        g = Ical2gcal::GoogleCalendar.new( opts )
        g.remove_all_events
        calendars.each { |c|
          Ical2gcal::Ics::Events.new( c ).each { |e|
            g.create_event( e )
          }
        }
      else
        puts "Your `google' command is not authorized. Please type `google calendar list' and get auth."
      end
    end

    def calendars
      if ( @ics )
        @calendars = @ics
      end
      if ( @list )
        l          = Ical2gcal::Ics::List.new( @list ).import
        @calendars = l.list
      end

      @calendars
    end

    def opts
      OptionParser.new do |opt|
        opt.on( '-c', '--calendar-name NAME' ) { |c|
          @target = c
        }
        opt.on( '-i', '--ics URI' ) { |i|
          @ics = i
        }
        opt.on( '-l', '--calendar-list' ) { |l|
          @list = l
        }
      end
    end
  end
end

