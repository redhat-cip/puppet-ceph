define ceph::key (
  $secret       = undef,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
  $capabilities = {},
) {

  #FIXME: inline-template to extract capabilities
  $capabilities_str = ''

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name=${name} --add-key='${secret}' ${capabilities_str}",
    creates => $keyring_path,
    require => Package['ceph'],
  }

}
