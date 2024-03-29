# frozen_string_literal: true

require "forwardable"
module Pinhole
  # Image viewer. Displays a single image and allows zooming
  class Image
    extend Forwardable
    def_delegators :@widget, :to_ptr, :set_visible, :show_all

    _, COLOR_BLACK = Gdk.color_parse "black"

    def initialize
      @widget = Gtk::ScrolledWindow.new nil, nil
      @eventbox = Gtk::EventBox.new
      @widget.add_with_viewport(@eventbox)
      @viewport = @widget.get_child
      @viewport.set_shadow_type :none

      # This line is needed to prevent the viewport from forcing a minimum
      # size on the window when the scroll bars are not visible
      @viewport.set_size_request(0, 0)

      setup_viewport_signal_handlers

      @zoom_mode = :manual
      @current_zoom = @wanted_zoom = 1.0

      @image = Gtk::Image.new
      @fullsize_buf = GdkPixbuf::Pixbuf.new(:rgb, false, 8, 1, 1)
      @eventbox.add(@image)
    end

    private

    def update_pixbuf
      return if @current_zoom == @wanted_zoom

      buf = if @wanted_zoom == 1.0
        @fullsize_buf
      else
        @fullsize_buf.scale_simple(
          @wanted_zoom * @fullsize_buf.width,
          @wanted_zoom * @fullsize_buf.height,
          :bilinear
        )
      end
      @image.set_from_pixbuf buf
      @current_zoom = @wanted_zoom
      GC.start
    end

    public

    def fullscreen
      @eventbox.modify_bg :normal, COLOR_BLACK
      @fullscreen = true
      update_scrollbar_policy
    end

    def unfullscreen
      @eventbox.modify_bg :normal, nil
      @fullscreen = false
      update_scrollbar_policy
    end

    def load_image_from_file(filename)
      @current_zoom = 0.0 # HACK: Force image reload
      @fullsize_buf = GdkPixbuf::Pixbuf.new_from_file(filename)
    end

    def zoom_in
      @zoom_mode = :manual
      update_scrollbar_policy
      self.wanted_zoom = @wanted_zoom * 1.15
    end

    def zoom_out
      @zoom_mode = :manual
      update_scrollbar_policy
      self.wanted_zoom = @wanted_zoom / 1.15
    end

    def zoom_fit
      @zoom_mode = :fit
      update_scrollbar_policy
      self.wanted_zoom = image_fit_zoom
    end

    def zoom_100
      @zoom_mode = :manual
      update_scrollbar_policy
      self.wanted_zoom = 1.0
    end

    private

    def image_fit_zoom
      alloc = @widget.allocation
      [
        (1.0 * alloc.width) / @fullsize_buf.width,
        (1.0 * alloc.height) / @fullsize_buf.height,
        1.0
      ].min
    end

    def wanted_zoom=(zoom)
      return if zoom <= 0.0

      @wanted_zoom = zoom
      update_pixbuf
    end

    def update_scrollbar_policy
      if @fullscreen || @zoom_mode == :fit
        @widget.set_policy(:never, :never)
      else
        @widget.set_policy(:automatic, :automatic)
      end
    end

    def setup_viewport_signal_handlers
      GObject.signal_connect @viewport, "button-press-event" do |widget, event|
        on_viewport_button_press_event widget, event
      end

      GObject.signal_connect @viewport, "button-release-event" do |widget, event|
        on_viewport_button_release_event widget, event
      end

      GObject.signal_connect @viewport, "motion-notify-event" do |widget, event|
        on_viewport_motion_notify_event widget, event
      end

      GObject.signal_connect @viewport, "size-allocate" do
        on_viewport_size_allocate
      end
    end

    def on_viewport_button_press_event(_widget, event)
      @dragging = true
      @dragx = event.x_root
      @dragy = event.y_root

      @scrollx = @viewport.hadjustment.value
      @scrolly = @viewport.vadjustment.value
      @viewport.window.set_cursor Gdk::Cursor.new(:fleur)
    end

    def on_viewport_button_release_event(_widget, _event)
      @dragging = false
      @viewport.window.set_cursor nil
    end

    def on_viewport_motion_notify_event(_widget, event)
      return false unless @dragging

      dx = event.x_root - @dragx
      dy = event.y_root - @dragy

      set_adjustment(@viewport.hadjustment, @scrollx - dx)
      set_adjustment(@viewport.vadjustment, @scrolly - dy)
    end

    def on_viewport_size_allocate
      if @zoom_mode == :fit
        zoom = image_fit_zoom
        return true if zoom == @wanted_zoom

        @wanted_zoom = zoom

        # Trick from Eye of Gnome: do fast scale now ...
        b = @fullsize_buf.scale_simple(
          @wanted_zoom * @fullsize_buf.width,
          @wanted_zoom * @fullsize_buf.height,
          :nearest
        )
        @image.set_from_pixbuf b

        # ... and delay slow scale till later.
        # FIXME: Allow priority to be left out.
        GLib.idle_add(GLib::PRIORITY_DEFAULT_IDLE) { update_pixbuf }
      end
      true
    end

    def set_adjustment(adj, val)
      max = adj.upper - adj.page_size
      val = max if val > max
      val = 0 if val < 0
      adj.set_value val
    end
  end
end
