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
    buf = Gdk::Pixbuf.new(@filename) #, 1024, 768)
    im = Gtk::Image.new(buf)
    @mainbox.add(im)
    @window.show_all
    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "rthumb.xml"
    @builder.connect_signals { |name| method(name) }

    @builder["viewport"].set_size_request(0,0)
  end

  def on_mainwindow_destroy
    Gtk.main_quit
  end

  def on_mainwindow_window_state_event w, e
    if e.new_window_state.fullscreen?
      @builder["menubar"].visible = false
      @builder["statusbar"].visible = false
      @builder["scrolledwindow"].set_policy(:never, :never)
    else
      @builder["menubar"].visible = true
      @builder["statusbar"].visible = true
      @builder["scrolledwindow"].set_policy(:automatic, :automatic)
    end
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

  def on_viewport_button_press_event w, e
    @dragging = true
    @dragx = e.x_root
    @dragy = e.y_root
    @scrollx = @builder["viewport"].hadjustment.value
    @scrolly = @builder["viewport"].vadjustment.value
  end

  def on_viewport_button_release_event w, e
    @dragging = false
  end

  def on_viewport_motion_notify_event w, e
    return false unless @dragging
    dx = e.x_root - @dragx
    dy = e.y_root - @dragy

    @builder["viewport"].hadjustment.value = @scrollx - dx
    @builder["viewport"].vadjustment.value = @scrolly - dy
  end
end

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
