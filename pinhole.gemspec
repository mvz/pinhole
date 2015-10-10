# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'pinhole'
  s.version = '0.1.5'

  s.summary = 'Image Viewer'
  s.description = 'Tracker-based image viewer for GNOME'

  s.authors = ['Matijs van Zuijlen']
  s.email = ['matijs@matijs.net']
  s.homepage = 'http://www.github.com/mvz/pinhole'

  s.executables = ['pinhole']
  s.files =
    Dir['bin/*', '*.md', '*.rdoc', 'COPYING', 'Rakefile', 'Gemfile'] &
      `git ls-files -z`.split("\0")
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency('gir_ffi-gtk', ['~> 0.8.0'])
  s.add_dependency('ruby-dbus', ['~> 0.11.0'])
  s.add_development_dependency('rake', ['~> 10.1'])
end

