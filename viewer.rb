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

    @window = @builder["mainwindow"]
    @mainbox = @builder["eventbox"]
    buf = Gdk::Pixbuf.new(@filename, 1024, 768)
    im = Gtk::Image.new(buf)
    @mainbox.add(im)
    @window.signal_connect("destroy") { Gtk.main_quit }
    @window.signal_connect("window-state-event") {|w,e,d|
      if e.new_window_state.fullscreen?
	@builder["menubar"].visible = false
	@builder["statusbar"].visible = false
      else
	@builder["menubar"].visible = true
	@builder["statusbar"].visible = true
      end
    }
    @window.show_all
    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "rthumb.xml"
    @builder.connect_signals { |name| method(name) }
  end

  def on_menu_fullscreen_activate
    if @fullscreen then
      @fullscreen = false
      @window.unfullscreen
    else
      @fullscreen = true
      @window.fullscreen
    end
  end
end

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
