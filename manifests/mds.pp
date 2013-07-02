# Configure a ceph mds
#
# == Name
#   This resource's name is the mon's id and must be numeric.
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. undef or 'cephx'. Defaults to 'cephx'.
#
# [*mds_data*] Base path for mon data. Data will be put in a mon.$id folder.
#   Optional. Defaults to '/var/lib/ceph/mds.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Sébastien Han sebastien.han@enovance.com
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#

define ceph::mds (
  $fsid,
  $auth_type = 'cephx',
  $mds_data = '/var/lib/ceph/mds',
) {

  include 'ceph::package'
  include 'ceph::params'

  class { 'ceph::conf':
    fsid      => $fsid,
    auth_type => $auth_type,
  }

  $mds_data_expanded = "${mds_data}/mds.${name}"

  file { $mds_data_expanded:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  exec { 'ceph-mds-keyring':
    command =>"ceph auth get-or-create mds.${name} mds 'allow ' osd 'allow *' mon 'allow rwx'",
    creates => "/var/lib/ceph/mds/mds.${name}/keyring",
    before  => Service["ceph-mds.${name}"],
    require => Package['ceph'],
  }

  service { "ceph-mds.${name}":
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => "service ceph start mds.${name}",
    stop     => "service ceph stop mds.${name}",
    status   => "service ceph status mds.${name}",
    require  => Exec['ceph-mds-keyring'],
  }
}
