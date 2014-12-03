require 'rubygems' unless defined? ::Gem
require File.dirname( __FILE__ ) + '/ics'
require File.dirname( __FILE__ ) + '/google/calendar'
require File.dirname( __FILE__ ) + '/google/credential'

require 'optparse'

Version = open(File.dirname(__FILE__) + '/../VERSION').read

module Ical2gcal
  class MissingPitConfigOfGoogleAccount < StandardError; end

  class App
    def initialize
      @ics        = nil
      @list       = nil
      @calendars  = nil
      @credential = nil
      @target     = nil
    end

    def run
      opts.parse( ARGV )

      g = Ical2gcal::Google::Calendar.new(@target, @credential)
      g.remove_all_events
      if calendars
        cals = case calendars
               when Array
                 calendars
               else
                 [calendars]
               end
        cals.each { |c|
          Ical2gcal::Ics::Events.new( c ).each { |e|
            p e
            g.create_event( e )
          }
        }
      else
        puts opts
      end
    end

    #
    # [return] Array
    #
    def calendars
      if ( @ics )
        @calendars = @ics
      end
      if ( @list )
        @calendars = Ical2gcal::Ics::List.new( @list ).import
      end

      @calendars
    end

    #
    # [return] OptionParser
    #
    def opts
      OptionParser.new do |opt|
        opt.on( '-c', '--calendar-id ID' ) { |c|
          @target = c
        }
        opt.on( '-i', '--ics URI' ) { |i|
          @ics = i
        }
        opt.on( '-l', '--calendar-list LIST' ) { |l|
          @list = l
        }
        opt.on( '-s', '--credential-store STORE' ) { |s|
          @credential = s
        }
      end
    end
  end
end

