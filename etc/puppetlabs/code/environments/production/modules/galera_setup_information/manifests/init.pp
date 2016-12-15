# Galara my.cnf configuration information

class galera_setup_information {
	
  # Add some extra tools
  package { 'wget': 
    ensure => installed,
  }

  package { 'git':
    ensure => installed,
  }
  
  package { 'curl':
    ensure => installed,
  }

  file { '/tmp/epel-release-latest-6.noarch.rpm': 
   ensure => present,
   path => '/tmp/epel-release-latest-6.noarch.rpm',
   source => [ "puppet:///modules/galera_setup_information/epel-release-latest-6.noarch.rpm"]
  }

  file { '/tmp/remi-release-6.rpm': 
    ensure => present,
    path => '/tmp/remi-release-6.rpm',
    source => [ "puppet:///modules/galera_setup_information/remi-release-6.rpm"]
  }

   # excute the necessary repository installations
   package { 'epel-release-latest-6.noarch.rpm':
    ensure => installed,
    source => "/tmp/epel-release-latest-6.noarch.rpm",
   }

   package { 'remi-release-6.rpm':
     ensure => installed,
     source => "/tmp/remi-release-6.rpm",
   }

  # Galera repository
  file { '/etc/yum.repos.d/galera.repo':
    ensure => present,
    path => '/etc/yum.repos.d/galera.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/galera.repo"]
  }

  # epel repository
  file { '/etc/yum.repos.d/epel.repo':
    ensure => present,
    path => '/etc/yum.repos.d/epel.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/epel.repo"]
  }
  
  # remi.repo repository
  file { '/etc/yum.repos.d/remi.repo':
    ensure => present,
    path => '/etc/yum.repos.d/remi.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/remi.repo"]
  }

  # epel-testing repository
  file { '/etc/yum.repos.d/epel-testing.repo':
    ensure => present,
    path => '/etc/yum.repos.d/epel-testing.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/epel-testing.repo"]
  }

  # upgrade mysql
  package { 'mysql-libs':
    ensure => latest,
  }  

  # install the remaining packages
  package { 'galera-3': 
    ensure => installed,
  }

  package { 'mysql-wsrep-5.6':
    ensure => installed,
  }


  #file { 'my.cnf':
  #  ensure => present,
  #  path => '/etc/my.cnf',
  #  mode => '0600',
  # owner => 'root',
  # source => [ "puppet:///modules/galera/my.cnf" ],
  # }



}

