require 'spec_helper'

describe 'ceph::radosgw' do

  let :title do
    'radosgw1'
  end

  let :pre_condition do
'
class { "ceph::conf": fsid => "1234567890" }
'
  end

  let :default_params do
    {
      :monitor_secret => 'hardtoguess',
      :admin_email    => 'me@somewhere.tld'
    }
  end

  let :params do
    default_params
  end

  let :facts do
    {
      :concat_basedir => '/var/lib/puppet/concat',
      :hostname       => 'some-host.foo.tld'
    }
  end

  it { should include_class('ceph::package') }
  it { should include_class('ceph::conf') }
  it { should include_class('ceph::params') }

  describe 'with default parameters' do
    it { should contain_ceph__conf__radosgw('radosgw1') }

    it { should contain_exec('ceph-radosgw-keyring').with(
      'command' => "ceph auth get-or-create client.radosgw.some-host.foo.tld osd 'allow rwx' mon 'allow r' --name mon. --key=hardtoguess -o /etc/ceph/ceph.client.radosgw.some-host.foo.tld.keyring",
      'path'    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      'creates' => '/etc/ceph/ceph.client.radosgw.some-host.foo.tld.keyring',
      'before'  => 'Service[radosgw]',
      'require' => 'Package[ceph]'
    )}

    it { should contain_file('/etc/init.d/radosgw').with(
      'ensure' => 'link',
      'source' => '/etc/init.d/ceph-radosgw'
    )}

    it { should contain_service('radosgw').with(
      'ensure'    => 'running',
      'hasstatus' => 'false',
      'require'   => ['Exec[ceph-radosgw-keyring]', 'File[/etc/init.d/radosgw]']
    )}

  end

end
