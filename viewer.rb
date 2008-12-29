require 'optparse'
require 'gtk2'

class Viewer
  def initialize(filename)
    @filename = filename
  end

  def run
    Gtk.init

    setup_ui

    @fullscreen = false

    buf = Gdk::Pixbuf.new(@filename, 1024, 768)
    im = Gtk::Image.new(buf)
    @eventbox.add(im)
    @window.signal_connect("destroy") { Gtk.main_quit }
    @window.show_all
    Gtk.main
  end

  private

  def setup_ui
    b = Gtk::Builder.new
    b.add("rthumb.xml")
    @window = b["window1"]
    @eventbox = b["eventbox1"]
  end

  def toggle_fullscreen
    if @fullscreen then
      @fullscreen = false
      stop_fullscreen
    else
      @fullscreen = true
      run_fullscreen
    end
  end

  def run_fullscreen
    @window.fullscreen
  end

  def stop_fullscreen
    @window.unfullscreen
  end
end

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
