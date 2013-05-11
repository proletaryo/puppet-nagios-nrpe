# puppet-nagios-nrpe

This module automates the installation/management of the NRPE agent for Nagios/Opsview.

Tested to work on 32-bit/64-bit:
  * Amazon AWS Linux
  * CentOS 6.x
  * Ubuntu 12.04

## Parameters
  * `allowed_hosts`: required
  * `ensure`: optional, default=running
  * `enable`: optional, default=true

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

This will create the following in `/etc/nagios/nrpe.cfg`:

    command[check_mem]=/usr/local/nagios/plugins/check_mem 40 60
    command[check_blah]=/usr/local/nagios/plugins/check_blah arg1 arg2

### Default command definitions 

Please note that this is intended to be used with Opsview so parameter passing was enabled (`dont_blame_nrpe=1`).

    command[check_users]=<%= libpath %>/nagios/plugins/check_users $ARG1$
    command[check_disk]=<%= libpath %>/nagios/plugins/check_disk $ARG1$
    command[check_procs]=<%= libpath %>/nagios/plugins/check_procs $ARG1$
    command[check_load]=<%= libpath %>/nagios/plugins/check_load $ARG1$
    command[check_swap]=<%= libpath %>/nagios/plugins/check_swap $ARG1$

## Dependencies

Requires the [lboynton-rpmforge](https://github.com/lboynton/puppet-rpmforge) module for RHEL based distributions.
