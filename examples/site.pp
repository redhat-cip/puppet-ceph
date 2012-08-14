$fsid = '07d28faa-48ae-4356-a8e3-19d5b81e159e'
$mon_secret = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='

Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

class ceph_mon (
  $id
) {

  ceph::mon { $id:
    fsid           => $::fsid,
    monitor_secret => $::mon_secret,
    auth_type      => 'cephx',
    mon_data       => '/var/lib/ceph',
    mon_port       => 6789,
    mon_addr       => $ipaddress_eth1,
  }

}

node 'ceph-mon0.test' {
  class { 'ceph_mon': id => 0 }
}

node 'ceph-mon1.test' {
  class { 'ceph_mon': id => 1 }
}

node 'ceph-mon2.test' {
  class { 'ceph_mon': id => 2 }
}
