# Setting up Puppet to install Galera

## Install puppet

For a bare node, you will need to do some work

Edit your `/etc/hosts` file if DNS is not enabled.

Add in the puppet labs repository

	yum install -y https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

And add in the client

	yum install -y puppet

Turn on the system

	puppet resource service puppet ensure=running enable=true
    
    puppet resource cron puppet-agent ensure=present user=root minute=30 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
  
    puppet agent --test --server=puppetserver.localdomain

Sign the certificate on the server

	puppet cert list

	puppet cert --sign <host>

Need to clean up a host?

	puppet cert clean <host>	


## File locations

Base location for the manifests:

	/etc/puppetlabs/code/environments/production/modules/galera_setup_information/manifests

Repository files and RPMS should live in:

	/etc/puppetlabs/code/environments/production/modules/galera_setup_information/files

The `init.pp` for installing `Galera` by puppet (still in progress)

	# Galara my.cnf configuration information
	## ISSUES:
	## 1) wget does not complete before package run executes. Need to find a way to wait state.
	## 2) For some reason it does not pull the remi.repo or the galera.repo on the first go around. 
	## 3) It will run if executed twice. 
	## 4) Break into two or three executions?
	## It works, but it doesn't work the way we would like.

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

  	# excute the necessary repository installations
  	# This is an ugly method, but it does not seem to work otherwise
    exec { 'epel-release-latest-6':
      command => '/usr/bin/wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && /bin/rpm -Uvh epel-release-latest-6.noarch.rpm'
    }
  
    exec { 'remi-release-6':
     command => '/usr/bin/wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && /bin/rpm -Uvh remi-release-6*.rpm'
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



	