require 'spec_helper'

describe 'ceph::conf' do

  let :facts do
    { :concat_basedir => "/var/lib/puppet/concat" }
  end

  let :params do
    { :fsid => 'qwertyuiop', }
  end

  let :fragment_path do
    "/var/lib/puppet/concat/_etc_ceph_ceph.conf/fragments/01_ceph.conf"
  end

  it { should contain_class('ceph::package') }

  describe "with default parameters" do

    it { should contain_concat('/etc/ceph/ceph.conf').with(
      'owner'   => 'root',
      'group'   => 0,
      'mode'    => '0664',
      'require' => 'Package[ceph]'
    ) }

    it { should contain_concat__fragment('ceph.conf').with(
      'target'  => '/etc/ceph/ceph.conf',
      'order'   => '01'
    ) }

    it 'should create the configuration fragment with the correct content' do
      verify_contents(
        subject,
        fragment_path,
        [
          '[global]',
          '  auth cluster required = cephx',
          '  auth service required = cephx',
          '  auth client required = cephx',
          '  keyring = /etc/ceph/keyring',
          '  fsid = qwertyuiop',
          '[mon]',
          '  mon data = /var/lib/ceph/mon/mon.$id',
          '[osd]',
          '  osd journal size = 4096',
          '  filestore flusher = false',
          '  osd data = /var/lib/ceph/osd/ceph-$id',
          '  osd journal = /var/lib/ceph/osd/ceph-$id/journal',
          '  osd mkfs type = xfs',
          '  keyring = /var/lib/ceph/osd/ceph-$id/keyring',
          '[mds]',
          '  mds data = /var/lib/ceph/mds/mds.$id',
          '  keyring = /var/lib/ceph/mds/mds.$id/keyring'
        ]
      )
    end

  end

  describe "when overriding default parameters" do

    let :params do
      {
        :fsid                    => 'qwertyuiop',
        :auth_type               => 'dummy',
        :signatures_require      => 'true',
        :signatures_cluster      => 'true',
        :signatures_service      => 'true',
        :signatures_sign_msgs    => 'true',
        :pool_default_pg_num     => 16,
        :pool_default_pgp_num    => 16,
        :pool_default_size       => 3,
        :pool_default_min_size   => 8,
        :pool_default_crush_rule => 1,
        :journal_size_mb         => 8192,
        :cluster_network         => '10.0.0.0/16',
        :public_network          => '10.1.0.0/16',
        :mon_data                => '/opt/ceph/mon._id',
        :mon_init_members        => 'a , b , c',
        :osd_data                => '/opt/ceph/osd._id',
        :osd_journal             => '/opt/ceph/journal/osd._id',
        :mds_data                => '/opt/ceph/mds._id',
        :config                  => {
          'osd max backfills'       => 1,
          'osd recovery max active' => 1
        }
      }
    end

    it { should contain_concat('/etc/ceph/ceph.conf').with(
      'owner'   => 'root',
      'group'   => 0,
      'mode'    => '0664',
      'require' => 'Package[ceph]'
    ) }

    it 'should create the configuration fragment with the correct content' do
      verify_contents(
        subject,
        fragment_path,
        [
          '[global]',
          '  auth cluster required = dummy',
          '  auth service required = dummy',
          '  auth client required = dummy',
          '  cephx require signatures = true',
          '  cephx cluster require signatures = true',
          '  cephx service require signatures = true',
          '  cephx sign messages = true',
          '  keyring = /etc/ceph/keyring',
          '  cluster network = 10.0.0.0/16',
          '  public network = 10.1.0.0/16',
          '  osd pool default pg num = 16',
          '  osd pool default pgp num = 16',
          '  osd pool default size = 3',
          '  osd pool default min size = 8',
          '  osd pool default crush rule = 1',
          '  osd max backfills = 1',
          '  osd recovery max active = 1',
          '  fsid = qwertyuiop',
          '[mon]',
          '  mon initial members = a , b , c',
          '  mon data = /opt/ceph/mon._id',
          '[osd]',
          '  osd journal size = 8192',
          '  filestore flusher = false',
          '  osd data = /opt/ceph/osd._id',
          '  osd journal = /opt/ceph/journal/osd._id',
          '  osd mkfs type = xfs',
          '  keyring = /opt/ceph/osd._id/keyring',
          '  osd recovery op priority = 1',
          '[mds]',
          '  mds data = /opt/ceph/mds._id',
          '  keyring = /opt/ceph/mds._id/keyring'
        ]
      )
    end

  end

end
