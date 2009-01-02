require 'rake'
desc "Build and run"
task :default => [:interface, :test]

desc "Build interface"
task :interface do
  `gtk-builder-convert rthumb.glade rthumb.xml`
end

desc "Perform test run"
task :test do
  #`ruby viewer.rb _DSC2502.jpg`
  `ruby viewer.rb p1013366.jpg`
end
