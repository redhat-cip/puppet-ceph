require 'spec_helper'

describe 'ceph::key' do

  let :title do
    'dummy'
  end

  describe 'with default parameters' do
    it { should contain_exec('ceph-key-dummy').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/dummy.keyring --create-keyring --name='client.dummy' --add-key=''",
      'creates' => '/var/lib/ceph/tmp/dummy.keyring',
      'require' => 'Package[ceph]'
    )}
  end

  describe 'wen setting secret' do
    let :params do
      { :secret => 'shhh_dont_tell_anyone' }
    end
    it { should contain_exec('ceph-key-dummy').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/dummy.keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone'",
      'creates' => '/var/lib/ceph/tmp/dummy.keyring',
      'require' => 'Package[ceph]'
    )}
  end

  describe 'wen overriding keyring_path' do
    let :params do
      { :keyring_path => '/dummy/path/for/keyring' }
    end
    it { should contain_exec('ceph-key-dummy').with(
      'command' => "ceph-authtool /dummy/path/for/keyring --create-keyring --name='client.dummy' --add-key=''",
      'creates' => '/dummy/path/for/keyring',
      'require' => 'Package[ceph]'
    )}
  end

end
