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

  package { 'xfsprogs':
    ensure => present
  }


  #FIXME: Ensure ceph user/group

  file { '/var/lib/ceph':
    ensure => directory,
    #FIXME: ensure user/group/perms
  }

  file { '/var/run/ceph':
    ensure => directory,
    #FIXME: ensure user/group/perms
  }

}
