# Configure a ceph osd device
#
# == Name
# the resource name is the full path to the device to be used.
#
# == Parameters
#
# [*partition_device*] if the device should get partitioned
#  Optional. Boolean (true or false).
#  Defaults to 'false.'
#
# [*journal*] path to place the journal
#  Optional. Defaults to undef.
#
# == Dependencies
#
# ceph::osd need to be called for the node beforehand. The
# MON node(s) need to be setup and running.
#
# == Authors
#
#  François Charlier <francois.charlier@enovance.com>
#  Danny Al-Gaaf <danny.al-gaaf@bisect.de>
#
# == Copyright
#
# Copyright 2013 eNovance <licensing@enovance.com>
#

define ceph::osd::device (
  $partition_device = true,
  $journal          = undef,
) {

  include ceph::osd
  include ceph::conf
  include ceph::params

  $devname = regsubst($name, '/dev/', '')

  if $partition_device == true {
    exec { "mktable_gpt_${devname}":
      command => "parted -a optimal --script ${name} mktable gpt",
      unless  => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
      require => Package['parted']
    }

    exec { "mkpart_${devname}":
      command => "parted -a optimal -s ${name} mkpart ceph 0% 100%",
      unless  => "parted ${name} print | egrep '^ 1.*ceph$'",
      require => [Package['parted'], Exec["mktable_gpt_${devname}"]]
    }
    $dev_path = "${name}1"
    $blkid_uuid_fact = "blkid_uuid_${devname}1"
    $osd_id_fact = "ceph_osd_id_${devname}1"
    $mkfs_require = [Package['xfsprogs'], Exec["mkpart_${devname}"]]
  } else {
    $dev_path = $name
    $blkid_uuid_fact = "blkid_uuid_${devname}"
    $osd_id_fact = "ceph_osd_id_${devname}"
    $mkfs_require = [Package['xfsprogs']]
  }

  # TODO: add other file systems ... otherwise fail!
  if $::ceph::conf::osd_mkfs_type == 'xfs' {
    exec { "mkfs_${devname}":
      command => "mkfs.xfs ${::ceph::conf::osd_mkfs_options} ${dev_path}",
      unless  => "xfs_admin -l ${dev_path}",
      require => $mkfs_require,
    }
  }
  elsif $::ceph::conf::osd_mkfs_type == 'btrfs' {
    exec { "mkfs_${devname}":
      command => "mkfs.btrfs ${::ceph::conf::osd_mkfs_options} ${dev_path}",
      unless  => "btrfs device scan ${dev_path}",
      require => $mkfs_require,
    }
  }

  $tmp_blkid = inline_template('<%= scope.lookupvar(blkid_uuid_fact) or "undefined" %>')

  if $tmp_blkid == 'undefined' {
    $osd_conf_id_fact = regsubst($osd_id_fact, 'ceph_osd_id', 'ceph_osd_conf_id')
    $osd_conf_id = inline_template('<%= scope.lookupvar(osd_conf_id_fact) or "undefined" %>')
    $uuid_conf_fact = "ceph_osd_conf_uuids_osd.${osd_conf_id}"
    $blkid = inline_template('<%= scope.lookupvar(uuid_conf_fact) or "undefined" %>')
  } else {
    $blkid = $tmp_blkid
  }

  if $blkid == 'undefined' {
    # workaround for e.g. /dev/mapper/mydmdevice devices!
    $blkid_file = regsubst($blkid_uuid_fact, '/', '-')
    exec { "get_blkid_${devname}":
      command => "blkid /sbin/blkid -s UUID -o value ${dev_path} > /var/lib/ceph/tmp/${blkid_file}",
      require => Exec["mkfs_${devname}"],
    }

    exec { "ceph_osd_create_${devname}":
      path    => '/usr/sbin:/usr/bin:/sbin:/bin:',
      command => "ceph osd create `cat /var/lib/ceph/tmp/${blkid_file}`",
      unless  => "ceph osd dump | grep -sq `cat /var/lib/ceph/tmp/${blkid_file}`",
      require => [Ceph::Key['client.admin'], Exec["get_blkid_${devname}"]],
    }

  } else {
    exec { "ceph_osd_create_${devname}":
      command => "ceph osd create ${blkid}",
      unless  => "ceph osd dump | grep -sq ${blkid}",
      require => Ceph::Key['client.admin'],
    }
  }

  $tmp_osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) or "undefined" %>')

  if $tmp_osd_id == 'undefined' {
    $osd_id = $osd_conf_id
  } else {
    $osd_id = $tmp_osd_id
  }

  if $blkid != 'undefined'  and defined( Ceph::Key['client.admin'] ){

    if $osd_id != 'undefined' {

      ceph::conf::osd { $osd_id:
        device       => $dev_path,
        cluster_addr => $::ceph::osd::cluster_address,
        public_addr  => $::ceph::osd::public_address,
        journal      => $journal,
      }

      $osd_data = regsubst($::ceph::conf::osd_data, '\$id', $osd_id)

      file { $osd_data:
        ensure => directory,
      }

      mount { $osd_data:
        ensure  => mounted,
        device  => $dev_path,
        atboot  => true,
        fstype  => $::ceph::conf::osd_mkfs_type,
        options => $::ceph::conf::osd_mount_options,
        pass    => 2,
        require => [
          Exec["mkfs_${devname}"],
          File[$osd_data]
        ],
      }

      exec { "ceph-osd-mkfs-${osd_id}":
        command => "ceph-osd -c /etc/ceph/ceph.conf -i ${osd_id} --mkfs --mkkey --osd-uuid ${blkid} ",
        creates => "${osd_data}/keyring",
        require => [
          Mount[$osd_data],
          Concat['/etc/ceph/ceph.conf'],
          ],
      }

      exec { "ceph-osd-register-${osd_id}":
        command => "ceph auth add osd.${osd_id} osd 'allow *' mon 'allow rwx' -i ${osd_data}/keyring",
        require => Exec["ceph-osd-mkfs-${osd_id}"],
      }

      exec { "ceph-osd-crush-add-${osd_id}":
        command => "ceph osd crush add ${osd_id} 1 root=default host=${::hostname}",
        onlyif  => "ceph osd dump |grep -q 'new ${blkid}'",
        before  => Exec["ceph-osd-crush-set-${osd_id}"],
        require => Exec["ceph-osd-register-${osd_id}"],
      }

      exec { "ceph-osd-crush-set-${osd_id}":
        command => "ceph osd crush set ${osd_id} 1 root=default host=${::hostname}",
        require => Exec["ceph-osd-register-${osd_id}"],
      }

      service { "ceph-osd.${osd_id}":
        ensure    => running,
        provider  => $::ceph::params::service_provider,
        start     => "service ceph start osd.${osd_id}",
        stop      => "service ceph stop osd.${osd_id}",
        status    => "service ceph status osd.${osd_id}",
        require   => Exec["ceph-osd-crush-set-${osd_id}"],
        subscribe => Concat['/etc/ceph/ceph.conf'],
      }

    }

  }

}
