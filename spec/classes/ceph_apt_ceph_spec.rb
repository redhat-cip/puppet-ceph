require 'spec_helper'

describe 'ceph::apt::ceph' do

  describe "when dist codename is wheezy" do

    let :facts do
      { :lsbdistcodename => 'wheezy' }
    end

    describe "with default params" do

      it { should contain_apt__key('ceph').with(
        'key'        => '17ED316D',
        'key_source' => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
      ) }

      it { should contain_apt__source('ceph').with(
        'location' => 'http://ceph.com/debian-bobtail/',
        'release'  => 'wheezy',
        'require'  => 'Apt::Key[ceph]',
        'before'   => 'Package[ceph]'
      ) }

    end

    describe "when overriding ceph release" do
      let :params do
        { 'release' => 'octopuss' }
      end

      it { should contain_apt__source('ceph').with(
        'location' => 'http://ceph.com/debian-octopuss/',
        'release'  => 'wheezy',
        'require'  => 'Apt::Key[ceph]',
        'before'   => 'Package[ceph]'
      ) }
    end

  end

end
