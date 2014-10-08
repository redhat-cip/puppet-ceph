##2014-10-08 - release 1.2.0

###Summary
* mon: try to create admin keyring only after service started
* Reduce recovery priority (new feature)
* Use sane default XFS options (same as ceph-disk) (remove '-n size=64k')

####Bugfixes
* Fix deprecation warning in ceph::osd::device
* Increase ceph keyring timeout
* Fixing admin keyring exported resources
* future parser is using strict var types when comparing
* ceph_osd_bootstrap_key fact: increase timeout

##2014-06-23 - Features release 1.1.0

###Summary
* Allow to configure ceph's apt source
* Allow custom configuration for ceph conf (config hash)
* Ensure a consistent ordering of config keys
* Manage mon and osd in /var/lib/ceph

####Bugfixes
* Fix spec tests and RSpec 3.x formater

##2014-04-04 - First version 1.0.0

###Summary
* First stable version.
