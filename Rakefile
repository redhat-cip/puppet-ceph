# -*- mode: ruby -*-
# vi: set ft=ruby :
#
NAME = 'eNovance-ceph'
TDIR = File.expand_path(File.dirname(__FILE__))

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')

exclude_tests_paths = ['pkg/**/*','vendor/**/*','spec/**/*','examples/**/*']
PuppetLint.configuration.ignore_paths = exclude_tests_paths
PuppetSyntax.exclude_paths = exclude_tests_paths

task(:default).clear
task :default => [:syntax,:lint,:spec]

namespace :module do
  desc "Build #{NAME} module (in a clean env) Please use this for puppetforge"
  task :build do
    exec "rsync -rv --exclude-from=#{TDIR}/.forgeignore . /tmp/#{NAME};cd /tmp/#{NAME};puppet module build"
  end
end
