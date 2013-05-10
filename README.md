# puppet-nagios-nrpe
==================

This module automates the installation of the NRPE agent for Nagios/Opsview.

Tested to work on 32-bit/64-bit:
  * Amazon AWS Linux
  * CentOS 6.x
  * Ubuntu 12.04

## Usage

    class { 'nagios-nrpe':
      $allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
    }
 
    class { 'nagios-nrpe':
      $allowed_hosts => [ "192.168.56.9", "10.10.10.23", ],
      ensure => running,
      enable => false,
    }

## Dependencies

Requires the (lboynton-rpmforge)[https://github.com/lboynton/puppet-rpmforge] for RHEL based distributions.
