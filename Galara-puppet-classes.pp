#Galara puppet classes

#Superclass that Class 3, requires Class 2, requires Class 1? (this goes in init.pp)

class galera_setup {


}

#These go into other buckets.
#Class 1: Install tools, grab stuff, exit.

class galera_setup::tools inherits galera_setup {
	
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
  
  # excute the necessary repository grabs (file does not do remote http calls)
  # This is an ugly method, but it does not work otherwise
  exec { 'epel-release-latest-6':
    command => '/usr/bin/wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm'
  }
  
  exec { 'remi-release-6':
    command => '/usr/bin/wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm'
  }

  # Galera repository
  file { '/etc/yum.repos.d/galera.repo':
    ensure => present,
    path => '/etc/yum.repos.d/galera.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/galera.repo"]
  }
}

# Class 2: Intalls the repos

class galera_setup::repo inherits galera_setup {

  package { 'epel-release-latest-6.noarch.rpm':
    ensure => installed,
    provider => rpm,
    source => "/tmp/epel-release-latest-6.noarch.rpm",
  }

  package { 'remi-release-6.rpm':
    ensure => installed,
    provider => rpm,
    source => "/tmp/remi-release-6.rpm",
  }

  # remi.repo repository
  file { '/etc/yum.repos.d/remi.repo':
    ensure => present,
    path => '/etc/yum.repos.d/remi.repo',
    mode => '0644',
    owner => 'root',
    source => [ "puppet:///modules/galera_setup_information/remi.repo"]
  }
}

# Class 3: Updage MySQL, install galara, exit.

class galera_setup::install inherits galera_setup {
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
}