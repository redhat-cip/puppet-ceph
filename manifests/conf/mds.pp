define ceph::conf::mds (
  $mds_data
) {

  @@concat::fragment { "ceph-mds-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => 50,
    content => template('ceph/ceph.conf-mds.erb'),
  }

}
