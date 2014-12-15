source "https://rubygems.org"

group :development, :test do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint-param-docs'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppet-lint'
  gem 'rake', '10.1.0'
  gem 'rspec', '< 2.99'
end

if puppetversion = ENV['PUPPET_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
