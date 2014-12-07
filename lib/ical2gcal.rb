require 'rubygems' unless defined? ::Gem
require File.dirname( __FILE__ ) + '/ics'
require File.dirname( __FILE__ ) + '/google'

require 'optparse'

Version = open(File.dirname(__FILE__) + '/../VERSION').read

module Ical2gcal
  class App
    def initialize
      @ics        = nil
      @list       = nil
      @calendars  = nil
      @target     = nil
      @credential = nil

      set_credential(Dir.pwd)
    end

    #
    # [param]  String path
    # [return] String
    #
    def set_credential(path)
      @credential = if File.directory?(path)
                      File.join(path, '.ical2gcal_credential')
                    else
                      path
                    end
    end

    def run
      opts.parse( ARGV )
      unless @target
        puts opts.help
        exit
      end

      if calendars
        cals = case calendars
               when Array
                 calendars
               else
                 [calendars]
               end
        g = Ical2gcal::Google.new(@target, @credential)
        g.remove_all_events
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
          set_credential(s)
        }
      end
    end
  end
end

