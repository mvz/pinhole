module Pinhole
  class MainWindow
    GVS = []
    def initialize(provider)
      @provider = provider
    end

    def run
      Gtk.init

      setup_ui

      @window = built_object("mainwindow")
      @box = built_object("mainvbox")

      @browser = Browser.new
      @image = Image.new

      @box.pack_start(@browser, true, true, 0)
      @box.pack_start(@image, true, true, 0)

      @active_widget = @browser

      @browser.set_action do |iv, path|
	filename = iv.model.get_iter(path).get_value(0)
	@image.load_image_from_file(filename)

	@browser.visible = false
	@image.visible = true
	@active_widget = @image

	@image.zoom_fit
	@image.show_all
      end

      # FIXME: Implement Gtk::ListStore.new
      #@store = Gtk::ListStore.new(String, GdkPixbuf::Pixbuf, String)
      st = GObject.type_from_name "gchararray"
      pt = GdkPixbuf::Pixbuf.get_gtype
      @store = Gtk::ListStore.newv([st, pt, st])

      @provider.each { |f|
	pb = GdkPixbuf::Pixbuf.new_from_file_at_size(f, 100, 100)
	it = Gtk::TreeIter.new

	@store.append it

	gvstr = GObject::Value.new
	gvstr.init st

	gvpb = GObject::Value.new
	gvpb.init pt

	gvstr.set_string f
	# FIXME: Automate wrapping in GValues.
	@store.set_value it, 0, gvstr

	gvpb.set_instance pb
	@store.set_value it, 1, gvpb

	gvstr.set_string File.basename(f)
	@store.set_value it, 2, gvstr
      }

      @browser.set_model @store

      @window.show_all

      @browser.set_visible true
      @image.set_visible false

      Gtk.main
    end

    private

    def setup_ui
      @builder = Gtk::Builder.new
      @builder.add_from_file Pinhole.path "data", "pinhole.ui"
      # FIXME: Perhaps add override to simplify this method call.
      @builder.connect_signals_full Proc.new { |b,o,sn,hn,co,f,ud|
	sn.gsub! /_/, '-'
	GObject.signal_connect o, sn, &self.method(hn)
      }, nil
    end

    def built_object name
      @builder.get_object(name)
    end

    def on_mainwindow_destroy w, u
      Gtk.main_quit
    end

    def on_mainwindow_window_state_event w, e, u
      if e[:window_state][:new_window_state] == :fullscreen
	built_object("menubar").set_visible false
	built_object("statusbar").set_visible false
	@active_widget.fullscreen
	@fullscreen = true
      else
	built_object("menubar").set_visible true
	built_object("statusbar").set_visible true
	@active_widget.unfullscreen
	@fullscreen = false
      end
    end

    def on_menu_fullscreen_activate w, u
      if @fullscreen then
	@window.unfullscreen
      else
	@window.fullscreen
      end
    end

    def on_menu_zoom_in_activate w, u
      @active_widget.zoom_in
    end

    def on_menu_zoom_out_activate w, u
      @active_widget.zoom_out
    end

    def on_menu_zoom_fit_activate w, u
      @active_widget.zoom_fit
    end

    def on_menu_zoom_100_activate w, u
      @active_widget.zoom_100
    end

    def on_menu_cancel_activate w, u
      @image.visible = false
      @browser.visible = true
      @active_widget = @browser
    end
  end
end

