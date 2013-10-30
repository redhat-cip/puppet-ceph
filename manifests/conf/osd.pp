define ceph::conf::osd (
  $device,
  $cluster_addr = undef,
  $public_addr  = undef,
  $journal = undef,
) {

  if $journal {
    $journal_real = regsubst($journal, '\$id', $name)
  } else {
    $journal_real = undef
  }

  concat::fragment { "ceph-osd-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '80',
    content => template('ceph/ceph.conf-osd.erb'),
  }

}
