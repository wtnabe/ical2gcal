require 'rubygems' unless defined? ::Gem
require File.dirname( __FILE__ ) + '/ics'
require File.dirname( __FILE__ ) + '/google'

require 'optparse'
require 'pit'

module Ical2gcal
  class MissingPitConfigOfGoogleAccount < StandardError; end

  class App
    def initialize
      @ics       = nil
      @list      = nil
      @calendars = nil
      @target    = nil
    end

    def run
      opts.parse( ARGV )

      conf = pit_get_google
      conf.merge!( {'calendar' => {'name' => @target}} ) if @target
      g = Ical2gcal::Google.new( conf )
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
            g.create_event( e )
          }
        }
      else
        puts opts
      end
    end

    #
    # [return] Hash
    #
    def pit_get_google
      info = ::Pit.get('google')

      if info.size > 0
        info
      else
        raise MissingPitConfigOfGoogleAccount, 'execute "pit set google"'
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
        l          = Ical2gcal::Ics::List.new( @list ).import
        @calendars = l.list
      end

      @calendars
    end

    #
    # [return] OptionParser
    #
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

