# Galara my.cnf configuration information

## ISSUES:
## 1) wget does not complete before package run executes. Need to find a way to wait state.
## 2) For some reason it does not pull the remi.repo or the galera.repo on the first go around. 
## 3) It will run if executed twice. 
## 4) Break into two or three executions?
## It works, but it doesn't work the way we would like.

class galera_setup_information {
	
  # Add some extra tools
  #package { 'wget': 
  #  ensure => installed,
  #}

  #package { 'git':
  #  ensure => installed,
  #}
  
  #package { 'curl':
  # ensure => installed,
  #}

  package { ensure => 'installed' }
  $tools = [ 'wget', 'git', 'curl' ]
  package { $tools: }
  #file { '/tmp/epel-release-latest-6.noarch.rpm': 
  # ensure => present,
  # path => '/tmp/epel-release-latest-6.noarch.rpm',
  # source => [ "puppet:///modules/galera_setup_information/epel-release-latest-6.noarch.rpm"]
  #}

  #file { '/tmp/remi-release-6.rpm': 
  #  ensure => present,
  #  path => '/tmp/remi-release-6.rpm',
  #  source => [ "puppet:///modules/galera_setup_information/remi-release-6.rpm"]
  #}

  # excute the necessary repository installations
  # This is an ugly method, but it does not seem to work otherwise
  exec { 'epel-release-latest-6':
    command => '/usr/bin/wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && /bin/rpm -Uvh epel-release-latest-6.noarch.rpm'
  }
  
  exec { 'remi-release-6':
    command => '/usr/bin/wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && /bin/rpm -Uvh remi-release-6*.rpm'
  }
  #package { 'epel-release-latest-6.noarch.rpm':
  #  ensure => installed,
  #  provider => rpm,
  #  source => "/tmp/epel-release-latest-6.noarch.rpm",
  #}

  #package { 'remi-release-6.rpm':
  #  ensure => installed,
  #  provider => rpm,
  #  source => "/tmp/remi-release-6.rpm",
  #}

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

