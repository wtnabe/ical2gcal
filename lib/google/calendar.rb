# -*- mode: ruby; coding: utf-8 -*-

require 'google_calendar'
require 'json'
require 'time'
require File.dirname(__FILE__) + '/credential'

module Ical2gcal
  module Google
    class Calendar

    #
    # [param] String id
    # [param] String credential_store
    #
    def initialize(id, credential_store =nil)
      @calendar = nil

      auth_and_init_calendar(id, credential_store)
    end
    attr_reader :calendar

    #
    # [param]  String id
    # [param]  String id
    # [return] Google::Calendar
    #
    def auth_and_init_calendar(id, store)
      credential = Ical2gcal::Google::Credential.new(store)

      cal = ::Google::Calendar.new(
        client_id:     credential.client_id,
        client_secret: credential.client_secret,
        calendar:      id,
        redirect_url:  'urn:ietf:wg:oauth:2.0:oob')

      if credential.token
        cal.login_with_refresh_token(credential.token)
      else
        STDERR.puts 'open google to authorize this app and fetch token, and type that'
        Launchy.open(cal.authorize_url)
        credential.token = cal.login_with_auth_code($stdin.gets.chomp)
      end

      if credential.token
        @calendar = cal
      end
    end

    def create_event( event )
      e             = calendar.create_event
      e.title       = event.summary.gsub(/[\r\n]/, " ")
      e.description = event.description.gsub(/[\r\n]/, " ")
      e.location    = event.location if event.location

      start_time    = Time.parse(event.start_time.to_s.sub(/\+.*/, ''))
      e.start_time  = start_time

      if event.respond_to? :end_time
        e.end_time = Time.parse(event.end_time.to_s.sub(/\+.*/, ''))
      elsif start_time.localtime.hour == 0 and start_time.localtime.min == 0
        e.end_time = start_time + 60 * 60 * 24
      else
        e.end_time = start_time
      end

      e.save
    end

    def remove_all_events
      max_retry = 3

      omni_retry = max_retry

      while calendar.events.size > 0 and omni_retry > 0
        calendar.events.each { |e|
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
    def remove_one_event(evt, num_retry)
      begin
        evt.delete
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
end
