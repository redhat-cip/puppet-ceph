# Creates the ceph configuration file
#
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. none or 'cephx'. Defaults to 'cephx'.
#
# [*signatures_require*] If Ceph requires signatures on all
#   message traffic (client<->cluster and between cluster daemons).
#   Optional. Boolean.
#
# [*signatures_cluster*] If Ceph requires signatures on all
#   message traffic between the cluster daemons.
#   Optional. Boolean.
#
# [*signatures_service*] If Ceph requires signatures on all
#   message traffic between clients and the cluster.
#   Optional. Boolean.
#
# [*signatures_sign_msgs*] If all ceph msg should be signed.
#   Optional. Boolean.
#
# [*pool_default_size*] Number of replicas for objects in the pool
#   Optional. Integer.
#
# [*pool_default_pg_num*] The default number of PGs per pool.
#   Optional. Integer.
#
# [*pool_default_pgp_num*] The default flags for new pools.
#   Optional. Integer.
#
# [*pool_default_min_size*] The default minimum num of replicas.
#   Optional. Integer
#
# [*pool_default_crush_rule*] The default CRUSH ruleset to use
#   when creating a pool.
#   Optional. Integer
#
# [*mon_osd_full_ratio*] Percentage of disk space used before
#   an OSD considered full
#   Optional. Integer e.g. 95, NOTE: ends in config as .95
#
# [*mon_osd_nearfull_ratio*] Percentage of disk space used before
#   an OSD considered nearfull
#   Optional. Float e.g. 90, NOTE: ends in config as .90
#
# [*journal_size_mb*] The size of the journal in megabytes.
#   Optional. Defaults to '4096'.
#
# [*cluster_network*] The address if the cluster network.
#   Optional. {cluster-network-ip/netmask}
#
# [*public_network*] The address if the public network.
#   Optional. {public-network-ip/netmask}
#
# [*mon_data*] The monitor’s data location.
#   Optional. Defaults to '/var/lib/ceph/mon/mon.$id'.
#
# [*mon_init_members*] The IDs of initial MONs in the cluster during startup.
#   Optional. String like e.g. 'a, b, c'.
#
# [*osd_data*] The OSDs data location.
#   Optional. Defaults to '/var/lib/ceph/osd/osd.$id'
#
# [*osd_journal*] The path to the OSD’s journal.
#   Optional. Absolute path.
#
# [*osd_journal_dio*] Wether the journal should be written with direct IO.
#   Optional. Defaults to 'true'.
#
# [*osd_mkfs_type*] Type of the OSD filesystem.
#   Optional. Defaults to 'xfs'.
#
# [*osd_mkfs_options*] The options used to format the OSD fs.
#   Optional. Defaults to '-f' for XFS.
#
# [*osd_mount_options*] The options used to mount the OSD fs.
#   Optional. Defaults to 'rw,noatime,inode64' for XFS.
#
# [*osd_max_backfills*] The number of active recovery
#   requests per OSD at one time. More requests will accelerate recovery,
#   but the requests places an increased load on the cluster.
#   Optional. Defaults to 5 .
#
# [*osd_recovery_max_active*] The maximum number of
#   backfills allowed to or from a single OSD.
#   Optional. Defaults to 10 .
#
# [*mds_activate*] Switch to activate the '[mds]' section in the config.
#   Optional. Defaults to 'true'.
#
# [*mds_data*] The path to the MDS data.
#   Optional. Defaults to '/var/lib/ceph/mds/mds.$id'
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier <francois.charlier@enovance.com>
#  Sébastien Han     <sebastien.han@enovance.com>
#  Danny Al-Gaaf     <danny.al-gaaf@bisect.de>
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::conf (
  $fsid,
  $auth_type               = 'cephx',
  $signatures_require      = undef,
  $signatures_cluster      = undef,
  $signatures_service      = undef,
  $signatures_sign_msgs    = undef,
  $pool_default_size       = undef,
  $pool_default_pg_num     = undef,
  $pool_default_pgp_num    = undef,
  $pool_default_min_size   = undef,
  $pool_default_crush_rule = undef,
  $mon_osd_full_ratio      = undef,
  $mon_osd_nearfull_ratio  = undef,
  $journal_size_mb         = 4096,
  $cluster_network         = undef,
  $public_network          = undef,
  $mon_data                = '/var/lib/ceph/mon/mon.$id',
  $mon_init_members        = undef,
  $osd_data                = '/var/lib/ceph/osd/osd.$id',
  $osd_journal             = undef,
  $osd_journal_dio         = true,
  $osd_mkfs_type           = 'xfs',
  $osd_mkfs_options        = '-f -i size=2048 -n size=64k',
  $osd_mount_options       = 'rw,noatime,inode64,nobootwait,noexec,logbsize=256k,delaylog',
  $osd_max_backfills       = undef,
  $osd_recovery_max_active = undef,
  $mds_activate            = true,
  $mds_data                = '/var/lib/ceph/mds/mds.$id'
) {

  include 'ceph::package'

  # Ensure that when the $osd_max_backfills is define that's neither empty or integers.
  if $osd_max_backfills != '' and !is_integer($osd_max_backfills) {
    fail('Only integers are allowed in the ceph::conf::osd_max_backfills order param')
  }

  # Ensure that when the $osd_recovery_max_active is define that's neither empty or integers.
  if $osd_recovery_max_active != '' and !is_integer($osd_recovery_max_active) {
    fail('Only integers are allowed in the ceph::conf::osd_recovery_max_active order param')
  }

  if $osd_journal {
    $osd_journal_real = $osd_journal
  } else {
    $osd_journal_real = "${osd_data}/journal"
  }

  concat { '/etc/ceph/ceph.conf':
    owner   => 'root',
    group   => 0,
    mode    => '0664',
    require => Package['ceph'],
  }

  Concat::Fragment <<| target == '/etc/ceph/ceph.conf' |>>

  concat::fragment { 'ceph.conf':
    target  => '/etc/ceph/ceph.conf',
    order   => '01',
    content => template('ceph/ceph.conf.erb'),
  }

}
