require 'gir_ffi-gtk2'

GirFFI.setup :GdkPixbuf, '2.0'

module Pinhole
  # :stopdoc:
  VERSION = '1.0.0'.freeze
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path(*args)
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end
end
