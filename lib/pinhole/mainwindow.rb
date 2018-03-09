# frozen_string_literal: true

require 'pinhole/browser'
require 'pinhole/image'

module Pinhole
  # Main window for the Pinhole application
  class MainWindow
    def initialize(provider)
      @provider = provider
    end

    def run
      Gtk.init

      setup_ui

      @window = built_object('mainwindow')
      @box = built_object('mainvbox')

      @browser = Browser.new
      @image = Image.new

      @box.pack_start(@browser, true, true, 0)
      @box.pack_start(@image, true, true, 0)

      @active_widget = @browser

      @browser.connect_activation_signal do |view, path|
        model = view.model

        r, it = model.get_iter(path)

        next unless r

        filename = model.get_value(it, 0)

        @image.load_image_from_file(filename)

        @browser.set_visible false
        @image.set_visible true
        @active_widget = @image

        @image.zoom_fit
        @image.show_all
      end

      st = GObject.type_from_name 'gchararray'
      pt = GdkPixbuf::Pixbuf.gtype
      @store = Gtk::ListStore.new([st, pt, st])

      @provider.each do |f|
        it = @store.append

        unless File.exist? f
          warn "File #{f} does not exist"
          next
        end
        gf = Gio.file_new_for_path(f)
        inf = gf.query_info 'thumbnail::*', :none, nil

        iconpath = inf.get_attribute_byte_string 'thumbnail::path'

        if iconpath.nil?
          puts 'Scaling image as thumbnail'
          pb = GdkPixbuf::Pixbuf.new_from_file_at_size(f, 128, 128)
        else
          pb = GdkPixbuf::Pixbuf.new_from_file(iconpath)
        end

        @store.set_value it, 0, f
        @store.set_value it, 1, pb
        @store.set_value it, 2, File.basename(f)
      end

      @browser.model = @store

      @window.show_all

      @browser.set_visible true
      @image.set_visible false

      Gtk.main
    end

    private

    def setup_ui
      @builder = Gtk::Builder.new
      @builder.add_from_file Pinhole.path 'data', 'pinhole.ui'
      @builder.connect_signals { |handler_name| method(handler_name) }
    end

    def built_object(name)
      @builder.get_object(name)
    end

    def on_mainwindow_destroy(_widget, _user_data)
      Gtk.main_quit
    end

    def on_mainwindow_window_state_event(_widget, event, _user_data)
      if event.new_window_state[:fullscreen]
        built_object('menubar').set_visible false
        built_object('statusbar').set_visible false
        @active_widget.fullscreen
        @fullscreen = true
      else
        built_object('menubar').set_visible true
        built_object('statusbar').set_visible true
        @active_widget.unfullscreen
        @fullscreen = false
      end
    end

    def on_menu_fullscreen_activate(_action, _user_data)
      if @fullscreen
        @window.unfullscreen
      else
        @window.fullscreen
      end
    end

    def on_menu_zoom_in_activate(_action, _user_data)
      @active_widget.zoom_in
    end

    def on_menu_zoom_out_activate(_action, _user_data)
      @active_widget.zoom_out
    end

    def on_menu_zoom_fit_activate(_action, _user_data)
      @active_widget.zoom_fit
    end

    def on_menu_zoom_100_activate(_action, _user_data)
      @active_widget.zoom_100
    end

    def on_menu_cancel_activate(_action, _user_data)
      @image.set_visible false
      @browser.set_visible true
      @active_widget = @browser
    end
  end
end
