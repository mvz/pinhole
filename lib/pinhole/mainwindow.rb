require 'gtk2'

module Pinhole
  class MainWindow
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
      @builder.add Pinhole.path "data", "pinhole.xml"
      @builder.connect_signals { |name| method(name) }
    end

    def on_mainwindow_destroy
      Gtk.main_quit
    end

    def on_mainwindow_window_state_event w, e
    end

    def on_menu_fullscreen_activate
    end

    def on_menu_zoom_in_activate
    end

    def on_menu_zoom_out_activate
    end

    def on_menu_zoom_fit_activate
    end

    def on_menu_zoom_100_activate
    end
  end
end

