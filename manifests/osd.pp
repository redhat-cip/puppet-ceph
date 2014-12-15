# Configure a ceph osd node
#
# == Parameters
#
# [*public_address*]
#  (Optional) The IP address for the public (front-side) network. Set for each daemon.
#  Defaults to '$::ipaddress'
#
# [*cluster_address*]
#  (Optional) The IP address for the cluster (back-side) network. Set for each daemon.
#  Defaults to '$::ipaddress'
#
# == Dependencies
#
# none
#
# == Authors
#
#  Francois Charlier francois.charlier@enovance.com
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

  ensure_packages( [ 'xfsprogs', 'parted' ] )

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>
}
