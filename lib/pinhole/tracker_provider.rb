# frozen_string_literal: true

require "gir_ffi-tracker"
require "cgi"

module Pinhole
  # Image provider using the Tracker file searcher as its backend
  class TrackerProvider
    include Enumerable

    def each
      cursor = searcher.query <<~SPARQL
        SELECT ?url
        WHERE {
                ?photo a nmm:Photo .
                ?photo nie:isStoredAs ?url .
        }
        LIMIT 10
      SPARQL

      while cursor.next
        uri = cursor.get_string 0
        yield CGI.unescape(uri.gsub(%r{file://}, ""))
      end
    end

    private

    def searcher
      @searcher ||=
        Tracker::SparqlConnection.bus_new("org.freedesktop.Tracker3.Miner.Files")
    end
  end
end
