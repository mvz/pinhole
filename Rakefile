task :default => [:interface, :test]

task :interface do
  `gtk-builder-convert rthumb.glade rthumb.xml`
end

task :test do
  `ruby viewer.rb _DSC2502.jpg`
end

