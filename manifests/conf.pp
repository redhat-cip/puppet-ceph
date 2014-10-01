# Creates the ceph configuration file
#
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. none or 'cephx'. Defaults to 'cephx'.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#  Sébastien Han     sebastien.han@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::conf (
  $fsid,
  $auth_type                = 'cephx',
  $signatures_require       = undef,
  $signatures_cluster       = undef,
  $signatures_service       = undef,
  $signatures_sign_msgs     = undef,
  $pool_default_size        = '3',
  $pool_default_pg_num      = '1024',
  $pool_default_pgp_num     = '1024',
  $pool_default_min_size    = undef,
  $pool_default_crush_rule  = undef,
  $journal_size_mb          = '4096',
  $cluster_network          = undef,
  $public_network           = undef,
  $mon_data                 = '/var/lib/ceph/mon/mon.$id',
  $mon_init_members         = undef,
  $osd_data                 = '/var/lib/ceph/osd/ceph-$id',
  $osd_journal              = undef,
  $mds_data                 = '/var/lib/ceph/mds/mds.$id',
  $enable_service           = false,
  $conf_owner               = 'root',
  $conf_group               = '0',
  $config                   = {},
  $osd_recovery_max_active  = 1,
  $osd_max_backfills        = 1,
  $osd_recovery_op_priority = 1,
) {
  validate_hash($config)

  include 'ceph::package'

  if $osd_journal {
    $osd_journal_real = $osd_journal
  } else {
    $osd_journal_real = "${osd_data}/journal"
  }

  concat { '/etc/ceph/ceph.conf':
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => '0664',
    require => Package['ceph'],
  }

  Concat::Fragment <<| target == '/etc/ceph/ceph.conf' |>>

  concat::fragment { 'ceph.conf':
    target  => '/etc/ceph/ceph.conf',
    order   => '01',
    content => template('ceph/ceph.conf.erb'),
  }

  service { 'ceph': enable => $enable_service }
}
