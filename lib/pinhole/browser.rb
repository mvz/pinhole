require 'gtk2'

module Pinhole
  class Browser < Gtk::ScrolledWindow
    def initialize
      super
      @iconview = Gtk::IconView.new
      self.add @iconview
      self.set_policy(:automatic, :automatic)
      @iconview.set_size_request 0, 0
      @iconview.text_column = 0
      @iconview.pixbuf_column = 1
    end

    def model= m
      @iconview.model = m
    end

    def set_action &block
      @iconview.signal_connect "item-activated", &block
    end
  end
end
