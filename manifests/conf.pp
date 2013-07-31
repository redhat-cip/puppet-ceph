# Creates the ceph configuration file
#
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. undef or 'cephx'. Defaults to 'cephx'.
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
  $auth_type       = 'cephx',
  $journal_size_mb = 4096,
  $cluster_network = undef,
  $public_network  = undef,
  $mon_data        = '/var/lib/ceph/mon/mon.$id',
  $osd_data        = '/var/lib/ceph/osd/osd.$id',
  $osd_journal     = undef,
  $mds_data        = '/var/lib/ceph/mds/mds.$id'
  $conf_owner      = 'root',
  $conf_group      = 0,
) {

  include 'ceph::package'

  if $auth_type == 'cephx' {
    $mode = '0660'
  } else {
    $mode = '0664'
  }

  if $osd_journal {
    $osd_journal_real = $osd_journal
  } else {
    $osd_journal_real = "${osd_data}/journal"
  }

  concat { '/etc/ceph/ceph.conf':
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => $mode,
    require => Package['ceph'],
  }

  Concat::Fragment <<| target == '/etc/ceph/ceph.conf' |>>

  concat::fragment { 'ceph.conf':
    target  => '/etc/ceph/ceph.conf',
    order   => '01',
    content => template('ceph/ceph.conf.erb'),
  }

}
