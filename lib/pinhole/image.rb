module Pinhole
  class Image < Gtk::ScrolledWindow

    #COLOR_BLACK = Gdk::Color.new(0, 0, 0)

    def initialize
      super
      @eventbox = Gtk::EventBox.new
      self.add_with_viewport(@eventbox)
      @viewport = self.child
      @viewport.shadow_type = Gtk::ShadowType::NONE

      # This line is needed to prevent the viewport from forcing a minimum
      # size on the window when the scroll bars are not visible
      @viewport.set_size_request(0,0)

      setup_viewport_signal_handlers

      @zoom_mode = :manual
      @current_zoom = @wanted_zoom = 1.0

      @image = Gtk::Image.new
      @fullsize_buf = Gdk::Pixbuf.new(
	Gdk::Pixbuf::COLORSPACE_RGB, false, 8, 1, 1)
      @eventbox.add(@image)
    end

    private

    def update_pixbuf
      return if @current_zoom == @wanted_zoom
      if @wanted_zoom == 1.0
	@image.pixbuf = @fullsize_buf
      else
	b = @fullsize_buf.scale(@wanted_zoom * @fullsize_buf.width,
				@wanted_zoom * @fullsize_buf.height,
				Gdk::Pixbuf::INTERP_BILINEAR)
	@image.pixbuf = b
      end
      @current_zoom = @wanted_zoom
      GC.start
    end

    public

    def fullscreen
      #@eventbox.modify_bg Gtk::STATE_NORMAL, COLOR_BLACK
      @fullscreen = true
      update_scrollbar_policy
    end

    def unfullscreen
      @eventbox.modify_bg Gtk::STATE_NORMAL, nil
      @fullscreen = false
      update_scrollbar_policy
    end

    def load_image_from_file filename
      @fullsize_buf = Gdk::Pixbuf.new(filename)
    end

    def zoom_in
      @zoom_mode = :manual
      update_scrollbar_policy
      set_zoom @wanted_zoom * 1.15
    end

    def zoom_out
      @zoom_mode = :manual
      update_scrollbar_policy
      set_zoom @wanted_zoom / 1.15
    end

    def zoom_fit
      @zoom_mode = :fit
      update_scrollbar_policy
      set_zoom image_fit_zoom
    end

    def zoom_100
      @zoom_mode = :manual
      update_scrollbar_policy
      set_zoom 1.0
    end

    private

    def image_fit_zoom
      [(1.0 * allocation.width) / @fullsize_buf.width,
	(1.0 * allocation.height) / @fullsize_buf.height,
	1.0].min
    end

    def set_zoom zoom
      return if zoom <= 0.0
      @wanted_zoom = zoom
      update_pixbuf
    end

    def update_scrollbar_policy
      if @fullscreen or @zoom_mode == :fit
	self.set_policy(:never, :never)
      else
	self.set_policy(:automatic, :automatic)
      end
    end

    def setup_viewport_signal_handlers
      @viewport.signal_connect "button-press-event" do |w, e|
	on_viewport_button_press_event w, e
      end

      @viewport.signal_connect "button-release-event" do |w, e|
	on_viewport_button_release_event w, e
      end

      @viewport.signal_connect "motion-notify-event" do |w, e|
	on_viewport_motion_notify_event w, e
      end

      @viewport.signal_connect "size-allocate" do
	on_viewport_size_allocate
      end
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
	zoom = image_fit_zoom
	return true if zoom == @wanted_zoom
	@wanted_zoom = zoom

	# Trick from Eye of Gnome: do fast scale now ...
	b = @fullsize_buf.scale(@wanted_zoom * @fullsize_buf.width,
				@wanted_zoom * @fullsize_buf.height,
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
end
