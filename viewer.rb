require 'optparse'
require 'gtk2'
require 'image'

class Viewer
  def initialize(filename)
    @filename = filename
  end

  def run
    Gtk.init

    setup_ui

    @fullscreen = false

    @window = @builder["mainwindow"]

    @scrolledwindow.load_image_from_file(@filename)
    @window.show_all

    on_menu_zoom_fit_activate

    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "rthumb.xml"
    @builder.connect_signals { |name| method(name) }

    @scrolledwindow = Image.new

    @builder["mainvbox"].pack_start(@scrolledwindow)
  end

  def on_mainwindow_destroy
    Gtk.main_quit
  end

  def on_mainwindow_window_state_event w, e
    if e.new_window_state.fullscreen?
      @builder["menubar"].visible = false
      @builder["statusbar"].visible = false
      @scrolledwindow.fullscreen
      @fullscreen = true
    else
      @builder["menubar"].visible = true
      @builder["statusbar"].visible = true
      @scrolledwindow.unfullscreen
      @fullscreen = false
    end
    update_scrollbar_policy
  end

  def on_menu_fullscreen_activate
    if @fullscreen then
      @window.unfullscreen
    else
      @window.fullscreen
    end
  end

  def on_menu_zoom_in_activate
    @scrolledwindow.zoom_in
  end

  def on_menu_zoom_out_activate
    @scrolledwindow.zoom_out
  end

  def on_menu_zoom_fit_activate
    @scrolledwindow.zoom_fit
  end

  def on_menu_zoom_100_activate
    @scrolledwindow.zoom_100
  end

  def set_zoom new_zoom
    @scrolledwindow.set_zoom new_zoom
  end

  def image_fit_zoom
    @scrolledwindow.image_fit_zoom
  end

  # TODO: deprecate
  def update_scrollbar_policy
    @scrolledwindow.update_scrollbar_policy
  end

  def on_viewport_button_press_event w, e
    @dragging = true
    @dragx = e.x_root
    @dragy = e.y_root

    @scrollx = @viewport.hadjustment.value
    @scrolly = @viewport.vadjustment.value
    @viewport.window.cursor = Gdk::Cursor.new(Gdk::Cursor::FLEUR)
  end

  def on_viewport_button_release_event w, e
    @dragging = false
    @viewport.window.cursor = nil
  end

  def on_viewport_motion_notify_event w, e
    return false unless @dragging
    dx = e.x_root - @dragx
    dy = e.y_root - @dragy

    set_adjustment(@viewport.hadjustment, @scrollx - dx)
    set_adjustment(@viewport.vadjustment, @scrolly - dy)
  end

  def on_viewport_size_allocate
    if @zoom_mode == :fit
      new_zoom = image_fit_zoom
      return true if new_zoom == @requested_zoom
      @requested_zoom = new_zoom

      # Trick from Eye of Gnome: do fast scale now ...
      b = @fullsize_buf.scale(@requested_zoom * @fullsize_buf.width,
			      @requested_zoom * @fullsize_buf.height,
			      Gdk::Pixbuf::INTERP_NEAREST)
      @image.pixbuf = b

      # ... and delay slow scale till later.
      Gtk.idle_add { @scrolledwindow.update_pixbuf }
    end
    return true
  end

  def set_adjustment adj, val
    max = adj.upper - adj.page_size
    val = max if val > max
    val = 0 if val < 0
    adj.value = val
  end
end

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
