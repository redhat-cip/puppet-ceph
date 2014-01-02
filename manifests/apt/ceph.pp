# Configure ceph APT repository
#
# == Parameters
#
# [*release*] The ceph release name
#   Optional. Default to bobtail
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::apt::ceph (
  $release = 'bobtail'
) {
  apt::key { 'ceph':
    key        => '17ED316D',
    key_source => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
  }

  apt::source { 'ceph':
    location => "http://ceph.com/debian-${release}/",
    release  => $::lsbdistcodename,
    require  => Apt::Key['ceph'],
    before   => Package['ceph'],
  }
}
