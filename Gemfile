source "https://rubygems.org"

group :development, :test do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', '~> 2.0.0', :require => false
  gem 'puppet-lint-param-docs'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppet-lint'
end

if puppetversion = ENV['PUPPET_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
