# Install and configure base ceph components
#
# == Parameters
# [*package_ensure*] The ensure state for the ceph-common package.
#   Optional. Defaults to present.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Michael Jeanson <michael.jeanson@usherbrooke.ca>
#
# == Copyright
#
# Copyright 2013 Université de Sherbrooke <vrr@usherbrooke.ca>
#
class ceph::package::common (
  $package_ensure = 'present'
) {

  file { '/etc/ceph':
    ensure => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755'
  }

  package { 'ceph-common':
    ensure => $package_ensure
  }
}
