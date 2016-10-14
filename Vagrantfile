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
    #
    #  Note: please ensure vbox, and guest additions on the host is 5.1.2:
    #
    #        - http://download.virtualbox.org/virtualbox/5.1.2/
    #
    #        this requirement is not arbitrary, and corresponds to the guest
    #        additions installed on the vagrant base box. A difference between
    #        the host and guest, will require each vagrant vm's defined in this
    #        Vagrantfile, to be restarted after the initial build, with the
    #        possibility of other manual configurations.
    #
    if ENV['ENV'] == 'CentOS7'
      ## ensure private key
      puppetserver.trigger.before :up do
        run 'mkdir -p .ssh'
        run 'curl -o .ssh/puppetserver_vagrant.private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetserver.vm.box         = 'jeff1evesque/centos7x'
      puppetserver.vm.box_version = '1.0.1'
      $ssh_username               = 'provisioner'
      $ssh_password               = 'vagrant-provision'
      $privateKey                 = '.ssh/puppetserver_vagrant.private'
    end

    ## ensure pty is used for provisioning (useful for vagrant base box)
    puppetserver.ssh.pty = true

    ## ssh
    puppetserver.ssh.private_key_path = $privateKey
    puppetserver.ssh.username         = $ssh_username
    puppetserver.ssh.password         = $ssh_password

    ## clean up host files after 'vagrant destroy'
    puppetserver.trigger.after :destroy do
      run 'rm -rf .ssh/puppetserver_vagrant.private'
    end

    ## shell provision: install foreman (with puppetserver)
    puppetserver.vm.provision :shell, path: 'install_scripts/install_foreman'

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
    puppetserver.vm.network :private_network, ip: '192.168.0.1'
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
    #
    #  Note: please ensure vbox, and guest additions on the host is 5.1.2:
    #
    #        - http://download.virtualbox.org/virtualbox/5.1.2/
    #
    #        this requirement is not arbitrary, and corresponds to the guest
    #        additions installed on the vagrant base box. A difference between
    #        the host and guest, will require each vagrant vm's defined in this
    #        Vagrantfile, to be restarted after the initial build, with the
    #        possibility of other manual configurations.
    #
    if ENV['ENV'] == 'CentOS7'
      ## ensure private key
      puppetagent.trigger.before :up do
        run 'mkdir -p .ssh'
        run 'curl -o .ssh/puppetagent_vagrant.private https://raw.githubusercontent.com/jeff1evesque/drupal-demonstration/master/centos7x/.ssh/private'
      end

      puppetagent.vm.box         = 'jeff1evesque/centos7x'
      puppetagent.vm.box_version = '1.0.1'
      $ssh_username              = 'provisioner'
      $ssh_password              = 'vagrant-provision'
      $privateKey                = '.ssh/puppetagent_vagrant.private'
    end

    ## ensure pty is used for provisioning (useful for vagrant base box)
    puppetagent.ssh.pty = true

    ## ssh
    puppetagent.ssh.private_key_path = $privateKey
    puppetagent.ssh.username         = $ssh_username
    puppetagent.ssh.password         = $ssh_password

    ## clean up host files after 'vagrant destroy'
    puppetagent.trigger.after :destroy do
      run 'rm -rf .ssh/puppetagent_vagrant.private'
    end

    ## shell provision: install puppetagent
    puppetagent.vm.provision :shell, path: 'install_scripts/install_puppet_agent'

    ## internal network:  virtual machines can communicate between each other
    ##                    and with the hosting system but not outside.
    ##
    ## Note: By default, private networks are host-only networks, because those
    ##       are the easiest to work with. However, internal networks can be
    ##       enabled as well.
    ##
    puppetagent.vm.network :private_network, ip: '192.168.0.2'
  end
end

