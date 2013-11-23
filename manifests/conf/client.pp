define ceph::conf::client (
  $keyring,
) {

  concat::fragment { "ceph-client-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '70',
    content => template('ceph/ceph.conf-client.erb'),
  }

}
