class nagios-nrpe ( $allowed_hosts ) {
  # dependency: lboynton-rpmforge (osfamily: RedHat)

  validate_array($allowed_hosts)

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
    content => template('nagios-nrpe/nrpe.cfg.erb'),
    require => Package[$main_package],
    notify  => Service[$service],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Package[$main_package], File['nrpe.cfg'] ],

  }

}
