# = Class: nrpe
#
# == Parameters:
#
# allowed_hosts::   required, An array of allowed IPs that can connect to this NRPE instance
# ensure::          optional, running or stopped, default=running
# enable::          optional, true or false, default=true
# dont_blame_nrpe:: optional, Toggle the dont_blame_nrpe config to enable/disable argument passing
#                   to check commands, default=false (dont_blame_nrpe=0)
# opsview_use::     optional, Define basic check commands with arguments enabled, you have to set
#                   dont_blame_nrpe=true to make this work
# service_check_command:: optional, A hash containing the additional command definition
#                         e.g. { 'command_name' => '/path/to/it ARG' }
#
# include_nrpe_d::  optional, include checks in nrpe.d directory
#
#
# == Requires:
#
# yguenane/repoforge (for OS based on RHEL)
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
#     allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
#     ensure         => running,
#     enable         => false,
#     include_nrpe_d => true,
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
  $allowed_hosts         = '127.0.0.1',
  $ensure                = running,
  $enable                = true,
  $dont_blame_nrpe       = false,
  $opsview_use           = false,
  $server_address        = '0.0.0.0',
  $service_check_command = {},
  $include_nrpe_d        = false,
) {

  validate_array($allowed_hosts)
  validate_hash($service_check_command)
  validate_bool($enable, $dont_blame_nrpe, $opsview_use)

  case $::operatingsystem {
    amazon: {
      $service      = 'nrpe'
      $main_package = 'nrpe'
      $packages     = [ 'nrpe', 'nagios-plugins-users', 'nagios-plugins-load',
        'nagios-plugins-disk', 'nagios-plugins-procs', 'nagios-plugins-swap', ]

      # set the lib path
      if $::architecture == 'x86_64' {
        $libpath = '/usr/lib64'
      } else {
        $libpath = '/usr/lib'
      }

      # set the pid file
      $pid_file = '/var/run/nrpe/nrpe.pid'
      $template_file = 'nrpe/Amazon.nrpe.cfg.erb'

      service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
        require    => [ Package[$main_package], File['nrpe.cfg'] ],
      }

    }
    centos, redhat: {
      if ! defined(Class['repoforge']) { include repoforge }

      $service      = 'nrpe'
      $main_package = 'nagios-nrpe'
      $packages     = [ 'nagios-nrpe', 'nagios-plugins-users', 'nagios-plugins-load',
        'nagios-plugins-disk', 'nagios-plugins-procs', 'nagios-plugins-swap', ]

      # set the lib path
      if $::architecture == 'x86_64' {
        $libpath = '/usr/lib64'
      } else {
        $libpath = '/usr/lib'
      }

      # set the pid file
      $pid_file = '/var/run/nrpe.pid'
      $template_file = 'nrpe/nrpe.cfg.erb'

      service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
        require    => [ Package[$main_package], File['nrpe.cfg'] ],
      }

    }

    debian, ubuntu: {
      $service      = 'nagios-nrpe-server'
      $main_package = 'nagios-nrpe-server'
      $packages     = [ 'nagios-nrpe-server', 'nagios-plugins-basic', 'nagios-plugins', ]

      # config variables
      $libpath  = '/usr/lib'
      $pid_file = '/var/run/nagios/nrpe.pid'
      $template_file = 'nrpe/nrpe.cfg.erb'

      service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => false,
        status     => 'ps -Ao user,pid,command | egrep "^[n]agios" | grep -q "nrpe -c /etc/nagios/nrpe.cfg -d"',
        require    => [ Package[$main_package], File['nrpe.cfg'] ],
      }

    }

    default: { fail ("Error: Unrecognized operating system = ${::operatingsystem}") }

  }

  # allowed hosts to connect
  $hosts = join( $allowed_hosts, ',' )

  if $::operatingsystem =~ /(?i:RedHat|CentOS)/ {
    package { $packages:
      ensure  => installed,
      require => Class['repoforge'],
    }
  }
  else {
    package { $packages:
      ensure => installed,
    }
  }

  file { 'nrpe.cfg':
    ensure  => file,
    path    => '/etc/nagios/nrpe.cfg',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template($template_file),
    require => Package[$main_package],
    notify  => Service[$service],

  }

}
