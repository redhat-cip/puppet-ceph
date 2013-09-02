# Configure a ceph osd node
#
# == Parameters
#
# [*client_admin_secret*] The client.admin secret
#  Mandatory. The client.admin secret to generate a
#  keyring under '/etc/ceph/keyring' if needed to
#  setup and start the OSDs.
#
# [*public_address*] The OSD's public IP address.
#   Optional. Defaults to the $ipaddress fact.
#
# [*cluster_address*] The OSD's cluster IP address.
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
  $client_admin_secret,
  $public_address  = $::ipaddress,
  $cluster_address = $::ipaddress,
) {

  include 'ceph::package'

  ensure_packages( [ 'xfsprogs', 'parted' ] )

  ceph::key { 'client.admin':
    secret         => $client_admin_secret,
    keyring_path   => '/etc/ceph/keyring',
    require        => Package['ceph'],
  }
}

