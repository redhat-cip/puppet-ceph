define ceph::key (
  $secret       = undef,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
) {

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}'",
    creates => $keyring_path,
    require => Package['ceph'],
  }

}
