# Configure a ceph mds
#
# == Name
#   This resource's name is the mds's id and must be numeric.
# == Parameters
#
# none
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

  $mds_data_real = regsubst($ceph::conf::mds_data, '\$id', $name)

  ceph::conf::mds { $name: }

  file { $mds_data_real:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
    require => [ Package['ceph'], Concat['/etc/ceph/ceph.conf'] ],
  }

  $ceph_mds_keyring_command = "ceph auth get-or-create mds.${name} mds 'allow' osd 'allow *' mon 'allow rwx'"
  exec { 'ceph-mds-keyring':
    command => "${ceph_mds_keyring_command} && ${ceph_mds_keyring_command} > ${mds_data_real}/keyring",
    creates => "${mds_data_real}/keyring",
    before  => Service["ceph-mds.${name}"],
    require => File[$mds_data_real],
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
