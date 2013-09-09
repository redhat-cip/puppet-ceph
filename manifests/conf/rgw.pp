define ceph::conf::rgw (
) {

  concat::fragment { "ceph-rgw-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '90',
    content => template('ceph/ceph.conf-rgw.erb'),
  }

}
