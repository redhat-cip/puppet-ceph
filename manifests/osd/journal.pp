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
# [*mkfs_type*] Type of the journal disks filesystem.
#   Optional. Defaults to ceph::conf::osd_mkfs_type.
#
# [*mkfs_options*] The options used to format the journal fs.
#   Optional. Defaults to ceph::conf::osd_mkfs_options.
#
# [*mount_options*] The options used to mount the journal fs.
#   Optional. Defaults to ceph::conf::osd_mount_options.
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
  $mount_point   = undef,
  $mkfs_type     = $ceph::conf::osd_mkfs_type,
  $mkfs_options  = $ceph::conf::osd_mkfs_options,
  $mount_options = $ceph::conf::osd_mount_options,
) {

  $dev_path = $name
  $devname = regsubst($name, '/dev/', '')

  ensure_packages (['ceph'])

  # TODO: add other file systems ... otherwise fail!
  if $mkfs_type == 'xfs' {
    exec { "mkfs_${devname}":
      command => "mkfs.xfs ${mkfs_options} ${dev_path}",
      unless  => "xfs_admin -l ${dev_path}",
      require => [Package['xfsprogs']],
    }
    $mount_require = [ Exec["mkfs_${devname}"], File[$mount_point] ]
  } else {
    # fall back to default to be able to use tmpfs
    $mount_require = [File[$mount_point]]
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
      fstype  => $mkfs_type,
      options => $mount_options,
      pass    => 2,
      require => $mount_require,
    }
  }
}
