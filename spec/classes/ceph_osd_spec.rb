require 'spec_helper'

describe "ceph::osd" do

  describe 'with default parameters' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe "when overriding parameters" do
    let :facts do
      { :ipaddress => '2.4.6.8' }
    end

    let :params do
      { 'client_admin_secret' => 'shhh_dont_tell_anyone' }
    end

    it { should include_class('ceph::package') }

    it { should contain_package('xfsprogs') }
    it { should contain_package('parted') }
  end
end
