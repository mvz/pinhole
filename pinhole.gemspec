# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib/pinhole/version.rb")

Gem::Specification.new do |s|
  s.name = "pinhole"
  s.version = Pinhole::VERSION

  s.summary = "Image Viewer"
  s.description = "Tracker-based image viewer for GNOME"

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/pinhole"

  s.required_ruby_version = ">= 2.5.0"

  s.executables = ["pinhole"]
  s.files = File.read("Manifest.txt").split
  s.test_files = Dir["test/**/*.rb"]

  s.add_dependency "gir_ffi-gtk", "~> 0.15.0"
  s.add_dependency "gir_ffi-tracker", "~> 0.15.0"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rake-manifest", "~> 0.2.0"
  s.add_development_dependency "rubocop", "~> 1.19.0"
  s.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  s.add_development_dependency "rubocop-performance", "~> 1.11.0"
  s.add_development_dependency "rubocop-rake", "~> 0.6.0"
end
