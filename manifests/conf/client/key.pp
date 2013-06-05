define ceph::conf::client::key (
) {

  concat::fragment { "ceph-client-key-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '91',
    content => template('ceph/ceph.conf-client-key.erb'),
  }

}
