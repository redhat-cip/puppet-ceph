require 'spec_helper'

describe "ceph::osd" do

  let :facts do
    { :ipaddress => '2.4.6.8' }
  end

  it { should include_class('ceph::package') }

  it { should contain_package('xfsprogs') }
  it { should contain_package('parted') }

end
