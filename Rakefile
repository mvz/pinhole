# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'pinhole'

desc "Build and run"
task :default => [:interface, :testrun]
#task :default => 'spec:run'

PROJ.name = 'pinhole'
PROJ.authors = 'Matijs van Zuijlen'
PROJ.email = 'matijs@matijs.net'
PROJ.url = 'http://www.matijs.net/'
PROJ.version = Pinhole::VERSION
PROJ.readme_file = 'README.rdoc'

#PROJ.spec.opts << '--color'

desc "Build interface"
task :interface do
  `gtk-builder-convert data/pinhole.glade data/pinhole.ui`
end

desc "Perform test run"
task :testrun => [:interface] do
  `./bin/pinhole`
end

#Rake::TestTask.new do |t|

# EOF
