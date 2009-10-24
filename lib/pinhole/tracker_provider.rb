require "dbus"

module Pinhole
  class TrackerProvider
    include Enumerable

    def initialize
      @session_bus = DBus::SessionBus.instance
      @tracker = @session_bus.service("org.freedesktop.Tracker")
    end

    def each
      # Returns an array of arrays of arrays. The first element of each
      # sub-array is the file name.
      list = searcher.Query(1, "Images", ["File:Mime"], "", [], "", false,
			     [], false, 0, 50)
      list[0].each {|e| yield e[0]}
    end

    private

    def searcher
      @searcher ||= get_iface("Search")
    end

    def get_iface(name)
      o = @tracker.object("/org/freedesktop/Tracker/#{name}")
      o.introspect
      if o.has_iface? "org.freedesktop.Tracker.#{name}"
	return o["org.freedesktop.Tracker.#{name}"]
      else
	puts "We have no #{name} interface"
	return nil
      end
    end
  end
end
