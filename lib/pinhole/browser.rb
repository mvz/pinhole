require 'forwardable'
module Pinhole
  class Browser < Gtk::ScrolledWindow
    def initialize ptr
      super ptr
      @iconview = Gtk::IconView.new
      self.add @iconview
      self.set_policy(:automatic, :automatic)
      @iconview.set_size_request 0, 0
      @iconview.set_text_column 2
      @iconview.set_pixbuf_column 1
    end

    def set_model(m)
      @iconview.set_model m
    end

    def set_action(&block)
      GObject.signal_connect @iconview, 'item-activated', &block
    end

    def unfullscreen; end
    def fullscreen; end
    def zoom_in; end
    def zoom_out; end
    def zoom_100; end
    def zoom_fit; end
  end
end
