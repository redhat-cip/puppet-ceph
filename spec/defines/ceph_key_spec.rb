require 'spec_helper'

describe 'ceph::key' do

  let :title do
    'client.dummy'
  end

  let :facts do 
    { :concat_basedir => '/var/lib/puppet/concat' }
  end

  describe 'with default parameters' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe 'when setting secret' do
    let :params do
      { :secret => 'shhh_dont_tell_anyone' }
    end
    it { should contain_exec('ceph-key-client.dummy').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/client.dummy.keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone' ",
      'creates' => '/var/lib/ceph/tmp/client.dummy.keyring',
      'require' => 'Package[ceph-common]'
    )}
  end

  describe 'when overriding keyring_path' do
    let :params do
    {
      'secret'       => 'shhh_dont_tell_anyone',
      'keyring_path' => '/dummy/path/for/keyring',
    }
    end
    it { should contain_exec('ceph-key-client.dummy').with(
      'command' => "ceph-authtool /dummy/path/for/keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone' ",
      'creates' => '/dummy/path/for/keyring',
      'require' => 'Package[ceph-common]'
    )}
  end

  describe 'when setting caps' do
    let :params do
    {
      'secret'       => 'shhh_dont_tell_anyone',
      'cap_mon'      => 'x',
      'cap_osd'      => 'y',
      'cap_mds'      => 'z',
    }
    end
    it { should contain_exec('ceph-key-client.dummy').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/client.dummy.keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone' --cap mon 'x' --cap osd 'y' --cap mds 'z' ",
      'creates' => '/var/lib/ceph/tmp/client.dummy.keyring',
      'require' => 'Package[ceph-common]'
    )}
  end

  describe 'when set to inject key' do
    let :params do
    {
      'secret'         => 'shhh_dont_tell_anyone',
      'inject'         => true,
      'inject_as_id'   => 'mon.',
      'inject_keyring' => '/etc/ceph/mykeyring',
    }
    end
    it { should contain_exec('ceph-key-client.dummy').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/client.dummy.keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone' ",
      'creates' => '/var/lib/ceph/tmp/client.dummy.keyring',
      'require' => 'Package[ceph-common]'
    )}
    it { should contain_exec('ceph-inject-key-client.dummy').with(
      'command' => "ceph --name 'mon.' --keyring '/etc/ceph/mykeyring' auth add 'client.dummy' --in-file='/var/lib/ceph/tmp/client.dummy.keyring'",
      'onlyif'  => "ceph --name 'mon.' --keyring '/etc/ceph/mykeyring' -s",
      'require' => ['Package[ceph]', 'File[/var/lib/ceph/tmp/client.dummy.keyring]']
    )}
  end

  describe 'when add key to ceph.conf' do
    let :params do
    {
      'secret'        => 'shhh_dont_tell_anyone',
      'keyring_path'  => '/etc/ceph/client.dummy.keyring',
      'add_to_config' => true,
    }
    end
    it { should contain_exec('ceph-key-client.dummy').with(
      'command' => "ceph-authtool /etc/ceph/client.dummy.keyring --create-keyring --name='client.dummy' --add-key='shhh_dont_tell_anyone' ",
      'creates' => '/etc/ceph/client.dummy.keyring',
      'require' => 'Package[ceph-common]'
    )}

    # TODO add check for ceph.conf changes
  end

end
