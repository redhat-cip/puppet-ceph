# ceph::role::osd
#
# Class for role-based configuration of Ceph object storage nodes
#
# This class configures a Ceph object storage (OSD) node
# according to global variables set either in a site manifest
# or in an External Node Classifier (ENC).
#
# It inherits from ceph::role::base, so a node with the
# ceph::role::mon class does not necessarily also need to be
# configured with ceph::role::base.
#
# This class understands the global variables defined for
# ceph::role::base, plus the following:
#
# ceph_osd_devices       - comma-separated list of devices to configure
#                          as OSDs (no default)
class ceph::role::osd inherits ceph::role::base {

  # Style note: it looks like poor form that these variables
  # do not use the explicit top scope ("$::ceph_release" etc.),
  # but this is deliberate. While global variables and variables
  # set by an ENC are in the top scope, node variables
  # (set per node in site.pp) are not. They are in node scope
  # instead. The node scope, however, is anonymous, so it does
  # not set any explicit prefix. So to allow variables to be set
  # both globally and at the node level, use the unqualified
  # references.
  # See additional information in:
  # http://docs.puppetlabs.com/puppet/3/reference/lang_scope.html#node-scope
  $devices = split($ceph_osd_devices, ',')

  class { 'ceph::osd':
    public_address  => getvar("::ipaddress_${public_interface}"),
    cluster_address => getvar("::ipaddress_${cluster_interface}"),
  }

  ceph::osd::device { $devices: }
}

