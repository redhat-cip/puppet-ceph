# Create the ceph keyring
#
define ceph::key (
  $secret,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
) {

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}'",
    unless => "grep ${secret} ${keyring_path}",
    require => Package['ceph'],
  }

}
