# -*- coding: utf-8 -*-

#
# iCal format may include more than one calendars, but this force flatten them
#

require 'ri_cal'

module Ical2gcal
  module Ics
    class Events
      def initialize( uri )
        @uri       = uri
        @calendars = nil
      end

      def calendars
        if ( @uri and !@calendars )
          @calendars = RiCal.parse( open( @uri ) )
        end

        @calendars
      end

      def get
        calendars.map { |c| c.events }.flatten
      end

      def each( &block )
        calendars.each { |c|
          c.events.each { |e|
            block.call( e )
          }
        }
      end
    end
  end
end
