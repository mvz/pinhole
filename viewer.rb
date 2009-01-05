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

    @fullsize_buf = Gdk::Pixbuf.new(@filename) #, 1024, 768)
    @image = Gtk::Image.new
    @image.pixbuf = @fullsize_buf
    @mainbox.add(@image)

    @requested_zoom = 1.0
    @zoom = 1.0
    @zoom_mode = :manual

    #Gtk.idle_add { puts "Hello" }

    @window.show_all
    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "rthumb.xml"
    @builder.connect_signals { |name| method(name) }

    # This line is needed to prevent the viewport from forcing a minimum
    # size on the window when the scroll bars are not visible
    @builder["viewport"].set_size_request(0,0)
  end

  def on_mainwindow_destroy
    Gtk.main_quit
  end

  def on_mainwindow_window_state_event w, e
    if e.new_window_state.fullscreen?
      @builder["menubar"].visible = false
      @builder["statusbar"].visible = false
    else
      @builder["menubar"].visible = true
      @builder["statusbar"].visible = true
    end
    update_scrollbar_policy
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

  def on_menu_zoom_in_activate
    @zoom_mode = :manual
    update_scrollbar_policy
    set_zoom @requested_zoom * 1.15
  end

  def on_menu_zoom_out_activate
    @zoom_mode = :manual
    update_scrollbar_policy
    set_zoom @requested_zoom / 1.15
  end

  def on_menu_zoom_fit_activate
    @zoom_mode = :fit
    update_scrollbar_policy
    set_zoom image_fit_zoom
  end

  def on_menu_zoom_100_activate
    @zoom_mode = :manual
    update_scrollbar_policy
    set_zoom 1.0
  end

  def set_zoom new_zoom
    return if new_zoom <= 0.0
    @requested_zoom = new_zoom
    update_pixbuf
  end

  def image_fit_zoom
    alloc = @builder["scrolledwindow"].allocation
    
    zoom = [(1.0 * alloc.width) / @fullsize_buf.width,
      (1.0 * alloc.height) / @fullsize_buf.height,
      1.0].min

    return zoom
  end

  def update_pixbuf
    return if @zoom == @requested_zoom
    if @requested_zoom == 1.0
      @image.pixbuf = @fullsize_buf
    else
      b = @fullsize_buf.scale(@requested_zoom * @fullsize_buf.width,
			      @requested_zoom * @fullsize_buf.height,
			      Gdk::Pixbuf::INTERP_BILINEAR)
      @image.pixbuf = b
    end
    @zoom = @requested_zoom
    GC.start
  end

  def update_scrollbar_policy
    if @fullscreen or @zoom_mode == :fit
      @builder["scrolledwindow"].set_policy(:never, :never)
    else
      @builder["scrolledwindow"].set_policy(:automatic, :automatic)
    end
  end

  def on_viewport_button_press_event w, e
    @dragging = true
    @dragx = e.x_root
    @dragy = e.y_root

    viewport = @builder["viewport"]

    @scrollx = viewport.hadjustment.value
    @scrolly = viewport.vadjustment.value
    viewport.window.cursor = Gdk::Cursor.new(Gdk::Cursor::FLEUR)
  end

  def on_viewport_button_release_event w, e
    @dragging = false
    @builder["viewport"].window.cursor = nil
  end

  def on_viewport_motion_notify_event w, e
    return false unless @dragging
    dx = e.x_root - @dragx
    dy = e.y_root - @dragy

    viewport = @builder["viewport"]

    set_adjustment(viewport.hadjustment, @scrollx - dx)
    set_adjustment(viewport.vadjustment, @scrolly - dy)
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
      Gtk.idle_add { update_pixbuf }
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
