# Installing Galera for CMS

**Tested on CentOS 6.7 with MySQL 5.6, Galera 3**

## Base Requirements

### RAM and CPU

Galera requires the following minimum server settings:

* 1 GHz CPU
* 512 MB RAM for the database
* 100 Mbps network connectivity
* With this you may need to enable swap space

### SELinux Settings

Galera requires the following modifications to _SELinux_

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

	TCP Port 4444 Host 1
	TCP Port 4444 Host 2
	TCP Port 4444 Host 3
	TCP Port 4567 Host 1
	TCP Port 4567 Host 2
	TCP Port 4567 Host 3
	UDP Port 4567 Host 1
	UDP Port 4567 Host 2
	UDP Port 4567 Host 3
	TCP Port 4568 Host 1
	TCP Port 4568 Host 2
	TCP Port 4568 Host 3

## Upgrading MySQL to 5.6 and installing Galera

**NOTE** Ideally all this is done with Chef/paker and the repos are removed from a gold AMI

Because CentOS/RHEL 6 comes with MySQL 5.1, you must first upgrade MySQL to 5.6

### Add the Repos

We will start by modifying files in `/etc/yum.repos.d/`

Create a `galera.repo` file and include:

	[galera]
	name = Galera
	baseurl = http://releases.galeracluster.com/DIST/RELEASE/ARCH
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