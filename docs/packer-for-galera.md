# Build Galera with Packer



## packer.json

{
  "variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  },
  "builders": [{
    "type": "amazon-ebs",
    "access_key": "{{user `aws_access_key`}}",
    "secret_key": "{{user `aws_secret_key`}}",
    "region": "us-east-1",
    "source_ami": "ami-[fix ami value]",
    "instance_type": "[set as appropriate]",
    "ssh_username": "[set as appropriate]",
    "ami_name": "packer-example {{timestamp}}"
  }],

  "provisioners": [{
    "type": "shell",
    "inline": [
      "sleep 30",
      "sudo yum install -y wget curl git",
      "sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && sudo rpm -Uvh epel-release-latest-6.noarch.rpm",
      "sudo wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && sudo rpm -Uvh remi-release-6*.rpm",
      "sudo echo -e /etc/yum.repos.d/galera.repo | cat <<HERE",
        "[galera]",
        "name = Galera",
        "baseurl = http://releases.galeracluster.com/centos/6/x86_64/",
        "gpgkey = http://releases.galeracluster.com/GPG-KEY-galeracluster.com",
        "gpgcheck = 1",
        "HERE",
      "sudo sed 's/0/1' /etc/yum.repos.d/remi.repo | tee /etc/yum.repos.d/remi.repo",
      "sudo yum update -y mysql*",
      "sudo yum install -y galera-3 mysql-wsrep-5.6"
    ]
  }]
}