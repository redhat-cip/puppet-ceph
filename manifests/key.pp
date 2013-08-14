# Creates a ceph keyring file
#
# == Parameters
# [*secret*] The secret for the keyring
#   Mandatory. Get one with `ceph-authtool --gen-print-key`.
#
# [*keyring_path*] path to the keyring file.
#   Optional. Absolute file path incl. the file name.
#   Defaults to "/var/lib/ceph/tmp/${name}.keyring"
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
define ceph::key (
  $secret,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
) {

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}'",
    creates => $keyring_path,
    require => Package['ceph'],
  }

}
