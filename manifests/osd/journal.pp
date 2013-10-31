# Manages  a ceph osd journal disk
#
# We reuse the same mkfs and mount options as for the
# the OSD disks.
#
# == Name
# the resource name is the full path to the device to be used.
#
# == Parameters
#
# [*mount_point*] the path the disk mount to
#  Optional. If not set the disks isn't mounted
#
# == Dependencies
#
# == Authors
#
#  Danny Al-Gaaf <danny.al-gaaf@bisect.de>
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG
#

define ceph::osd::journal (
  $mount_point = undef,
) {

  $dev_path = $name
  $devname = regsubst($name, '/dev/', '')

  ensure_packages (['ceph'])

  # TODO: add other file systems ... otherwise fail!
  if $::ceph::conf::osd_mkfs_type == 'xfs' {
    exec { "mkfs_${devname}":
      command => "mkfs.xfs ${::ceph::conf::osd_mkfs_options} ${dev_path}",
      unless  => "xfs_admin -l ${dev_path}",
      require => [Package['xfsprogs']],
    }
  }

  if $mount_point {
    file { $mount_point:
      ensure  => directory,
      require => Package['ceph'],
    }

    mount { $mount_point:
      ensure  => mounted,
      device  => $dev_path,
      atboot  => true,
      fstype  => $::ceph::conf::osd_mkfs_type,
      options => $::ceph::conf::osd_mount_options,
      pass    => 2,
      require => [ Exec["mkfs_${devname}"], File[$mount_point] ],
    }
  }
}
