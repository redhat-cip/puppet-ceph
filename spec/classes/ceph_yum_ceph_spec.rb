require 'spec_helper'

describe 'ceph::yum::ceph' do

  describe "with default params" do

    it { should contain_yumrepo('ceph').with(
      'descr'    => "Ceph cuttlefish repository",
      'baseurl'  => 'http://ceph.com/rpm-cuttlefish/el6/x86_64/',
      'gpgkey'   => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
      'gpgcheck' => '1',
      'enabled'  => '1',
      'priority' => '5',
      'before'   => 'Package[ceph]'
    ) }

  end

  describe "when overriding ceph release" do
    let :params do
      { 'release' => 'octopuss' }
    end

    it { should contain_yumrepo('ceph').with(
      'descr'    => "Ceph octopuss repository",
      'baseurl'  => 'http://ceph.com/rpm-octopuss/el6/x86_64/',
      'gpgkey'   => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
      'gpgcheck' => '1',
      'enabled'  => '1',
      'priority' => '5',
      'before'   => 'Package[ceph]'
    ) }

  end

end
