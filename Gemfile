source "https://rubygems.org"

if ENV.key?('PUPPET_VERSION')
    puppetversion = ENV['PUPPET_VERSION']
else
    puppetversion = ['>= 2.7']
end

gem 'rake', '10.1.0'
gem 'puppet-lint', '~> 0.3.2'
gem 'rspec-puppet'
gem 'puppet-syntax'
gem 'puppetlabs_spec_helper'
gem 'puppet', puppetversion
