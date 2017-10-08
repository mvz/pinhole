require File.join(File.dirname(__FILE__), 'lib/pinhole/version.rb')

Gem::Specification.new do |s|
  s.name = 'pinhole'
  s.version = Pinhole::VERSION

  s.summary = 'Image Viewer'
  s.description = 'Tracker-based image viewer for GNOME'

  s.authors = ['Matijs van Zuijlen']
  s.email = ['matijs@matijs.net']
  s.homepage = 'http://www.github.com/mvz/pinhole'

  s.executables = ['pinhole']
  s.files = Dir['bin/*', '*.md', '*.rdoc', 'COPYING', 'Rakefile', 'Gemfile'] &
            `git ls-files -z`.split("\0")
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency('gir_ffi-gtk', ['~> 0.11.0'])
  s.add_dependency('ruby-dbus', ['~> 0.13.0'])
  s.add_development_dependency('rake', ['~> 12.0'])
end
