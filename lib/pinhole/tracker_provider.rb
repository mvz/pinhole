require 'dbus'
require 'cgi'

module Pinhole
  class TrackerProvider
    include Enumerable

    def initialize
      @session_bus = DBus::SessionBus.instance
      @tracker = @session_bus.service('org.freedesktop.Tracker1')
    end

    def each
      # Returns an array of arrays of arrays. The first element of each
      # sub-array is the file name.
      list = searcher.SparqlQuery "
      SELECT ?url ?typ
      WHERE {
              ?photo a nmm:Photo ;
                      nie:isStoredAs ?as .
              ?as nie:url ?url .
              ?photo nie:mimeType ?typ .
      }
      LIMIT 10
      "

      list[0].each do |e|
        yield CGI.unescape(e[0].gsub(/file:\/\//, '')) # if e[3] != ""
      end
    end

    private

    def searcher
      @searcher ||= get_iface('Resources')
    end

    def get_iface(name)
      o = @tracker.object("/org/freedesktop/Tracker1/#{name}")
      o.introspect
      unless o.has_iface? "org.freedesktop.Tracker1.#{name}"
        raise "We have no #{name} interface"
      end
      o["org.freedesktop.Tracker1.#{name}"]
    end
  end
end
