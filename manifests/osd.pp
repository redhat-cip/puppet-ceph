# Configure a ceph osd node
#
# == Parameters
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

class ceph::osd (
  $osd_addr = $ipaddress,
) {

  include 'ceph::package'

  package { ['xfsprogs', 'parted']:}

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>

  # Required or not ?
  #Ceph::Key<<| title == 'admin' |>>

  if !defined(Anchor['key_ok']) {
    anchor { 'key_ok':
      require => Ceph::Key['admin'],
    }
  }

  exec { 'ceph-get-monmap':
    command => 'ceph mon getmap -o /var/lib/ceph/tmp/monmap',
    creates => '/var/lib/ceph/tmp/monmap'
  }

}

