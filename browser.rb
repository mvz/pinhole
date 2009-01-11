require 'optparse'
require 'gtk2'

class Browser
  def run
    Gtk.init

    setup_ui

    @fullscreen = false

    @window = @builder["mainwindow"]

    @iconview = @builder["iconview"]

    @store = Gtk::ListStore.new(String, Gdk::Pixbuf)

    Dir.glob("*.jpg").each { |f|
      pb = Gdk::Pixbuf.new(f, 100, 100)
      @store.append.set_value(0, f).set_value(1, pb)
    }

    @iconview.model = @store
    @iconview.text_column = 0
    @iconview.pixbuf_column = 1

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

Browser.new.run
