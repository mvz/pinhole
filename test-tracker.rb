require "dbus"

class IfaceProvider
  def initialize
    @session_bus = DBus::SessionBus.instance
    @tracker = @session_bus.service("org.freedesktop.Tracker")
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

provider = IfaceProvider.new

meta = provider.get_iface("Metadata")

p meta.GetCount("Images", "File:Mime", "")

search = provider.get_iface("Search")
p search.GetHitCount("Images", "image")
#p search.Text(1, "Images", "Canon", 0, 10)
p search.Query(1, "Images", ["File:Mime"], "", [], "", false, [], false, 0, 10)
#p player_with_iface.getPlayingUri

