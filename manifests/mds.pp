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

define ceph::mds {
  include 'ceph::package'
  include 'ceph::conf'
  include 'ceph::params'

  ceph::conf::mds { $name: }

  file { "/var/lib/ceph/mds/mds.${name}":
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
    require => [ Package['ceph'], Concat['/etc/ceph/ceph.conf'] ],
  }
  $ceph_mds_keyring_command = "ceph auth get-or-create mds.${name} mds 'allow' osd 'allow *' mon 'allow rwx'"

  exec { 'ceph-mds-keyring':
    command => "${ceph_mds_keyring_command} && ${ceph_mds_keyring_command} > /var/lib/ceph/mds/mds.${name}/keyring",
    creates => "/var/lib/ceph/mds/mds.${name}/keyring",
    before  => Service["ceph-mds.${name}"],
    require => File["/var/lib/ceph/mds/mds.${name}"],
  }

  service { "ceph-mds.${name}":
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => "service ceph start mds.${name}",
    stop     => "service ceph stop mds.${name}",
    status   => "service ceph status mds.${name}",
    require  => Exec['ceph-mds-keyring'],
  }

  Ceph::Mon <| |> -> File["/var/lib/ceph/mds/mds.${name}"]
}
