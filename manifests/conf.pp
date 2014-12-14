# Creates the ceph configuration file
#
# == Parameters
#
# [*fsid*]
#   The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*]
#   (Optional) Auth type, could be 'none' or 'cephx'.
#   Defaults to 'cephx'.
#
# [*signatures_require*]
#  (Optional) If set to true, Ceph requires signatures on all message traffic
#  between the Ceph Client and the Ceph Storage Cluster, and between daemons
#  comprising the Ceph Storage Cluster.
#  Defaults to 'undef'
#
# [*signatures_cluster*]
#  (Optional) If set to true, Ceph requires signatures on all message traffic
#  between Ceph daemons comprising the Ceph Storage Cluster.
#  Defaults to 'undef'
#
# [*signatures_service*]
#  (Optional) If set to true, Ceph requires signatures on all message traffic
#  between Ceph Clients and the Ceph Storage Cluster.
#  Defaults to 'undef'
#
# [*signatures_sign_msgs*]
#  (Optional) If the Ceph version supports message signing, Ceph will sign all
#  messages so they cannot be spoofed.
#  Defaults to 'undef'
#
# [*pool_default_size*]
#  (Optional) Sets the number of replicas for objects in the pool. The default
#  value is the same as ceph osd pool set {pool-name} size {size}.
#  Defaults to '3'
#
# [*pool_default_pg_num*]
#  (Optional) The default number of placement groups for a pool. The default
#  value is the same as pg_num with mkpool.
#  Defaults to '1024'
#
# [*pool_default_pgp_num*]
#  (Optional) The default number of placement groups for placement for a pool.
#  The default value is the same as pgp_num with mkpool. PG and PGP should be
#  equal (for now).
#  Defaults to '1024'
#
# [*pool_default_min_size*]
#  (Optional) Sets the minimum number of written replicas for objects in the
#  pool in order to acknowledge a write operation to the client. If minimum is
#  not met, Ceph will not acknowledge the write to the client. This setting
#  ensures a minimum number of replicas when operating in degraded mode.
#  Defaults to 'undef'
#
# [*pool_default_crush_rule*]
#  (Optional) The default CRUSH rule to use when creating a replicated pool.
#  Default to 'undef'
#
# [*journal_size_mb*]
#  (Optional) The size of the journal in megabytes. If this is 0, and the
#  journal is a block device, the entire block device is used. Since v0.54,
#  this is ignored if the journal is a block device, and the entire block
#  device is used.
#  Defaults to '4096'
#
# [*cluster_network*]
#  (Optional) The IP address and netmask of the cluster (back-side) network
#  (e.g., 10.0.0.0/24). Set in [global]. You may specify comma-delimited
#  subnets.
#  Defaults to 'undef'
#
# [*public_network*]
#  (Optional) The IP address and netmask of the public (front-side) network
#  (e.g., 192.168.0.0/24). Set in [global]. You may specify comma-delimited
#  subnets.
#  Defaults to 'undef'
#
# [*mon_init_members*]
#  (Optional) The IDs of initial monitors in a cluster during startup. If
#  specified, Ceph requires an odd number of monitors to form an initial quorum
#  (e.g., 3).
#  Defaults to 'undef'
#
# [*mon_data*]
#  (Optional) The monitor's data location
#  Defaults to '/var/lib/ceph/mon/mon.$id'
#
# [*osd_data*]
#  (Optional) The path to the OSDs data. You must create the directory when
#  deploying Ceph. You should mount a drive for OSD data at this mount point.
#  We do not recommend changing the default.
#  Default to '/var/lib/ceph/osd/ceph-$id'
#
# [*osd_journal*]
#  (Optional) The path to the OSD’s journal. This may be a path to a file or a
#  block device (such as a partition of an SSD). If it is a file, you must
#  create the directory to contain it. We recommend using a drive separate from
#  the osd data drive.
#  Defaults to 'undef'
#
# [*mds_data*]
#  (Optional) The mds's data location
#  Defaults to '/var/lib/ceph/mds/mds.$id'
#
# [*enable_service*]
#  (Optional) Enable or not Ceph services at boot time
#  Defaults to 'false'
#
# [*conf_owner*]
#  (Optional) Username or id of Ceph configuration files owner
#  Defaults to 'root'
#
# [*conf_group*]
#  (Optional) Username or id of Ceph configuration files group
#  Defaults to '0'
#
# [*config*]
#  (Optional) A custom configuration, using keys/values
#  Defaults to '{}'
#
# [*osd_recovery_max_active*]
#  (Optional) The number of active recovery requests per OSD at one time. More
#  requests will accelerate recovery, but the requests places an increased load
#  on the cluster.
#  Defaults to '1'
#
# [*osd_max_backfills*]
#  (Optional) The maximum number of backfills allowed to or from a single OSD
#  Defaults to '1'
#
# [*osd_recovery_op_priority*]
#  (Optional) The priority set for recovery operations. It is relative to osd
#  client op priority.
#  Defaults to '1'
#
# == Dependencies
#
# none
#
# == Authors
#
#  Francois Charlier francois.charlier@enovance.com
#  Sebastien Han     sebastien.han@enovance.com
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
