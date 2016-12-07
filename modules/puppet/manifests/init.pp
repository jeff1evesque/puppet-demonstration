## @init.pp, ensure puppet service enabled, and running on successive reboot.

## local variables
$config_file = '/etc/puppetlabs/puppet/puppet.conf'

## ensure configuration: allows 'subscribe'
##
## @notify, restarts puppet if the file changes
##
file { $config_file:
    ensure  => file,
    content => template('puppet/puppet.erb'),
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    notify  => Service['puppet'],
}

## puppet service
service { 'puppet':
    ensure  => running,
    enable  => true,
    require => File[$config_file],
}
