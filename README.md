# Puppet Demonstration [![Build Status](https://travis-ci.org/jeff1evesque/puppet-demonstration.svg?branch=master)](https://travis-ci.org/jeff1evesque/puppet-demonstration)

This repository is a simple demonstration of a virtualized environment
 ([vagrant](https://www.vagrantup.com/) + [virtualbox](https://www.virtualbox.org/)),
 tailored to exhibit the [puppetserver](https://docs.puppet.com/puppetserver/latest/services_master_puppetserver.html)
 / [puppetagent](https://docs.puppet.com/puppet/latest/reference/man/agent.html) ecosystem,
 contained within [Centos 7x](https://www.centos.org/) operating systems.
 Specifically, a custom vagrant [base box](https://www.vagrantup.com/docs/boxes/base.html),
 has been created, from [minimal iso](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso),
 which vagrant provisions via the [`Vagrantfile`](https://github.com/jeff1evesque/puppet-demonstration/blob/master/Vagrantfile),
 using corresponding [install scripts](https://github.com/jeff1evesque/puppet-demonstration/tree/master/install_scripts).

 When vagrant completes provisioning, a puppetserver, with a corresponding
 [foreman](https://theforeman.org/) gui is available on the host on `192.168.0.10`,
 and can be used to manage various puppetagent nodes:

![Foreman Login](https://cloud.githubusercontent.com/assets/2907085/19436102/4c40ca40-943c-11e6-9554-cd13f363569c.PNG)

---

![Foreman Hosts](https://cloud.githubusercontent.com/assets/2907085/19436123/68a121e4-943c-11e6-8b18-c8582b232870.PNG)

## Configuration

Fork this project in your GitHub account.  Then, clone your repository, with
 one of the following approaches:

- [simple clone](https://github.com/jeff1evesque/machine-learning/blob/master/documentation/configuration/setup_clone.rst#simple-clone):
 clone the remote master branch.
- [commit hash](https://github.com/jeff1evesque/machine-learning/blob/master/documentation/configuration/setup_clone.rst#commit-hash):
 clone the remote master branch, then checkout a specific commit hash.
- [release tag](https://github.com/jeff1evesque/machine-learning/blob/master/documentation/configuration/setup_clone.rst#release-tag):
 clone the remote branch, associated with the desired release tag.

**Note**: various [approaches](https://github.com/jeff1evesque/machine-learning/blob/master/documentation/configuration/setup_clone.rst) can be used to clone the repository, which would cover the possibility of cloning the repository, at a specific commit hash.

## Installation

In order to proceed with the installation for this project, three dependencies
 need to be installed:

- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox 5.1.2](http://download.virtualbox.org/virtualbox/5.1.2/)
- [Extension Pack 5.1.2](http://download.virtualbox.org/virtualbox/5.1.2/)

**Note:** though there is a minimum requirement for the virtualbox version,
 the [extension pack](https://github.com/jeff1evesque/puppet-demonstration/blob/3145a783e3822e465419606e8ff96899bd2b116e/Vagrantfile#L46-L54)
 must be installed at `5.1.2`.

Once the necessary dependencies have been installed, execute the following
 command to build the virtual environment:

```bash
cd /path/to/machine-learning/
vagrant up
```

**Note:** an alternative syntax to `vagrant up`, is to run `vagrant up puppetserver`.

Depending on the network speed, the build can take between 10-15 minutes. So,
 grab a cup of coffee, and perhaps enjoy a danish while the virtual machine
 builds.

**Note:** a more complete refresher on virtualization, can be found within the
 vagrant [wiki page](https://github.com/jeff1evesque/machine-learning/wiki/Vagrant).

When `vagrant up` is complete, a `puppetserver` will be installed on the
 [primary machine](https://github.com/jeff1evesque/puppet-demonstration/blob/3145a783e3822e465419606e8ff96899bd2b116e/Vagrantfile#L31-L32).
 Next, a single `puppetagent`, can be configured to the latter `puppetserver`,
 as follows:

```bash
cd /path/to/machine-learning/
vagrant up puppetagent
```

## Testing / Execution

Once the [installation](https://github.com/jeff1evesque/puppet-demonstration/blob/master/README.md#installation)
 requirements are complete, the `puppetagent` can be synchronized to `puppetserver`:

```bash
$ vagrant ssh puppetagent
==> puppetagent: The machine you're attempting to SSH into is configured to use
==> puppetagent: password-based authentication. Vagrant can't script entering the
==> puppetagent: password for you. If you're prompted for a password, please enter
==> puppetagent: the same password you have configured in the Vagrantfile.
Enter passphrase for key '/c/Users/jeff1evesque/.ssh/id_rsa':
provisioner@127.0.0.1's password:
Last login: Sun Oct 16 12:30:18 2016 from gateway
[provisioner@localhost ~]$ sudo su
[root@localhost provisioner]# puppet agent -t
Info: Creating a new SSL key for localhost.localdomain
Info: csr_attributes file loading from /etc/puppetlabs/puppet/csr_attributes.yaml
Info: Creating a new SSL certificate request for localhost.localdomain
Info: Certificate Request fingerprint (SHA256): 1B:A2:76:58:9D:C8:D2:59:A2:5B:CC:E3:C9:2F:6E:C7:62:72:3A:6E:AE:B0:B6:AE:02:ED:87:8F:CA:30:8D:20
Info: Caching certificate for localhost.localdomain
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for localhost.localdomain
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Caching catalog for localhost.localdomain
Info: Applying configuration version '1476635580'
Info: Creating state file /opt/puppetlabs/puppet/cache/state/state.yaml
Notice: Applied catalog in 0.02 seconds
```

As shown in the [introduction](https://github.com/jeff1evesque/puppet-demonstration/blob/master/README.md#puppet-demonstration--),
 the foreman gui can be used, to manage the puppetserver, and corresponding
 puppetagent nodes. Specifically, foreman can be accessed on the host machine,
 via an [internal network](https://github.com/jeff1evesque/puppet-demonstration/blob/3145a783e3822e465419606e8ff96899bd2b116e/Vagrantfile#L99),
 on `192.168.0.10`.

This repository demonstrates the puppetserver / puppetagent ecosystem, with
 and intermediate gui, or foreman, to manage this ecosystem. Although, the
 corresponding [install scripts](https://github.com/jeff1evesque/puppet-demonstration/tree/master/install_scripts)
 can be run in vagrant, it requires some assumptions, if needed to be run
 on production like systems.

For example, the `install_foreman` bash script, assumes the containing virtual
 machine has a defined [proxy](https://en.wikipedia.org/wiki/Proxy_server).
 This is indicated by the following [snippet](https://github.com/jeff1evesque/puppet-demonstration/blob/7f08b038c1d9b54c2a464e6f8dc7c85834e25d2b/install_scripts/install_foreman#L23-L27),
 from the corresponding install script:

```bash
...
## acquire proxy ip
read -p 'Enter your proxy ip > ' PROXY_IP

## acquire proxy port
read -p 'Enter your proxy port > ' PROXY_PORT
...
```

**Note:** in the vagrant implementation, a proxy is not required, hence the
 same install script, does not prompt, nor make such definitions.