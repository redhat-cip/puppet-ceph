# Configure a ceph osd
#
# == Name
# FIXME: use device path and get the device's uuid with blkid
#   This resource's name must be a uuid. (get one with `uuidgen -r`.)
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*osd_data*] Base path for osd data. Data will be put in a osd.$id folder.
#   Optional. Defaults to '/var/lib/ceph.
#
# [*osd_journal_path*] An eventual journal device.
#   Default: undef.
#
# [*osd_journal_is_file*] The journal is a file.
#   Default: false. If true, the journal file will be createdi
#   and its size will be osd_journal_size.
#
# [*osd_journal_size*] The journal size.
#   Default: undef. Set it if osd_journal_is_file == true.
#
# [*osd_addr*] The osd's address.
#   Optional. Defaults to the $ipaddress fact.
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
define ceph::osd (
  $fsid,
  $osd_data = '/var/lib/ceph/osd',
  auth_type = 'cephx',
  $osd_journal_path = undef,
  $osd_journal_is_file = false,
  $osd_journal_size = undef,
  $osd_addr = $ipaddress,
) {

  include 'ceph::package'

  Package['ceph'] -> Ceph::Key <<| title == 'bootstrap-osd' |>>

  if !defined(Anchor['key_ok']) {
    anchor { 'key_ok':
      require => Ceph::Key['bootstrap-osd'],
    }
  }

  Ceph::Key<<| title == 'bootstrap-osd' |>>


#    $osd_id = generate("\
#ceph osd create ${name} \
#--name client.bootstrap-osd \
#--keyring /var/lib/ceph/tmp/bootstrap-osd.keyring")
#
#    $osd_data_expanded = "${osd_data}/osd.${osd_id}"
#
#    file { $osd_data_expanded:
#      ensure  => directory,
#      owner   => 'root',
#      group   => 0,
#      mode    => '0755',
#      require => Anchor['key_ok'],
#    }
#
#    if !defined(Exec['ceph-get-monmap']) {
#      exec { 'ceph-get-monmap':
#        command => 'ceph mon getmap -o /var/lib/ceph/tmp/monmap',
#        creates => '/var/lib/ceph/tmp/monmap'
#      }
#    }
#
#    exec { "ceph-osd-mkfs-${osd_id}":
#      command => "\
#ceph-osd -c /etc/ceph.conf \
#-i ${osd_id} \
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
#  }

}
