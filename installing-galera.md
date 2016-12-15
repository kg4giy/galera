# Installing Galera for CMS

**Tested on Vagrant with bento/CentOS 6.7 nodes with MySQL 5.6, Galera 3**

Source documentation includes the [Galera documentation][link-galera], upgrade [information for MySQL][link-mysql], and [resetting root passwords][link-password].

[link-galera]: http://galeracluster.com/documentation-webpages/
[link-mysql]: https://www.zerostopbits.com/how-to-upgrade-mysql-5-1-to-mysql-5-5-on-centos-6-7/
[link-password]: https://www.howtoforge.com/setting-changing-resetting-mysql-root-passwords

## Base Requirements 

### RAM and CPU

Galera requires the following minimum server settings:

* 1 GHz CPU
* 512 MB RAM for the database
* 100 Mbps network connectivity
* With this you may need to enable swap space

### SELinux Settings

Galera requires the following modifications to _SELinux_ where it is running/active

For testing

	# semanage permissive -a mysqld_t

For production

Open the port

	# semanage port -a -t mysqld_port_t -p tcp 4567
	# semanage port -a -t mysqld_port_t -p tcp 4568  
	# semanage port -a -t mysqld_port_t -p tcp 4444  

and for UDP

	# semanage port -a -t mysqld_port_t -p udp 4567

Depending on your profiles and existing SELinux policies, additional work may need to be done.

### Firewall settings

You will need to enable the following security groups for AWS

	TCP Port 3306
	TCP Port 4444 
	TCP Port 4567 
	UDP Port 4567 
	TCP Port 4568

## Upgrading MySQL to 5.6 and installing Galera 

**NOTE** Ideally all this is done with Chef/paker and the repos are removed from a gold AMI

Because CentOS/RHEL 6 comes with MySQL 5.1, you must first upgrade MySQL to 5.6

### Add the Repos 

We will start by modifying files in `/etc/yum.repos.d/`

Create a `galera.repo` file and include:

	[galera]
	name = Galera
	baseurl = http://releases.galeracluster.com/centos/6/x86_64/
	gpgkey = http://releases.galeracluster.com/GPG-KEY-galeracluster.com
	gpgcheck = 1

Create an `epel.repo` file and include:
	
	[epel]
	name=Extra Packages for Enterprise Linux 6 - $basearch
	#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
	failovermethod=priority
	enabled=1
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

	[epel-debuginfo]
	name=Extra Packages for Enterprise Linux 6 - $basearch - Debug
	#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch/debug
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch
	failovermethod=priority
	enabled=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	gpgcheck=1

	[epel-source]
	name=Extra Packages for Enterprise Linux 6 - $basearch - Source
	#baseurl=http://download.fedoraproject.org/pub/epel/6/SRPMS
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch
	failovermethod=priority
	enabled=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	gpgcheck=1

Create and `epel-testing` file repo and include:

	[epel-testing]
	name=Extra Packages for Enterprise Linux 6 - Testing - $basearch
	#baseurl=http://download.fedoraproject.org/pub/epel/testing/6/$basearch
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=testing-epel6&arch=$basearch
	failovermethod=priority
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

	[epel-testing-debuginfo]
	name=Extra Packages for Enterprise Linux 6 - Testing - $basearch - Debug
	#baseurl=http://download.fedoraproject.org/pub/epel/testing/6/$basearch/debug
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=testing-debug-epel6&arch=$basearch
	failovermethod=priority
	enabled=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	gpgcheck=1

	[epel-testing-source]
	name=Extra Packages for Enterprise Linux 6 - Testing - $basearch - Source
	#baseurl=http://download.fedoraproject.org/pub/epel/testing/6/SRPMS
	mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=testing-source-epel6&arch=$basearch
	failovermethod=priority
	enabled=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	gpgcheck=1

Finally create a `remi.repo` file and include:

	# Repository: http://rpms.remirepo.net/
	# Blog:       http://blog.remirepo.net/
	# Forum:      http://forum.remirepo.net/

	[remi]
	name=Remi's RPM repository for Enterprise Linux 6 - $basearch
	#baseurl=http://rpms.remirepo.net/enterprise/6/remi/$basearch/
	mirrorlist=http://rpms.remirepo.net/enterprise/6/remi/mirror
	enabled=1
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-php55]
	name=Remi's PHP 5.5 RPM repository for Enterprise Linux 6 - $basearch
	#baseurl=http://rpms.remirepo.net/enterprise/6/php55/$basearch/
	mirrorlist=http://rpms.remirepo.net/enterprise/6/php55/mirror
	# NOTICE: common dependencies are in "remi-safe"
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-php56]
	name=Remi's PHP 5.6 RPM repository for Enterprise Linux 6 - $basearch
	#baseurl=http://rpms.remirepo.net/enterprise/6/php56/$basearch/
	mirrorlist=http://rpms.remirepo.net/enterprise/6/php56/mirror
	# NOTICE: common dependencies are in "remi-safe"
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-test]
	name=Remi's test RPM repository for Enterprise Linux 6 - $basearch
	#baseurl=http://rpms.remirepo.net/enterprise/6/test/$basearch/
	mirrorlist=http://rpms.remirepo.net/enterprise/6/test/mirror
	# WARNING: If you enable this repository, you must also enable "remi"
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-debuginfo]
	name=Remi's RPM repository for Enterprise Linux 6 - $basearch - debuginfo
	baseurl=http://rpms.remirepo.net/enterprise/6/debug-remi/$basearch/
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-php55-debuginfo]
	name=Remi's PHP 5.5 RPM repository for Enterprise Linux 6 - $basearch - debuginfo
	baseurl=http://rpms.remirepo.net/enterprise/6/debug-php55/$basearch/
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-php56-debuginfo]
	name=Remi's PHP 5.6 RPM repository for Enterprise Linux 6 - $basearch - debuginfo
	baseurl=http://rpms.remirepo.net/enterprise/6/debug-php56/$basearch/
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

	[remi-test-debuginfo]
	name=Remi's test RPM repository for Enterprise Linux 6 - $basearch - debuginfo
	baseurl=http://rpms.remirepo.net/enterprise/6/debug-test/$basearch/
	enabled=0	
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

### Upgrade MySQL 

	`yum update -y mysql*`

### Install Galera

	`yum install -y galera-3 mysql-wsrep-5.6`

### Set the MySQL database passwords

On each node:

	# service mysql start --skip-grant-tables 
	# mysql -u root

Inside MySQL:

	mysql> use mysql; 
	mysql> update user set password=PASSWORD("ROOT-PASSWORD") where User='root'; 
	mysql> flush privileges;
	mysql> quit;

And back on the node:

	# service mysql stop

## System Configuration 

Now that everything is installed, configure `/etc/my.cnf` to include

	[mysqld]
	datadir=/var/lib/mysql
	socket=/var/lib/mysql/mysql.sock
	user=mysql
	binlog_format=ROW
	bind-address=0.0.0.0
	default_storage_engine=innodb
	innodb_autoinc_lock_mode=2
	innodb_flush_log_at_trx_commit=0
	innodb_buffer_pool_size=122M
	wsrep_provider=/usr/lib/libgalera_smm.so
	wsrep_provider_options="gcache.size=300M; gcache.page_size=300M"
	wsrep_cluster_name="example_cluster"
	wsrep_cluster_address="gcomm://IP.node1,IP.node2,IP.node3"
	wsrep_sst_method=rsync

	[mysql_safe]
	log-error=/var/log/mysqld.log
	pid-file=/var/run/mysqld/mysqld.pid

**NOTE** : It is very important that if you have a 
	
	bind-address = 127.0.0.1

in your `my.cnf` file that it is commented out or removed. Otherwise the cluster will not work. 

## Cluster specific configurations

### Replication configuration

Additionally, these changed must be made to the `my.cnf` file per node.

* _wsrep_cluster_name_ This is the logical cluster name and should be the same on each node
* _wsrep_cluster_address_ This parameter is the IP definition for cluster, in a comma separated list
* _wsrep_node_name_ This is the logical name for each node
* _wsrep_node_address_ This parameter explicitly sets the IP address for the individual node. It gets used in the event that the auto-guessing does not produce desirable results.  

Add/edit the `my.cnf`. Ensure the IP and node names are correct for the servers being used.

	[mysqld]
	wsrep_cluster_name=MyCluster <-- Unique per cluster
	wsrep_cluster_address="gcomm://192.168.0.1,192.168.0.2,192.168.0.3" <-- all nodes in the cluster
	wsrep_node_name=MyNode1 <-- Unique per node
	wsrep_node_address="192.168.0.1" <-- Unique per node

For each node in the cluster, you must provide IP addresses for all other nodes in the cluster, using the _wsrep_cluster_address_ parameter. Cluster addresses are listed using this syntax:

	<backend schema>://<cluster address>[?<option1>=<value1>[&<option2>=<value2>]]

where the backend schema `gcomm` provides the group communication back-end for use in production. It takes an address and has several settings that you can enable through the option list, or by using the _wsrep_provider_options parameter_.

Ensure the _wsrep_provider_ variable is correctly set
	
	wsrep_provider=/usr/lib64/galera-3/libgalera_smm.so

## Start the cluster 

On the primary node (and only on the primary node), execute:

	# service mysql start --wsrep-new-cluster

Output should look like this:

	[root@node1-mysql vagrant]# service mysql start --wsrep-new-cluster
	Starting MySQL.... SUCCESS! 
	[root@node1-mysql vagrant]# ps aux | grep mysql
	root      4504  0.0  0.1  11436   516 pts/0    S    16:41   0:00 /bin/sh /usr/bin/mysqld_safe --datadir=/var/lib/mysql --pid-file=/var/lib/mysql/node1-mysql.localdomain.pid --wsrep-new-cluster
	mysql     4869  3.5 80.9 1728072 406200 pts/0  Sl   16:41   0:00 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --wsrep-new-cluster --log-error=/var/lib/mysql/node1-mysql.localdomain.err --pid-file=/var/lib/mysql/node1-mysql.localdomain.pid --socket=/var/lib/mysql/mysql.sock --wsrep_start_position=00000000-0000-0000-0000-000000000000:-1

In MySQL:

First you will be prompted to change/reset your password with this command:

	SET PASSWORD = PASSWORD('new_password');

Then: 

	mysql> show status like 'wsrep_cluster_size';
	+--------------------+-------+
	| Variable_name      | Value |
	+--------------------+-------+
	| wsrep_cluster_size | 1     |
	+--------------------+-------+
	1 row in set (0.01 sec)

On the other nodes:
	
	service mysql start

On the node, you will see:

	[root@localhost vagrant]# service mysql start
	Starting MySQL.......... SUCCESS! 

	[root@localhost vagrant]# ps axu | grep mysql
	root      2770  0.0  0.1  11436   912 pts/0    S    19:14   0:00 /bin/sh /usr/bin/mysqld_safe --datadir=/var/lib/mysql --pid-file=/var/lib/mysql/localhost.localdomain.pid
	mysql     3120  1.2 80.1 1728132 402596 pts/0  Sl   19:14   0:00 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/lib/mysql/localhost.localdomain.err --pid-file=/var/lib/mysql/localhost.localdomain.pid --socket=/var/lib/mysql/mysql.sock --wsrep_start_position=00000000-0000-0000-0000-000000000000:-1

On the master node, you will see:

	SHOW STATUS LIKE 'wsrep_cluster_size';

	+--------------------+-------+
	| Variable_name      | Value |
	+--------------------+-------+
	| wsrep_cluster_size | 2     |
	+--------------------+-------+

The master node will increment as each node comes into the cluster.

## Vagrant configuration additions

For a multi-node configuration make the following modifications in the `Vagrantfile`:

	config.vm.define :node1 do |node1|
    	node1.vm.box = "bento/centos-6.7"
   		node1.vm.network :private_network, ip: "192.168.31.10"
  	end
  
  	config.vm.define :node2 do |node2|
    	node2.vm.box = "bento/centos-6.7"
    	node2.vm.network :private_network, ip: "192.168.32.10"
  	end
  
  	config.vm.define :node3 do |node3|
    	node3.vm.box = "bento/centos-6.7"
    	node3.vm.network :private_network, ip: "192.168.33.10"
  	end


Vagrant cheats for repo creations

	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && rpm -Uvh epel-release-latest-6.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && rpm -Uvh remi-release-6*.rpm


## Using puppet

### Install puppet

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


### File locations

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



	