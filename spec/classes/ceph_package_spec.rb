require 'spec_helper'

describe 'ceph::package' do
  describe "with default parameters" do
    it { should contain_package('ceph').with_ensure('present') }

    it { should contain_file('/var/lib/ceph').with(
      'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 0,
      'mode'   => '0755'
    ) }

    it { should contain_file('/var/run/ceph').with(
      'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 0,
      'mode'   => '0755'
    ) }
  end

  describe "when overriding parameters" do
    let :params do { :package_ensure => 'latest' } end

    it { should contain_package('ceph').with_ensure('latest') }
  end
end
