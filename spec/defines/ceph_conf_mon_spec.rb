require 'spec_helper'

describe 'ceph::conf::mon' do

  let :pre_condition do
'
class { "ceph::conf": fsid => "1234567890" }
'
  end

  let :title do
    '42'
  end

  let :params do
    {
      'mon_addr' => '1.2.3.4',
      'mon_port' => '1234',
    }
  end

  let :facts do
    {
      :concat_basedir => '/var/lib/puppet/concat',
      :hostname       => 'some-host.foo.tld',
    }
  end

  let :fragment_file do
    '/var/lib/puppet/concat/_etc_ceph_ceph.conf/fragments/50_ceph-mon-42.conf'
  end

  describe "writes the mon configuration file" do
    # Need to work around the exported resources problem
    xit { should contain_file(fragment_file).with_content(/[mon.42]/) }
    xit { should contain_file(fragment_file).with_content(/  host = some-host.foo.tld/) }
    xit { should contain_file(fragment_file).with_content(/  mon addr = 1.2.3.4:1234/) }
  end

end
