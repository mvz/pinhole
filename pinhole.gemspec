# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib/pinhole/version.rb")

Gem::Specification.new do |spec|
  spec.name = "pinhole"
  spec.version = Pinhole::VERSION

  spec.summary = "Image Viewer"
  spec.description = "Tracker-based image viewer for GNOME"

  spec.authors = ["Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]
  spec.homepage = "http://www.github.com/mvz/pinhole"

  spec.required_ruby_version = ">= 2.6.0"

  spec.executables = ["pinhole"]
  spec.files = File.read("Manifest.txt").split
  spec.test_files = Dir["test/**/*.rb"]

  spec.add_dependency "gir_ffi-gtk", "~> 0.15.0"
  spec.add_dependency "gir_ffi-tracker", "~> 0.15.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.2.0"
  spec.add_development_dependency "rubocop", "~> 1.22.2"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.11.0"
  spec.add_development_dependency "rubocop-rake", "~> 0.6.0"
end
