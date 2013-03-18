===========
puppet-ceph
===========

About
=====

This is a Puppet_ module to install a Ceph_ cluster.

.. _Puppet: http://www.puppetlabs.com/
.. _Ceph: http://ceph.com/

Status
======

This module is currently in active development and must be considered unstable.

It is being developped on Debian/Wheezy, targetting the Bobtail Ceph release.

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

* Ceph MDSs ?

  • To be tested further ✗

* Rspec tests ✗

* Documentation ✗

Testing
=======

Using Vagrant
-------------

Clone the repo & enter the created directory :::

    git clone git://github.com/enovance/puppet-ceph.git
    cd puppet-ceph

Launch three MONs :::

    vagrant up mon0
    vagrant up mon1
    vagrant up mon2

Run puppet one more time to update the ceph configuration (uses exported resources) :::

    vagrant ssh mon0 -c 'sudo puppet agent -vt'
    vagrant ssh mon1 -c 'sudo puppet agent -vt'
    vagrant ssh mon2 -c 'sudo puppet agent -vt'

Ceph MONs should be up :::

    vagrant ssh mon0 -c "sudo ceph mon stat"
    e3: 3 mons at {0=192.168.251.10:6789/0,1=192.168.251.11:6789/0,2=192.168.251.12:6789/0}, election epoch 4, quorum 0,1 0,1

Launch at least 2 OSDs :::

    vagrant up osd1
    vagrant up osd2
    vagrant up osd3

This should work !
