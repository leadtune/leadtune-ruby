# -*- ruby -*-

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

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
Rake::RDocTask.new(:rdoc) do |rd|
  rd.options << "-t LeadTune API Ruby Gem"
  rd.options << "--exclude=Gemfile"
  rd.options << "--exclude=TAGS"
  rd.options << "--exclude=Rakefile"
  rd.options << "--exclude=spec/"
end

desc 'clobber generated files'
task :clobber => [:clobber_rdoc,] do
  rm_rf "pkg"
  rm_rf "tmp"
  rm_rf "doc"
end

task :hudson => [:spec, :rdoc,]

task :default => [:spec, :cucumber,]



