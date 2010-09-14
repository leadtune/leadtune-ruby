# -*- ruby -*-
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'yaml'

require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new
Rake::RDocTask.new

desc 'clobber generated files'
task :clobber => [:clobber_rdoc,]do
  rm_rf "pkg"
  rm_rf "tmp"
end

task :default => [:spec, :cucumber,]



