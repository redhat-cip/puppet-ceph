# Configure yum repository
#
# == Parameters
#
# [*release*]
#   (Optional) The ceph release name
#   Default to 'cuttlefish'
#
# == Dependencies
#
# none
#
# == Authors
#
#  Francois Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::yum::ceph (
  $release = 'cuttlefish'
) {
  yumrepo { 'ceph':
    descr    => "Ceph ${release} repository",
    baseurl  => "http://ceph.com/rpm-${release}/el6/x86_64/",
    gpgkey   =>
      'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
    gpgcheck => 1,
    enabled  => 1,
    priority => 5,
    before   => Package['ceph'],
  }
}
