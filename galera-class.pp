
#Galara puppet classes

#Superclass that Class 3, requires Class 2, requires Class 1?

#Class 1: Install tools, grab stuff, exit.
node default {
  include galera_setup_information, galera_install_rpm, galera_update_install
}

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
  
  # excute the necessary repository grabs (file does not do remote http calls)
  # This is an ugly method, but it does not work otherwise
  exec { 'epel-release-latest-6':
    cwd => '/tmp/',
    command => '/usr/bin/wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  }
  
  exec { 'remi-release-6':
    cwd => '/tmp/',
    command => '/usr/bin/wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm',
  }


  yumrepo { 'galera':
    name => 'galera',
    baseurl => 'http://releases.galeracluster.com/centos/6/x86_64/',
    gpgkey => 'http://releases.galeracluster.com/GPG-KEY-galeracluster.com',
    gpgcheck => 1,

  }
}
  # Galera repository
class galera_install_rpm {
  require galera_setup_information
  file { '/etc/yum.repos.d/galera.repo':
    ensure => present,
    path => '/etc/yum.repos.d/',
    mode => '0644',
    owner => 'root',
    source => '/etc/yum.repos.d',
  }

  

 #Class 2: Install RPMS, overwrite remi.repo, exit.

  package { 'epel-release-latest-6.noarch.rpm':
    ensure => installed,
    provider => rpm,
    source => "/tmp/epel-release-latest-6.noarch.rpm",
  }

  package { 'remi-release-6.rpm':
    require => Package['epel-release-latest-6.noarch.rpm'],
    ensure => installed,
    provider => rpm,
    source => "/tmp/remi-release-6.rpm",
  }
 
  # remi.repo repository
  #file { '/etc/yum.repos.d/remi.repo':
  #  ensure => present,
  #  mode => '0644',
  #  owner => 'root',
  #  source => '/etc/yum.repos.d',
  #}




}

# Class 3: Updage MySQL, install galara, exit.

# upgrade mysql
class galera_update_install {
  require galera_install_rpm
  exec { 'mysql-libs':
    command => '/usr/bin/yum update -y mysql-libs',
  } 

  # install the remaining packages
  package { 'galera-3': 
    ensure => installed,
  }

  package { 'mysql-wsrep-5.6':
    ensure => installed,
    require => Exec['mysql-libs'],
  }
}
