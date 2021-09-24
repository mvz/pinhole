# frozen_string_literal: true

require "forwardable"
module Pinhole
  # Image browser. Displays images as a set of icons.
  class Browser
    extend Forwardable
    def_delegators :@widget, :to_ptr, :set_visible

    def initialize
      @widget = Gtk::ScrolledWindow.new nil, nil
      @iconview = Gtk::IconView.new
      @widget.add @iconview
      @widget.set_policy(:automatic, :automatic)
      @iconview.set_size_request 0, 0
      @iconview.set_text_column 2
      @iconview.set_pixbuf_column 1
      @iconview.set_has_tooltip false
      @iconview.set_item_width 100
    end

    def model=(model)
      @iconview.set_model model
    end

    def connect_activation_signal(&block)
      GObject.signal_connect @iconview, "item-activated", &block
    end

    def unfullscreen
    end

    def fullscreen
    end

    def zoom_in
    end

    def zoom_out
    end

    def zoom_100
    end

    def zoom_fit
    end
  end
end
