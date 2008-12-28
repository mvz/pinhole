require 'optparse'
require 'gtk2'

class Viewer
  def initialize(filename)
    @filename = filename
  end

  def run
    Gtk.init

    window = Gtk::Window.new
    buf = Gdk::Pixbuf.new(@filename, 1024, 768)
    im = Gtk::Image.new(buf)
    eb = Gtk::EventBox.new.add(im)
    window.signal_connect("destroy") { Gtk.main_quit }
    window.border_width = 0
    window.add(eb)
    window.show_all
    Gtk.main
  end
end

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
