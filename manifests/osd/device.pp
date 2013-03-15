# Configure a ceph osd device
#
# == Namevar
# the resource name is the full path to the device to be used.
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
# Copyright 2013 eNovance <licensing@enovance.com>
#

define ceph::osd::device (
) {

  include ceph::osd
  include ceph::conf

  $devname = regsubst($name, '.*/', '')

  exec { "mktable_gpt_${devname}":
    command => "parted -a optimal --script ${name} mktable gpt",
    unless => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
    require => Package [ "parted" ]
  }

  exec { "mkpart_${devname}":
    command => "parted -a optimal -s ${name} mkpart ceph 0% 100%",
    unless => "parted ${name} print | egrep '^ 1.*ceph$'",
    require => [ Package [ "parted" ], Exec [ "mktable_gpt_${devname}" ] ]
  }

  exec { "mkfs_${devname}":
    command => "mkfs.xfs -f -d agcount=${::processorcount} -l size=1024m -n size=64k ${name}1",
    unless  => "xfs_admin -l ${name}1",
    require => [ Package [ "xfsprogs" ], Exec [ "mkpart_${devname}"] ],
  }

  $blkid_uuid_fact = "blkid_uuid_${devname}1"
  notify { "BLKID FACT ${devname}: ${blkid_uuid_fact}": }
  $blkid = inline_template('<%= scope.lookupvar(blkid_uuid_fact) %>')
  notify { "BLKID ${devname}: ${blkid": }

  if $blkid != 'undefined' {
    exec { "ceph_osd_create_${devname}":
      command => "ceph osd create ${blkid}",
      unless  => "ceph osd dump | grep -sq ${blkid}",
    }

    $osd_id_fact = "ceph_osd_id_${devname}1"
    $osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) %>')

    if $osd_id != 'undefined' {

      ceph::conf::osd { $osd_id:
        device       => $name,
        cluster_addr => $ipaddress_eth1,
        public_addr  => $ipaddress_eth0,
      }

      $osd_data = regsubst($::ceph::conf::osd_data, '\$id', $osd_id)

      file { $osd_data:
        ensure => directory,
      }

      mount { $osd_data:
        ensure  => mounted,
        device  => "${name}1",
        atboot  => true,
        fstype  => 'xfs',
        options => 'rw,noatime,inode64',
        pass    => 2,
        require => [
          Exec["mkfs_${devname}"],
          File[$osd_data]
          ],
      }

      exec { "ceph-osd-mkfs-${osd_id}":
        command => "\
        ceph-osd -c /etc/ceph/ceph.conf \
        -i ${osd_id} \
        --mkfs \
        --mkkey",
        creates => "${osd_data}/keyring",
        require => [
          Mount[$osd_data],
          Concat['/etc/ceph/ceph.conf'],
          ],
      }

      exec { "ceph-osd-register-${osd_id}":
        command => "\
        ceph auth add osd.${osd_id} osd 'allow *' mon 'allow rwx' \
        -i ${osd_data}/keyring",
        require => Exec["ceph-osd-mkfs-${osd_id}"],
      }

      exec { "ceph-osd-crush-${osd_id}":
        command => "\
        ceph osd crush set ${osd_id} 1 root=default host=${::hostname}",
        require => Exec["ceph-osd-register-${osd_id}"],
      }

      service { "ceph-osd.${osd_id}":
        ensure  => running,
        start   => "service ceph start osd.${osd_id}",
        stop    => "service ceph stop osd.${osd_id}",
        status  => "service ceph status osd.${osd_id}",
        require => Exec["ceph-osd-crush-${osd_id}"],
      }

    }
  }

}
