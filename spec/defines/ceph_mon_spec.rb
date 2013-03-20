require 'spec_helper'

describe 'ceph::mon' do

  let :title do
    '42'
  end

  let :pre_condition do
'
class { "ceph::conf": fsid => "1234567890" }
'
  end

  let :default_params do
    { :monitor_secret => 'hardtoguess' }
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


  describe 'with default parameters' do
    it { should contain_ceph__conf__mon('42').with_mon_addr('169.254.0.1') }

    it { should contain_exec('ceph-mon-keyring').with(
      'command' => "ceph-authtool /var/lib/ceph/tmp/keyring.mon.42 \
--create-keyring --name=mon. --add-key='hardtoguess' \
--cap mon 'allow *'",
      'creates' => '/var/lib/ceph/tmp/keyring.mon.42',
      'before'  => 'Exec[ceph-mon-mkfs]',
      'require' => 'Package[ceph]'
    )}

    it { should contain_exec('ceph-mon-mkfs').with(
      'command' => "ceph-mon --mkfs -i 42 --keyring /var/lib/ceph/tmp/keyring.mon.42",
      'creates' => '/var/lib/ceph/mon/mon.42/keyring',
      'require' => ['Package[ceph]','Concat[/etc/ceph/ceph.conf]']
    )}

    it { should contain_service('ceph-mon.42').with(
      'ensure'  => 'running',
      'start'   => 'service ceph start mon.42',
      'stop'    => 'service ceph stop mon.42',
      'status'  => 'service ceph status mon.42',
      'require' => 'Exec[ceph-mon-mkfs]'
    )}

    it { should contain_exec('ceph-admin-key').with(
      'command' => "ceph-authtool /etc/ceph/keyring \
--create-keyring --name=client.admin --add-key \
$(ceph --name mon. --keyring /var/lib/ceph/mon/mon.42/keyring \
  auth get-or-create-key client.admin \
    mon 'allow *' \
    osd 'allow *' \
    mds allow)",
      'creates' => '/etc/ceph/keyring',
      'require' => 'Package[ceph]',
      'onlyif'  => "ceph --admin-daemon /var/run/ceph/ceph-mon.42.asok \
mon_status|egrep -v '\"state\": \"(leader|peon)\"'"
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
