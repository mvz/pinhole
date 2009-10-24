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
      @box = @builder["mainvbox"]

      @browser.set_action do |iv, path|
	filename = iv.model.get_iter(path).get_value(0)
	@scrolledwindow.load_image_from_file(filename)
	@box.remove @browser
	@box.pack_start @scrolledwindow
	@scrolledwindow.zoom_fit
	@scrolledwindow.show_all
      end

      @box.pack_start(@browser)

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
      @scrolledwindow = Image.new
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
  end
end

