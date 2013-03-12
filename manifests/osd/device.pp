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

  $devname = regsubst($name, /.*\//, '')

	exec { "mktable_gpt_${devname}":
		command => "parted -a optimal --script ${name} mktable gpt",
		unless => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
		require => Package [ "parted" ]
	}

	exec { "mkpart_${devname}":
		command => "parted -a optimal -s ${name} mkpart ceph 0% 100%",
		unless => "parted ${name} print | egrep '^ 1.*ceph$'",
		require => [ Package [ "parted" ], Exec [ "mktable_gpt_${name}" ] ]
	}

	exec { "mkfs_${devname}":
		command => "mkfs.xfs -f -d agcount=${::processorcount} -l size=1024m -n size=64k ${name}1",
		require => [ Package [ "xfsprogs" ], Exec [ "mkpart_${name}"] ],
	}

  $osd_id_fact = "ceph_osd_id_${devname}1"
  $osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) %>')

  if $osd_id {
    mount { "${ceph::osd::osd_data}/osd.${osd_id}":
      ensure  => mounted,
      device  => "${name}1",
      atboot  => true,
      fstype  => 'xfs',
      options => 'rw,noatime,inode64',
      pass    => 2,
      require => [ Exec [ "mkfs_${devname}" ] ]
    }
#
#    exec { "ceph-osd-mkfs-${::ceph_osd_id_name}":
#      command => "\
#ceph-osd -c /etc/ceph.conf \
#-i ${::ceph_osd_id_name} \
#--mkfs \
#--mkkey \
#--osd-uuid ${name}
#--monmap /var/lib/ceph/tmp/monmap",
#      creates => "${osd_data_expanded}/keyring",
#      before  => [
#        Exec['ceph-admin-key'],
#        #Exec['ceph-osd-bootstrap-key'],
#        Service["ceph-osd.${osd_id}"],
#      ],
#      require => [Anchor['key_ok'], Concat['/etc/ceph/ceph.conf']],
#    }
#
#    exec { "ceph-osd-register-${osd_id}":
#      command => "\
#ceph auth add osd.${osd_id} 'allow *' mon 'allow rwx' \
#-i ${osd_data_expanded}/keyring \
#--name client.bootstrap-osd \
#--keyring /var/lib/ceph/tmp/bootstrap-osd.keyring",
#      require => Exec["ceph-osd-mkfs-${osd_id}"],
#    }
#
#    service { "ceph-osd.${osd_id}":
#      ensure  => running,
#      start   => "service ceph start osd.${osd_id}",
#      stop    => "service ceph stop osd.${osd_id}",
#      status  => "service ceph status osd.${osd_id}",
#      require => Exec["ceph-osd-register-${osd_id}"],
#    }
#
  }

}






# Definition de la fonction
define partitionning {
}

# Exec de la fonction
partitionning { ["/dev/sdb", "/dev/sdc"]:}
