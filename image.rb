class Image < Gtk::ScrolledWindow

  COLOR_BLACK = Gdk::Color.new(0, 0, 0)

  def initialize
    super
    @eventbox = Gtk::EventBox.new
    self.add_with_viewport(@eventbox)
    @viewport = self.child
    @viewport.shadow_type = Gtk::ShadowType::NONE

    # This line is needed to prevent the viewport from forcing a minimum
    # size on the window when the scroll bars are not visible
    @viewport.set_size_request(0,0)

    @image = Gtk::Image.new
    @eventbox.add(@image)
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

  def fullscreen
    @eventbox.modify_bg Gtk::STATE_NORMAL, COLOR_BLACK
    @fullscreen = true
    update_scrollbar_policy
  end

  def unfullscreen
    @eventbox.modify_bg Gtk::STATE_NORMAL, nil
    @fullscreen = false
    update_scrollbar_policy
  end

  def update_scrollbar_policy
    if @fullscreen or @zoom_mode == :fit
      self.set_policy(:never, :never)
    else
      self.set_policy(:automatic, :automatic)
    end
  end

  def load_image_from_file filename
    @fullsize_buf = Gdk::Pixbuf.new(filename)
  end

  def zoom_in
    @zoom_mode = :manual
    update_scrollbar_policy
    set_zoom @requested_zoom * 1.15
  end

  def zoom_out
    @zoom_mode = :manual
    update_scrollbar_policy
    set_zoom @requested_zoom / 1.15
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

  def image_fit_zoom
    [(1.0 * allocation.width) / @fullsize_buf.width,
      (1.0 * allocation.height) / @fullsize_buf.height,
      1.0].min
  end

  def set_zoom new_zoom
    return if new_zoom <= 0.0
    @requested_zoom = new_zoom
    update_pixbuf
  end

end
