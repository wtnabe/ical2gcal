require 'launchy'
require 'json'

module Ical2gcal
  module Google
    class Credential
    #
    # [param] String cabinet
    #
    def initialize(cabinet = nil)
      @cabinet = cabinet
      prepare
    end
    attr_accessor :client_id, :client_secret
    attr_reader   :token

    #
    # [param]  String refresh_token
    # [return] Hash
    #
    def token=(refresh_token)
      @token = refresh_token
      store
    end

    #
    # [return] Hash
    #
    def prepare
      load
      (keys - [:token]).each {|k|
        unless send(k)
          STDERR.puts "Please setup #{k.upcase}"
          send("#{k}=", $stdin.gets.chomp)
        end
      }
      store
    end

    #
    # [return] Array
    #
    def keys
      [:client_id, :client_secret, :token]
    end

    #
    # [return] String
    #
    def cabinet
      if ( !@cabinet )
        @cabinet = File.join(ENV['HOME'], '.ical2gcal_credentials')
      end

      @cabinet
    end

    #
    # [return] Hash
    #
    def to_hash
      Hash[*keys.map {|k| [k, send(k)]}.flatten]
    end

    #
    # [return] Hash
    #
    def store
      hash = to_hash
      open(cabinet, 'wb', 0600) {|f| f.puts JSON.dump(hash)}

      hash
    end

    #
    # [return] Hash or nil
    #
    def load
      if File.exist?(cabinet) and File.size(cabinet) > 0
        hash = JSON.parse(open(cabinet).read)
        hash.each {|k, v| send("#{k}=", v)} if hash

        hash
      end
    end
    end
  end
end
