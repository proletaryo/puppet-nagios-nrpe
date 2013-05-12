# puppet-nagios-nrpe

This module automates the installation/management of the NRPE agent for Nagios/Opsview.

Tested to work on 32-bit/64-bit:

  * Amazon AWS Linux
  * CentOS 6.x
  * Ubuntu 12.04

## Parameters
  * `allowed_hosts`:   required, an array of allowed IPs that can connect to this NRPE instance
  * `ensure`:          optional, running or stopped, default=running
  * `enable`:          optional, boolean, default=true
  * `dont_blame_nrpe`: optional, boolean, default=false (dont_blame_nrpe=0), toggle the dont_blame_nrpe config to enable/disable argument passing to check commands
  * `opsview_use`:     optional, boolean, default=false, define basic check commands with arguments enabled, you have to set `dont_blame_nrpe=true` to make this work
  * `service_check_command`: optional, default={}, a hash containing the additional command definitions e.g. { 'command_name' => '/path/to/it ARG' }

## Usage

Basic:

    class { 'nrpe':
      allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
    }
 
Modify the behaviour of the NRPE service:

    class { 'nrpe':
      allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
      ensure => running,
      enable => false,
    }

If you want to add custom service check commands:

    class { 'nrpe':
      allowed_hosts         => [ "192.168.56.9", "10.10.10.23", ],
      ensure                => running,
      enable                => false,
      service_check_command => { 
        'check_mem'  => '/usr/local/nagios/plugins/check_mem 40 60',
        'check_blah' => '/usr/local/nagios/plugins/check_blah arg1 arg2',
      },
    }

Example above will create the following in `/etc/nagios/nrpe.cfg`:

    command[check_mem]=/usr/local/nagios/plugins/check_mem 40 60
    command[check_blah]=/usr/local/nagios/plugins/check_blah arg1 arg2

If you use Opsview, you might want to enable argument passing and some default check commands:

    class { 'nrpe':
      allowed_hosts         => [ "192.168.56.9", "10.10.10.23", ],
      ensure                => running,
      enable                => true,
      dont_blame_nrpe       => true,
      opsview_use           => true,
      service_check_command => { 
        'check_mem'  => '/usr/local/nagios/plugins/check_mem 40 60',
      }
    }

### `opsview_use => true`

This will enable the following check commands in `/etc/nagios/nrpe.cfg`:

    command[check_users]=<%= libpath %>/nagios/plugins/check_users $ARG1$
    command[check_disk]=<%= libpath %>/nagios/plugins/check_disk $ARG1$
    command[check_procs]=<%= libpath %>/nagios/plugins/check_procs $ARG1$
    command[check_load]=<%= libpath %>/nagios/plugins/check_load $ARG1$
    command[check_swap]=<%= libpath %>/nagios/plugins/check_swap $ARG1$

Note: You have to set `dont_blame_nrpe => true` for this to work properly.

## Dependencies

Requires the [lboynton-rpmforge](https://github.com/lboynton/puppet-rpmforge) module for RHEL based distributions.
