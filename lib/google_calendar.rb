# -*- mode: ruby; coding: utf-8 -*-

require 'pty'
require 'expect'
require 'gcal4ruby'

module Ical2gcal
  class GoogleCalendar
    include GCal4Ruby

    class GoogleclNotAuthenticated < StandardError; end

    def initialize( opts )
      @service  = nil
      @opts     = {
        'username' => nil,
        'password' => nil,
        'calendar' => nil
      }.merge( opts )
      @calendar = nil
      @events   = nil
    end

    def service
      if ( !@service and @opts )
        @service = Service.new
        @service.authenticate( @opts['username'], @opts['password'] )
      end

      @service
    end

    def calendar
      if ( !@calendar )
        @calendar = Calendar.find( service, :title => calendar_name ).first
      end

      @calendar
    end

    def calendar_name
      @opts['calendar']['name']
    end

    def create_event( event )
      begin
        e            = Event.new( service )
        e.calendar   = calendar
        e.title      = event.summary
        e.start_time = Time.iso8601(event.start_time.to_s)
        e.all_day    = event.all?
        e.end_time   = if event.respond_to? :end_time
                         Time.iso8601(event.end_time.to_s)
                       else
                         Time.iso8601(event.start_time.to_s)
                       end
        e.save
      rescue
        ;
      end
    end

    def remove_all_events
      if ( events.size )
        PTY.spawn( "google calendar delete --cal '#{calendar_name}' --title '.*'" ) { |r, w|
          w.sync = true

          events.each { |e|
            r.expect( /Are you SURE.*\?.*\(y\/N\)/iu, 5 ) {
              w.puts 'y'
            }
          }
        }
      end
    end

    def events
      if ( !@events )
        @events    = []
        list_below = false

        `google calendar list --cal '#{calendar_name}' --title '.*'`.lines.each { |line|
          if ( line.chomp == "[#{calendar_name}]" )
            list_below = true
            next
          end
          if ( list_below )
            @events << line.chomp
          end
        }
      end

      @events
    end

    def self.authenticated?
      begin
        PTY.spawn( 'google calendar list' ) { |r, w|
          r.expect( /(?:user|pass)/, 3 ) { |s|
            raise GoogleclNotAuthenticated if ( s and s[0] =~ /(?:user|pass)/ )
          }
        }
      rescue GoogleclNotAuthenticated
        false
      else
        true
      end
    end
  end
end
