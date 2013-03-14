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

It is being developped on Debian/Wheezy, using the Ceph package from Debian/Sid.

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

* Ceph OSDs ✗

  • OSD configuration ✓

  • OSD bootstrap key ✓

  • OSD device ✓

    - OSD device formatting ✗

    - OSD device mounting ✓

    - OSD filesystem creation ✓

    - OSD service key ✓

  • OSD service ✓

  • OSD registration ✓

  • Insert OSD into crushmap ✗

  • Working OSD ✗

* Rspec tests ✗

Testing
=======

Using Vagrant
-------------

Clone the repo & enter the created directory :::

    git clone git://github.com/fcharlier/puppet-ceph.git
    cd puppet-ceph

Launch three MONs :::

    vagrant up mon0
    vagrant up mon1
    vagrant up mon2

    vagrant ssh mon0 -c 'sudo puppet agent -vt'

Ceph MONs should be up :::

    vagrant ssh mon0 -c "sudo ceph mon stat"
    e3: 3 mons at {0=192.168.251.10:6789/0,1=192.168.251.11:6789/0,2=192.168.251.12:6789/0}, election epoch 4, quorum 0,1 0,1

Launth one OSD :::

    vagrant up osd1

