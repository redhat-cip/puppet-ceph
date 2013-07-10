# Configure a ceph radosgw
#
# == Name
#   This resource's name is generally the hostname
# == Parameters
# [*monitor_secret*] See mon.pp
#   Mandatory.
#
# [*admin_email*] Email address for apache server admin
#   Optional. Defaults to root@localhost
#
# == Dependencies
#
# none
#
# == Authors
#
#  Dan van der Ster daniel.vanderster@cern.ch
#
# == Copyright
#
# Copyright 2013 CERN
#

define ceph::radosgw (
  $monitor_secret,
  $admin_email = 'root@localhost'
) {

  include 'ceph::package'
  include 'ceph::conf'
  include 'ceph::params'

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>

  ensure_packages( [ 'ceph-radosgw', 'httpd' ] )

  ceph::conf::radosgw { $name: }

  exec { 'ceph-radosgw-keyring':
    command =>"ceph auth get-or-create client.radosgw.${::hostname} osd 'allow rwx' mon 'allow r' --name mon. --key=${monitor_secret} -o /etc/ceph/ceph.client.radosgw.${::hostname}.keyring",
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    creates => "/etc/ceph/ceph.client.radosgw.${::hostname}.keyring",
    before  => Service["radosgw"],
    require => Package['ceph'],
  }

  file { '/etc/init.d/radosgw':
    ensure  => link,
    source  => '/etc/init.d/ceph-radosgw',
    require => Package['ceph'],
  }

  service { "radosgw":
    ensure    => running,
    provider  => $::ceph::params::service_provider,
    hasstatus => false,
    require   => [Exec['ceph-radosgw-keyring'], File['/etc/init.d/radosgw']],
  }

  package { 'mod_fastcgi':
    ensure   => 'present',
    provider => 'rpm',
    source   => 'http://pkgs.repoforge.org/mod_fastcgi/mod_fastcgi-2.4.6-2.el6.rf.x86_64.rpm',
    require  => Package['httpd']
  }    

  augeas{ 'turn_fastcgiwrapper_off':
    context => '/files/etc/httpd/conf.d/fastcgi.conf',
    changes => "set *[self::directive='FastCgiWrapper']/arg Off",
    require => Package['mod_fastcgi'],
    notify  => Service['httpd']
  }

  file { '/etc/httpd/conf.d/rgw.conf':
    content => template('ceph/rgw.conf.erb'),
    require => Package['httpd'],
    notify  => Service['httpd']
  }
  
  file { '/var/www/s3gw.fcgi':
    content => template('ceph/s3gw.fcgi.erb'),
    mode    => '0755',
    require => Package['httpd'],
    notify  => Service['httpd']
  }

  service { 'httpd':
    ensure   => 'running',
    require  => [File['/etc/httpd/conf.d/rgw.conf'], File['/var/www/s3gw.fcgi'],
      Package['mod_fastcgi'], Augeas['turn_fastcgiwrapper_off']]
  }

}
