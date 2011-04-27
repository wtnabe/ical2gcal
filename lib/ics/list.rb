# -*- coding: utf-8 -*-

require 'open-uri'

module Ical2gcal
  module Ics
    class List
      def initialize( uri = nil )
        @uri   ||= uri
        @icses =   nil
      end

      def import( uri = nil )
        @uri = uri if uri

        if ( @uri )
          @icses = open( @uri ).read.split( /[\r\n]+/ )
        end
      end

      def list
        @icses || []
      end

      def with_scheme?
        ( %r!\A[a-z]+://! =~ @uri ) ? true : false
      end
    end
  end
end
