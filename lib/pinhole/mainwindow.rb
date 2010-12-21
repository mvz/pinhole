module Pinhole
  class MainWindow
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

      @box.pack_start(@browser, false, false, 0)
      @box.pack_start(@image, false, false, 0)

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

      @store = Gtk::ListStore.new(String, GdkPixbuf::Pixbuf, String)

      @provider.each { |f|
	pb = GdkPixbuf::Pixbuf.new(f, 100, 100)
	@store.append.set_value(0, f).
	  set_value(1, pb).set_value(2, File.basename(f))
      }

      @browser.model = @store

      @window.show_all

      @browser.visible = true
      @image.visible = false

      Gtk.main
    end

    private

    def setup_ui
      @builder = Gtk::Builder.new
      @builder.add_from_file Pinhole.path "data", "pinhole.ui"
      # FIXME: Add override to simplify this method call.
      @builder.connect_signals_full Proc.new { |b,o,sn,hn,co,f,ud|
	sn.gsub! /_/, '-'
	GObject.signal_connect cast_object_pointer(o), sn, self.method(hn)
      }, nil
    end

    # FIXME: Make part of gir_ffi.
    def cast_object_pointer optr
      tp = GObject.type_from_instance_pointer optr
      gir = GirFFI::IRepository.default
      info = gir.find_by_gtype tp
      klass = GirFFI::Builder.build_class info.namespace, info.name
      klass.send :_real_new, optr
    end

    # FIXME: Adjust Gtk::Builder#get_object
    def built_object name
      cast_object_pointer(@builder.get_object(name).to_ptr)
    end

    def on_mainwindow_destroy
      Gtk.main_quit
    end

    def on_mainwindow_window_state_event w, e
      if e.new_window_state.fullscreen?
	built_object("menubar").visible = false
	built_object("statusbar").visible = false
	@active_widget.fullscreen
	@fullscreen = true
      else
	built_object("menubar").visible = true
	built_object("statusbar").visible = true
	@active_widget.unfullscreen
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
      @active_widget.zoom_in
    end

    def on_menu_zoom_out_activate
      @active_widget.zoom_out
    end

    def on_menu_zoom_fit_activate
      @active_widget.zoom_fit
    end

    def on_menu_zoom_100_activate
      @active_widget.zoom_100
    end

    def on_menu_cancel_activate
      @image.visible = false
      @browser.visible = true
      @active_widget = @browser
    end
  end
end

