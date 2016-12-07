## @init.pp, ensure puppet service enabled, and running on successive reboot.

## ensure configuration: allows 'subscribe'
##
## @notify, restarts puppet if the file changes
##
file { '/etc/puppetlabs/puppet/puppet.conf':
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
    require => File['/etc/puppetlabs/puppet/puppet.conf'],
}
