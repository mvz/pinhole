require 'optparse'
require 'gtk2'
require 'image'

class Viewer
  def initialize(filename)
    @filename = filename
  end

  def run
    Gtk.init

    setup_ui

    @fullscreen = false

    @window = @builder["mainwindow"]

    @scrolledwindow.load_image_from_file(@filename)
    @window.show_all

    on_menu_zoom_fit_activate

    Gtk.main
  end

  private

  def setup_ui
    @builder = Gtk::Builder.new
    @builder.add "rthumb.xml"
    @builder.connect_signals { |name| method(name) }

    @scrolledwindow = Image.new

    @builder["mainvbox"].pack_start(@scrolledwindow)
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

# Main
opts = OptionParser.new()
files = opts.parse(*ARGV)
if files.empty? then exit; end
viewer = Viewer.new(files.first)
viewer.run
