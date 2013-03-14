$fsid = '07d28faa-48ae-4356-a8e3-19d5b81e159e'
$mon_secret = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='

Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

class role_ceph (
  $fsid,
  $auth_type = 'cephx'
) {

  class { 'ceph::conf':
    fsid      => $fsid,
    auth_type => $auth_type,
  }

  include ceph::apt::ceph

}

class role_ceph_mon (
  $id
) {

  class { 'role_ceph':
    fsid           => $::fsid,
    auth_type      => 'cephx',
  }

  ceph::mon { $id:
    monitor_secret => $::mon_secret,
    mon_data       => '/var/lib/ceph/mon',
    mon_port       => 6789,
    mon_addr       => $ipaddress_eth1,
  }

}

node 'ceph-mon0.test' {
  class { 'role_ceph_mon': id => 0 }
}

node 'ceph-mon1.test' {
  class { 'role_ceph_mon': id => 1 }
}

node 'ceph-mon2.test' {
  class { 'role_ceph_mon': id => 2 }
}

node /ceph-osd.?\.test/ {

  class { 'role_ceph':
    fsid           => $::fsid,
    auth_type      => 'cephx',
  }

  class { 'ceph::osd' :
    osd_addr => $ipaddress_eth0,
  }

  ceph::osd::device { '/dev/sdb': }
}
