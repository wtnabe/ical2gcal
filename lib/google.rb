# -*- mode: ruby; coding: utf-8 -*-

require 'gcalapi'
require 'simple-rss'

module Ical2gcal
  class Google

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

    #
    # [return] GoogleCalendar::Service
    #
    def service
      if ( !@service and @opts )
        @service = GoogleCalendar::Service.new( @opts['username'],
                                                @opts['password'] )
      end

      @service
    end

    #
    # [return] Array
    #
    def calendars
      SimpleRSS.parse( service.calendars.body ).entries
    end

    #
    # [return] GoogleCalendar::Calendar
    #
    def calendar
      if ( !@calendar )
        cal = calendars.find { |c|
          c.title == calendar_name
        }
        @calendar = GoogleCalendar::Calendar.new( @service, cal[:link] )
      end

      @calendar
    end

    #
    # [return] String
    #
    def calendar_name
      @opts['calendar']['name']
    end

    def create_event( event )
      e        = calendar.create_event
      e.title  = event.summary
      e.desc   = event.description
      e.where  = event.location
      e.st     = Time.parse(event.start_time.to_s.sub(/\+.*/, ''))
      e.allday = e.st.hour == 0 and e.st.min == 0 and not event.respond_to? :end_time
      e.en     = if event.respond_to? :end_time
                   Time.parse(event.end_time.to_s.sub(/\+.*/, ''))
                 else
                   Time.parse(event.start_time.to_s.sub(/\+.*/, ''))
                 end
      e.save!
    end

    def remove_all_events
      events    = calendar.events
      max_retry = 3

      omni_retry = max_retry

      while events.size > 0 and omni_retry > 0
        events.each { |e|
          remove_one_event(e, max_retry)
        }
        omni_retry -= 1

        sleep 1
      end
    end

    #
    # remove one event with retry
    #
    # [param] GoogleCalendar::Event
    # [param] Fixnum
    #
    def remove_one_event(e, num_retry)
      begin
        e.destroy!
      rescue => e
        case e
        when NoMethodError
          ;
        else
          num_retry -= 1
          if num_retry > 0
            sleep 1 and retry
          else
            raise e
          end
        end
      end
    end

  end
end
