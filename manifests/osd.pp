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
  $public_address  = $::ipaddress,
  $cluster_address = $::ipaddress,
) {

  include 'ceph::package'

  package { ['xfsprogs', 'parted']:}

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>

}

