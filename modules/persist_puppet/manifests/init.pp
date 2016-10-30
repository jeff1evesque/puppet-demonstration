## @init.pp, ensure puppet service enabled, and running on successive reboot.

service { 'puppet':
    ensure    => running,
    enable    => true,
    subscribe => [
        File['/etc/puppet/puppet.conf'],
        File['/etc/puppetlabs/puppet/puppet.conf'],
    ],
}
