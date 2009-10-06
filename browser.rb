require 'optparse'
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

class Browser
  def initialize(provider)
    @provider = provider
  end

  def run
    Gtk.init

    setup_ui

    @window = @builder["mainwindow"]

    @browser = Pinhole::Browser.new

    @browser.set_action do |iv, path|
      p iv.model.get_iter(path).get_value(0)
    end
    @builder["mainvbox"].pack_start(@browser)

    @store = Gtk::ListStore.new(String, Gdk::Pixbuf)

    @provider.each { |f|
      pb = Gdk::Pixbuf.new(f, 100, 100)
      @store.append.set_value(0, f).set_value(1, pb)
    }

    @browser.model = @store

    @window.show_all

    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "browser.xml"
    @builder.connect_signals { |name| method(name) }
  end

  def on_mainwindow_destroy
    Gtk.main_quit
  end
end

Browser.new(Dir.glob("*.jpg")).run
