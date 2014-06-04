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

  ensure_resource('file', ['/var/run/ceph', '/var/lib/ceph', '/var/lib/ceph/mon', '/var/lib/ceph/osd'], {
    'ensure' => 'directory',
    'owner'  => 'root',
    'group'  => '0',
    'mode'   => '0755'
  })

}
