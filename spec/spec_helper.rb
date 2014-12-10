require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'

  c.default_facts = {
    :kernel         => 'Linux',
    :concat_basedir => '/var/lib/puppet/concat',
    :memorysize     => '1000 MB',
    :processorcount => '1',
    :puppetversion  => '3.7.3',
    :uniqueid       => '123'
  }
end
