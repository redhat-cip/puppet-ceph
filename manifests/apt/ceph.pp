class ceph::apt::ceph (
  $release             = 'bobtail',
  $apt_key_source      = 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
  $apt_key_id          = '17ED316D',
  $apt_source_location = "http://ceph.com/debian-${release}/"
) {
  apt::key { 'ceph':
    key        => $apt_key_id,
    key_source => $apt_key_source,
  }

  apt::source { 'ceph':
    location => $apt_source_location,
    release  => $::lsbdistcodename,
    require  => Apt::Key['ceph'],
    before   => Package['ceph'],
  }
}
