require 'spec_helper'

describe 'ceph::mon' do

  let :title do
    '42'
  end

  describe 'with default parameters' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  let :pre_condition do
'
class { "ceph::conf": fsid => "1234567890" }
'
  end

  let :default_params do
    {
      :monitor_secret      => 'hardtoguess',
      :client_admin_secret => 'shhh_dont_tell_anyone'
    }
  end

  let :params do
    default_params
  end

  let :facts do
    {
      :ipaddress      => '169.254.0.1',
      :concat_basedir => '/var/lib/puppet/concat'
    }
  end

  it { should include_class('ceph::package') }
  it { should include_class('ceph::conf') }

  describe 'with secrets set' do
    it { should contain_ceph__conf__mon('42').with_mon_addr('169.254.0.1') }

    it { should contain_ceph__key('mon.').with(
      'secret'       => 'hardtoguess',
      'keyring_path' => '/var/lib/ceph/tmp/keyring.mon.42',
      'cap_mon'      => 'allow *',
      'before'       => 'Exec[ceph-mon-mkfs]',
      'require'      => 'Package[ceph]'
    )}

    it { should contain_file('/var/lib/ceph/mon/mon.42').with(
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'Exec[ceph-mon-mkfs]',
      'require' => 'Package[ceph]'
    )}

    it { should contain_exec('ceph-mon-mkfs').with(
      'command' => "ceph-mon --mkfs -i 42 --keyring /var/lib/ceph/tmp/keyring.mon.42",
      'creates' => '/var/lib/ceph/mon/mon.42/keyring',
      'require' => ['Package[ceph]','Concat[/etc/ceph/ceph.conf]',
        'File[/var/lib/ceph/mon/mon.42]']
    )}


    it { should contain_service('ceph-mon.42').with(
      'ensure'  => 'running',
      'start'   => 'service ceph start mon.42',
      'stop'    => 'service ceph stop mon.42',
      'status'  => 'service ceph status mon.42',
      'require' => 'Exec[ceph-mon-mkfs]'
    )}

    it { should contain_ceph__key('client.admin').with(
      'secret'         => 'shhh_dont_tell_anyone',
      'keyring_path'   => '/etc/ceph/keyring',
      'cap_mon'        => 'allow *',
      'cap_osd'        => 'allow *',
      'cap_mds'        => 'allow',
      'inject'         => true,
      'inject_as_id'   => 'mon.',
      'inject_keyring' => "/var/lib/ceph/tmp/keyring.mon.42",
      'require'        => ['Package[ceph]', 'Service[ceph-mon.42]']
    )}
  end

  describe 'when overriding mon addr/port' do
    let :params do
      default_params.merge({
        'mon_addr' => '10.0.0.254',
        'mon_port' => '9876',
      })
    end

    it { should contain_ceph__conf__mon('42').with(
      'mon_addr' => '10.0.0.254',
      'mon_port' => 9876
    ) }
  end

end
