# puppet-nagios-nrpe

This module automates the installation of the NRPE agent for Nagios/Opsview.

Tested to work on 32-bit/64-bit:
  * Amazon AWS Linux
  * CentOS 6.x
  * Ubuntu 12.04

## Usage

    class { 'nrpe':
      $allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
    }
 
    class { 'nrpe':
      $allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
      ensure => running,
      enable => false,
    }

### Enabled command definitions 

Please note that this is intended to be used with Opsview so parameter passing was enabled.

    command[check_users]=<%= libpath %>/nagios/plugins/check_users $ARG1$
    command[check_disk]=<%= libpath %>/nagios/plugins/check_disk $ARG1$
    command[check_procs]=<%= libpath %>/nagios/plugins/check_procs $ARG1$
    command[check_load]=<%= libpath %>/nagios/plugins/check_load $ARG1$
    command[check_swap]=<%= libpath %>/nagios/plugins/check_swap $ARG1$

## Dependencies

Requires the [lboynton-rpmforge](https://github.com/lboynton/puppet-rpmforge) module for RHEL based distributions.
