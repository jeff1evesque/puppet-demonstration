# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  ## variables
  #
  #  Note: multiple vagrant plugins follow the following syntax:
  #
  #        required_plugins = %w(plugin1 plugin2 plugin3)
  #
  required_plugins = %w(vagrant-triggers)
  plugin_installed = false

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
    ## Variables
    #
    #  Note: remember to define ENV['ENV']
    #
    ENV['ENV'] = 'CentOS7'

    ## increase RAM to allow greater HEAP required by puppetserver
    puppetserver.vm.provider 'virtualbox' do |v|
      v.customize ['modifyvm', :id, '--memory', '5000']
    end

    ## implement custom vagrant box with ssh credentials
    if ENV['ENV'] == 'CentOS7'
      ## ensure private key
      puppetserver.trigger.before :up do
        run 'curl -o centos7x/.ssh/private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetserver.vm.box         = 'jeff1evesque/centos7x'
      puppetserver.vm.box_version = '1.0.1'
      $ssh_username               = 'provisioner'
      $ssh_password               = 'vagrant-provision'
      $privateKey                 = 'centos7x/.ssh/private'
    end

    ## ensure pty is used for provisioning (useful for vagrant base box)
    puppetserver.ssh.pty = true

    ## ssh
    puppetserver.ssh.private_key_path = $privateKey
    puppetserver.ssh.username         = $ssh_username
    puppetserver.ssh.password         = $ssh_password

    ## port forward guest to host machine
    puppetserver.vm.network 'forwarded_port', guest: 80, host: 7070
    puppetserver.vm.network 'forwarded_port', guest: 443, host: 7071

    ## clean up host files after 'vagrant destroy'
    puppetserver.trigger.after :destroy do
      run 'rm -f centos/.ssh/private'
    end
  end

  ## nonprimary machine: puppetagent
  #
  #  @autostart, determine if the machine should start automatically on
  #      'vagrant up'
  #
  config.vm.define 'puppetagent', autostart: false do |puppetagent|
    ## Variables
    #
    #  Note: remember to define ENV['ENV']
    #
    ENV['ENV'] = 'CentOS7'

    ## implement custom vagrant box with ssh credentials
    if ENV['ENV'] == 'CentOS7'
      ## ensure private key
      puppetagent.trigger.before :up do
        run 'curl -o centos7x/.ssh/private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetagent.vm.box         = 'jeff1evesque/centos7x'
      puppetagent.vm.box_version = '1.0.1'
      $ssh_username              = 'provisioner'
      $ssh_password              = 'vagrant-provision'
      $privateKey                = 'centos7x/.ssh/private'
    end

    ## ensure pty is used for provisioning (useful for vagrant base box)
    puppetagent.ssh.pty = true

    ## ssh
    puppetagent.ssh.private_key_path = $privateKey
    puppetagent.ssh.username         = $ssh_username
    puppetagent.ssh.password         = $ssh_password

    ## port forward guest to host machine
    puppetagent.vm.network 'forwarded_port', guest: 80, host: 8070
    puppetagent.vm.network 'forwarded_port', guest: 443, host: 8071

    ## clean up host files after 'vagrant destroy'
    puppetagent.trigger.after :destroy do
      run 'rm -f centos/.ssh/private'
    end
  end
end

