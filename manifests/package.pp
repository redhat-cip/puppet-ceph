# Install and configure base ceph components
#
# == Parameters
# [*package_ensure*] The ensure state for the ceph package.
#   Optional. Defaults to present.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::package (
  $package_ensure = 'present'
) {

  package { 'ceph':
    ensure => $package_ensure
  }

  #FIXME: Ensure ceph user/group

  file { '/var/lib/ceph':
    ensure => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755'
  }

  file { '/var/run/ceph':
    ensure => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755'
  }

}
