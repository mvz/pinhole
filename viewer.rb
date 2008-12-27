require 'gtk2'

Gtk.init

window = Gtk::Window.new
buf = Gdk::Pixbuf.new("_DSC2502.jpg", 1024, 768)
im = Gtk::Image.new(buf)
eb = Gtk::EventBox.new.add(im)
window.signal_connect("destroy") { Gtk.main_quit }
window.border_width = 10
window.add(eb)
window.show_all
Gtk.main
