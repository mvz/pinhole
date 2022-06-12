# frozen_string_literal: true

require_relative "lib/pinhole/version"

Gem::Specification.new do |spec|
  spec.name = "pinhole"
  spec.version = Pinhole::VERSION
  spec.authors = ["Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "Image Viewer"
  spec.description = "Tracker-based image viewer for GNOME"
  spec.homepage = "http://www.github.com/mvz/pinhole"
  spec.license = "GPL-2+"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.executables = ["pinhole"]

  spec.files = File.read("Manifest.txt").split

  spec.add_runtime_dependency "gir_ffi-gtk", "~> 0.16.0"
  spec.add_runtime_dependency "gir_ffi-tracker", "~> 0.16.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.2.0"
  spec.add_development_dependency "rubocop", "~> 1.25"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.13"
  spec.add_development_dependency "rubocop-rake", "~> 0.6.0"
end
