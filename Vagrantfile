# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  ## variables
  ##
  ## Note: multiple vagrant plugins follow the following syntax:
  ##
  ##       required_plugins = %w(plugin1 plugin2 plugin3)
  ##
  required_plugins  = %w(vagrant-triggers)
  plugin_installed  = false
  ENV['AGENT_ENV']  = 'Trusty64'
  ENV['SERVER_ENV'] = 'CentOS7'

  ## install vagrant plugins
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      plugin_installed = true
    end
  end

  ## restart Vagrant: if new plugin installed
  if plugin_installed == true
    exec "vagrant #{ARGV.join(' ')}"
  end

  ## primary machine: puppetserver will autostart
  config.vm.define 'puppetserver', primary: true do |puppetserver|
    ## increase RAM to allow greater HEAP required by puppetserver
    puppetserver.vm.provider 'virtualbox' do |v|
      v.customize ['modifyvm', :id, '--memory', '4096']
    end

    ## implement custom vagrant box with ssh credentials
    ##
    ## Note: please ensure vbox, and guest additions on the host is 5.1.2:
    ##
    ##       - http://download.virtualbox.org/virtualbox/5.1.2/
    ##
    ##       this requirement is not arbitrary, and corresponds to the guest
    ##       additions installed on the vagrant base box. A difference between
    ##       the host and guest, will require each vagrant vm's defined in this
    ##       Vagrantfile, to be restarted after the initial build, with the
    ##       possibility of other manual configurations.
    ##
    if ENV['SERVER_ENV'] == 'CentOS7'

      ## ensure private key
      puppetserver.trigger.before :up do
        run 'mkdir -p .ssh'
        run 'curl -o .ssh/puppetserver_vagrant.private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetserver.vm.box         = 'jeff1evesque/centos7x'
      puppetserver.vm.box_version = '1.0.2'
      $ssh_username               = 'provisioner'
      $ssh_password               = 'vagrant-provision'
      $privateKey                 = '.ssh/puppetserver_vagrant.private'

      ## ensure pty is used for provisioning (useful for vagrant base box)
      puppetserver.ssh.pty = true

      ## ssh
      puppetserver.ssh.private_key_path = $privateKey
      puppetserver.ssh.username         = $ssh_username
      puppetserver.ssh.password         = $ssh_password

    elsif ENV['SERVER_ENV'] == 'Trusty64'

      atlas_repo  = 'jeff1evesque'
      atlas_box   = 'trusty64'
      box_version = '1.1.0'

      puppetserver.vm.box                        = "#{atlas_repo}/#{atlas_box}"
      puppetserver.vm.box_url                    = "https://atlas.hashicorp.com/#{atlas_repo}/boxes/#{atlas_box}/versions/#{box_version}/providers/virtualbox.box"
      puppetserver.vm.box_download_checksum      = 'cc26da6ba1c169bdc6e9168125ddb0525'
      puppetserver.vm.box_download_checksum_type = 'md5'

    end

    puppetserver.vm.provision 'shell', inline: <<-SHELL
      sudo yum install -y dos2unix
      dos2unix /vagrant/utility/*
    SHELL

    ## shell provision: install foreman (with puppetserver)
    puppetserver.vm.provision :shell, path: 'utility/install_foreman'

    ## ensure foreman on successive reboot
    ##
    ## Note: https://github.com/jeff1evesque/puppet-demonstration/issues/61
    ##
    puppetserver.vm.provision 'shell', run: 'always', path: 'utility/restart_network'

    ## internal network:  virtual machines can communicate between each other
    ##                    and with the hosting system but not outside.
    ##
    ## @ip, corresponds to the value defined in the /etc/hosts, which is
    ##     defined from 'install_foreman'.
    ##
    ## Note: since the 'install_foreman' defines /etc/hostname, and /etc/hosts,
    ##       defining config.vm.host_name is superfluous.
    ##
    ## Note: By default, private networks are host-only networks, because those
    ##       are the easiest to work with. However, internal networks can be
    ##       enabled as well.
    ##
    puppetserver.vm.network :private_network, ip: '192.168.0.10'

    ## clean up host files after 'vagrant destroy'
    puppetserver.trigger.after :destroy do
      run 'rm -rf .ssh/puppetserver_vagrant.private'
    end
  end

  ## nonprimary machine: puppetagent
  ##
  ## @autostart, determine if the machine should start automatically on
  ##     'vagrant up'
  ##
  config.vm.define 'puppetagent', autostart: false do |puppetagent|
    ## ensure puppet modules directory
    puppetagent.trigger.before :up do
      run 'mkdir -p code/environments/vagrant/modules'
      run 'mkdir -p code/environments/vagrant/modules_contrib'
    end

    ## Every Vagrant development environment requires a box. You can search for
    ## boxes at https://atlas.hashicorp.com/search.
    ##
    ## Note: if the NCCoE network won't allow the 'wget' the private ssh key, then
    ##       add the '--no-check-certificate' flag at the end of the command.
    ##
    if ENV['AGENT_ENV'] == 'CentOS7'

      ## ensure private key
      puppetagent.trigger.before :up do
        run 'mkdir -p .ssh'
        run 'curl -o .ssh/puppetagent_vagrant.private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetagent.vm.box         = 'jeff1evesque/centos7x'
      puppetagent.vm.box_version = '1.0.2'
      $ssh_username              = 'provisioner'
      $ssh_password              = 'vagrant-provision'
      $privateKey                = '.ssh/puppetagent_vagrant.private'

      ## implement pty since ssh user is not sudoless
      puppetagent.ssh.pty = true

      ## ssh
      puppetagent.ssh.private_key_path = $privateKey
      puppetagent.ssh.username         = $ssh_username
      puppetagent.ssh.password         = $ssh_password

      ## shell provision: install puppetagent
      puppetagent.vm.provision 'shell', inline: <<-SHELL
        sudo yum install -y dos2unix
        dos2unix /vagrant/utility/*
      SHELL
      puppetagent.vm.provision :shell, path: 'utility/install_puppet_agent_centos'

    elsif ENV['AGENT_ENV'] == 'Trusty64'

      atlas_repo        = 'jeff1evesque'
      atlas_box         = 'trusty64'
      atlas_box_version = '1.1.0'

      puppetagent.vm.box                        = "#{atlas_repo}/#{atlas_box}"
      puppetagent.vm.box_version                = atlas_box_version
      puppetagent.vm.box_download_checksum      = '28f704ae302a7b11879a7d835a727e8'
      puppetagent.vm.box_download_checksum_type = 'md5'

      ## shell provision: install puppetagent
      puppetagent.vm.provision 'shell', inline: <<-SHELL
        sudo apt-get install -y dos2unix
        dos2unix /vagrant/utility/*
      SHELL
      puppetagent.vm.provision :shell, path: 'utility/install_puppet_agent_ubuntu'

    end

    ## internal network:  virtual machines can communicate between each other
    ##                    and with the hosting system but not outside.
    ##
    ## Note: By default, private networks are host-only networks, because those
    ##       are the easiest to work with. However, internal networks can be
    ##       enabled as well.
    ##
    puppetagent.vm.network :private_network, ip: '192.168.0.11'

    ## clean up files on the host after 'vagrant destroy'
    puppetagent.trigger.after :destroy do
      run 'rm -rf .ssh/puppetagent_vagrant.private'
      run 'rm -rf code/environments/vagrant/modules_contrib'
    end
  end
end
