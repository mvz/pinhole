# frozen_string_literal: true

require "rake/clean"
require "rake/manifest/task"
require "rake/testtask"

Rake::Manifest::Task.new do |t|
  t.patterns = ["README.rdoc", "lib/**/*", "COPYING"]
end

namespace :test do
  Rake::TestTask.new(:run) do |t|
    t.libs = ["lib"]
    t.test_files = FileList["test/**/*_test.rb"]
    t.ruby_opts += ["-w"]
  end
end

desc "Alias to test:run"
task test: "test:run"

task default: ["test:run", "manifest:check"]
task build: ["manifest:check"]
