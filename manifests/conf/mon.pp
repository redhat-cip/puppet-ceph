define ceph::conf::mon (
  $mon_addr,
  $mon_port,
) {

  @@concat::fragment { "ceph-mon-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '50',
    content => template('ceph/ceph.conf-mon.erb'),
  }

}
