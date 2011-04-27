# -*- mode: ruby; coding: utf-8 -*-

Dir.glob( File.dirname( __FILE__ ) + '/ics/*.rb' ).each { |f|
  require f.sub( /\.rb\z/, '' )
}
