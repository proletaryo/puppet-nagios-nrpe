# = Class: nrpe
#
# == Parameters:
#
# allowed_hosts:: An array of allowed IPs that can connect to this NRPE instance
# ensure:: optional, running or stopped
# enable:: optional, true or false
# service_check_command:: A hash containing the command definition e.g. { 'command_name' => '/path/to/it ARG' }
#
# == Requires:
#
# lboynton-rpmforge (for OS based on RHEL)
#
# == Sample Usage:
#
#   class { 'nrpe':
#     allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
#   }
#
#   class { 'nrpe':
#     allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
#     ensure => running,
#     enable => false,
#   }
#
#   class { 'nrpe':
#     allowed_hosts         => [ "192.168.56.9", "10.10.10.23", ],
#     ensure                => running,
#     enable                => false,
#     service_check_command => { 
#       'check_mem'  => '/usr/local/nagios/plugins/check_mem 40 60',
#       'check_blah' => '/usr/local/nagios/plugins/check_blah arg1 arg2',
#     },
#   }

class nrpe ( $allowed_hosts, $ensure = running, $enable = true, $service_check_command = {} ) {

  validate_array($allowed_hosts)
  validate_hash($service_check_command)

  case $::operatingsystem {
    centos, redhat, amazon: {
      if ! defined(Class['rpmforge']) { include rpmforge }

      $service      = 'nrpe'
      $main_package = 'nagios-nrpe'
      $packages     = [ 'nagios-nrpe', 'nagios-plugins-users', 'nagios-plugins-load',
        'nagios-plugins-disk', 'nagios-plugins-procs', 'nagios-plugins-swap', ]

    }

    debian, ubuntu: {
      $service      = 'nagios-nrpe-server'
      $main_package = 'nagios-nrpe-server'
      $packages     = [ 'nagios-nrpe-server', 'nagios-plugins-basic', 'nagios-plugins', ]

    }

    default: { fail ("Error: Unrecognized operating system = ${::operatingsystem}") }

  }

  # set the lib path
  if $::architecture == 'x86_64' and $::osfamily == 'RedHat' {
    $libpath = '/usr/lib64'
  } else {
    $libpath = '/usr/lib'
  }

  # allowed hosts to connect
  $hosts = join( $allowed_hosts, ',' )

  package { $packages:
    ensure => installed,
  }

  file { 'nrpe.cfg':
    path    => '/etc/nagios/nrpe.cfg',
    ensure  => file,
    mode    => 644,
    owner   => 'root',
    group   => 'root',
    content => template('nrpe/nrpe.cfg.erb'),
    require => Package[$main_package],
    notify  => Service[$service],
  }

  service { $service:
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Package[$main_package], File['nrpe.cfg'] ],

  }

}
