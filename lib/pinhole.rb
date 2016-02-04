# frozen_string_literal: true

require "gir_ffi-gtk3"

GirFFI.setup :GdkPixbuf, "2.0"

# Main module
module Pinhole
  # :stopdoc:
  LIBPATH = __dir__ + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path(*args)
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end
end

require "pinhole/tracker_provider"
require "pinhole/mainwindow"
require "pinhole/version"
