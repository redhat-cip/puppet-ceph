===========
puppet-ceph
===========

About
=====

|BuildStatus|_

.. |BuildStatus| image:: https://travis-ci.org/enovance/puppet-ceph.png?branch=master
.. _BuildStatus: https://travis-ci.org/enovance/puppet-ceph

This is a Puppet_ module to install a Ceph_ cluster.

.. _Puppet: http://www.puppetlabs.com/
.. _Ceph: http://ceph.com/

Status
======

Developped/tested on Debian GNU/Linux Wheezy, targetting the Bobtail Ceph release.

Features
========

* Ceph package ✓

* Ceph MONs ✓

  • MON configuration ✓

  • MON service key ✓

  • MON filesystem creation ✓

  • MON service ✓

  • MON cluster ✓

  • admin key ✓

* Ceph OSDs ✓

  • OSD configuration ✓

  • OSD bootstrap key ✓

  • OSD device ✓

    - OSD device formatting ✓

    - OSD device mounting ✓

    - OSD filesystem creation ✓

    - OSD service key ✓

  • OSD service ✓

  • OSD registration ✓

  • Insert OSD into crushmap ✓

  • Working OSD ✓

TODO
====

* Finish writing the rspec tests

* Better OSD device placement possibilities

* Test/finish MDS/RadosGW code

Contributing
============

Contributions are welcome, just fork on GitHub and send a pull-request !

* When adding features, don't forget to add unit tests.

* puppet-lint (https://github.com/rodjek/puppet-lint) should not produce too much errors too :)

Using
=====

To install a Ceph cluster you'll need at least *one* host to act as a MON and with the current crushmap defaults *two* hosts to act as OSDs. (The MON *might* be the same as an OSD, but has not been tested yet). And of course one puppetmaster :-)

This module requires the puppet master to have `storeconfigs = true` set and a storage backend configured. On the puppet agents `pluginsync = true` is required too.

Minimum Puppet manifest for all members of the Ceph cluster
-----------------------------------------------------------

A Ceph cluster needs a cluster `fsid` : get one with `uuidgen -r` (Install it with `apt-get install uuid-runtime`)::

    $fsid ='some uuid from uuidgen -r'

The general configuration::

    class { 'ceph::conf':
      fsid            => $fsid,
      auth_type       => 'cephx', # Currently only cephx is supported AND required
      cluster_network => '10.0.0.0/24', # The cluster's «internal» network
      public_network  => '192.168.0.0/24', # The cluster's «public» (where clients are) network
    }

APT configuration to install from the official Ceph repositories::

    include ceph::apt::ceph


Puppet manifest for a MON
-------------------------

A MON host also needs the MONs secret : get it with `ceph-authtool --create /path/to/keyring --gen-key -n mon.`::

    $mon_secret = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='

An Id::

    $id = 0 # must be unique for each MON in the cluster

And the mon declaration::

    ceph::mon { $id:
      monitor_secret => $mon_secret,
      mon_addr       => '192.168.0.10', # The host's «public» IP address
    }

Then on **ONLY ONE** MON, export the admin key (required by the OSDs)::

    if !empty($::ceph_admin_key) {
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }


**NOTE**: The puppet agent needs to be ran 3 times for the MON to be up and the admin key exported.

Puppet manifest for an OSD
--------------------------

An OSD host also needs the global host configuration for OSDs::

    class { 'ceph::osd':
      public_address  => '192.168.0.100',
      cluster_address => '10.0.0.100',
    }

And for each disk/device the path of the physical device to format::

    ceph::osd::device { '/dev/sdb': }

**WARNING**: this previous step will trash all the data from your disk !!!

On an OSD, the puppet agent must be ran at least 4 times for the OSD to be formatted, registered on the OSDs and in the crushmap.

Testing
=======

Using Vagrant
-------------

Clone the repo & enter the created directory ::

    git clone git://github.com/enovance/puppet-ceph.git
    cd puppet-ceph

Launch three MONs ::

    vagrant up mon0
    vagrant up mon1
    vagrant up mon2

Run puppet one more time to update the ceph configuration (uses exported resources) ::

    vagrant ssh mon0 -c 'sudo puppet agent -vt'
    vagrant ssh mon1 -c 'sudo puppet agent -vt'
    vagrant ssh mon2 -c 'sudo puppet agent -vt'

Ceph MONs should be up ::

    vagrant ssh mon0 -c "sudo ceph mon stat"
        e3: 3 mons at {0=192.168.251.10:6789/0,1=192.168.251.11:6789/0,2=192.168.251.12:6789/0}, election epoch 4, quorum 0,1 0,1

Launch at least 2 OSDs ::

    vagrant up osd1
    vagrant up osd2
    vagrant up osd3

Now login on mon0 (for example) & check ceph health ::

    vagrant ssh mon0 -c 'sudo ceph -s'
       health HEALTH_OK
       monmap e2: 2 mons at {0=192.168.252.10:6789/0,1=192.168.252.11:6789/0}, election epoch 4, quorum 0,1 0,1
       osdmap e35: 6 osds: 6 up, 6 in
        pgmap v158: 192 pgs: 192 active+clean; 0 bytes data, 242 MB used, 23601 MB / 23844 MB avail

