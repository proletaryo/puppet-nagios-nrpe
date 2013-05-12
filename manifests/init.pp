# = Class: nrpe
#
# == Parameters:
#
# allowed_hosts::   required, An array of allowed IPs that can connect to this NRPE instance
# ensure::          optional, running or stopped, default=running
# enable::          optional, true or false, default=true
# dont_blame_nrpe:: optional, Toggle the dont_blame_nrpe config to enable/disable argument passing 
#                   to check commands, default=false (dont_blame_nrpe=0)
# opsview_use::    optional, Define basic check commands with arguments enabled, you have to set
#                   dont_blame_nrpe=true to make this work
# service_check_command:: optional, A hash containing the additional command definition 
#                         e.g. { 'command_name' => '/path/to/it ARG' }
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
#
#   class { 'nrpe':
#     allowed_hosts         => [ "192.168.56.9", "10.10.10.23", ],
#     ensure                => running,
#     enable                => true,
#     dont_blame_nrpe       => true,
#     opsview_use           => true,
#     service_check_command => { 
#       'check_mem'  => '/usr/local/nagios/plugins/check_mem 40 60',
#       'check_blah' => '/usr/local/nagios/plugins/check_blah arg1 arg2',
#     },
#   }

class nrpe ( 
  $allowed_hosts, 
  $ensure                = running, 
  $enable                = true, 
  $dont_blame_nrpe       = false,
  $opsview_use           = false,
  $service_check_command = {},
) {

  validate_array($allowed_hosts)
  validate_hash($service_check_command)
  validate_bool($enable, $dont_blame_nrpe, $opsview_use)

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
  
  # set the pid file
  if $::osfamily == 'RedHat' {
    $pid_file = '/var/run/nrpe.pid'
  } elsif $::osfamily == 'Debian' {
    $pid_file = '/var/run/nagios/nrpe.pid'
  } else {
    fail("Error: Can't set the pid file, ${::osfamily} is not supported!")
  }


  # allowed hosts to connect
  $hosts = join( $allowed_hosts, ',' )

  if $::osfamily == 'RedHat' {
    package { $packages:
      ensure  => installed,
      require => Class['rpmforge'],
    }
  }
  else {
    package { $packages:
      ensure => installed,
    }
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
