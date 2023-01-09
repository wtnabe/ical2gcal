# -*- mode: ruby; coding: utf-8 -*-

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/file_storage'
require_relative '../monkey_patches/multi_json'

module Ical2gcal
  class Google

    class CalendarIdNotDefined < StandardError; end

    #
    # [param] String calendar_id
    # [param] String store
    #
    def initialize(calendar_id, store = nil)
      raise CalendarIdNotDefined.new unless calendar_id

      @calendar_id = nil
      @calendar    = nil # Calendar API
      @client      = nil # Google API Client
      @events      = nil

      init_and_auth_calendar(calendar_id, store)
    end
    attr_reader :client, :calendar, :calendar_id

    #
    # [param] String calendar_id
    # [param] String dir
    # [return] Object Calendar API
    #
    def init_and_auth_calendar(calendar_id, store)
      @client = ::Google::APIClient.new(
                                  :application_name    => :ical2gcal,
                                  :application_version => Ical2gcal::VERSION,
                                  :user_agent => "ical2gcal-#{Ical2gcal::VERSION} (#{RUBY_PLATFORM})"
      )

      credential = ::Google::APIClient::FileStorage.new(store)
      secrets    = ::Google::APIClient::ClientSecrets.load(File.dirname(store))

      if credential.authorization.nil?
        flow = ::Google::APIClient::InstalledAppFlow.new(
          :client_id     => secrets.client_id,
          :client_secret => secrets.client_secret,
          :scope         => 'https://www.googleapis.com/auth/calendar')
        client.authorization = flow.authorize
        credential.write_credentials(client.authorization)
      else
        client.authorization = credential.authorization
      end

      @calendar_id = calendar_id
      @calendar    = client.discovered_api('calendar', 'v3')
    end

    #
    # [param]  RiCal::Component::Event
    # [return] String
    #
    def create_event( event )
      body = {:summary => event.summary.force_encoding('UTF-8')}
      body.merge!(:description => event.description.force_encoding('UTF-8')) if event.description
      body.merge!(:location    => event.location.force_encoding('UTF-8')) if event.location

      if all_day?(event)
        start_date = event.dtstart.to_s
        end_date   = event.dtend.to_s

        body.merge!(
          :start => {:date => start_date},
          :end   => {:date => end_date.size > 0 ? end_date : (Date.parse(start_date) + 1).to_s})
      else
        body.merge!(
          :start => {:dateTime => localtime(event.start_time)},
          :end   => {:dateTime => localtime((event.respond_to? :end_time) ? event.end_time : event.start_time)})
      end

      client.execute(
        :api_method => calendar.events.insert,
        :parameters => {:calendarId  => calendar_id},
        :headers    => {'Content-Type' => 'application/json'},
        :body       => JSON.dump(body)).response.body
    end

    #
    # [param]  Rical::Component::Event event
    # [return] Boolean
    #
    def all_day?(event)
      event.dtstart.class == Date
    end

    #
    # create Time object with local timezone
    #
    # [param]  String datetime
    # [return] String
    #
    def localtime(datetime)
      Time.parse(datetime.iso8601.sub(/(\+.*)\z/, '')).iso8601
    end

    def remove_all_events
      all_events.each {|e| remove_one_event(e)}
    end

    #
    # remove one event with retry
    #
    # [param] GoogleCalendar::Event
    #
    def remove_one_event(event)
      client.execute(
        :api_method => calendar.events.delete,
        :parameters => {:calendarId => calendar_id, :eventId => event['id']})
    end

    #
    # [return] Array
    #
    def all_events
      result = events_request
      events = result['items']
      while ( result['nextPageToken'] )
        result = events_request(result['nextPageToken'])
        events += result['items']
      end

      events
    end

    #
    # [param]  String next_page_token
    # [return] Hash
    #
    def events_request(next_page_token = nil)
      params = {:calendarId => calendar_id}
      params.merge!(:pageToken => next_page_token) if next_page_token

      JSON.parse(client.execute(
                        :api_method => calendar.events.list,
                        :parameters => params).response.body)
    end
  end
end
