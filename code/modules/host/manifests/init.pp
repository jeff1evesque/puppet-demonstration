### @init.pp, define '/etc/hosts'.
class host {
    $hosts = lookup('host')
    $ip    = $hosts['puppetserver']['ip']
    $fqdn  = $hosts['puppetserver']['fqdn']

    file { 'workaround-foreman.service':
        path    => '/etc/systemd/system/workaround-foreman.service',
        ensure  => file,
        content => dos2unix(template('host/foreman_workaround.erb')),
        mode    => '0711',
        owner   => root,
        group   => root,
    }

    service { 'workaround-foreman':
        ensure  => 'running',
        enable  => true,
        require => File['workaround-foreman.service'],
    }

    file { '/etc/hosts':
        ensure  => file,
        content => dos2unix(template('host/hosts.erb')),
        mode    => '0644',
        owner   => root,
        group   => root,
        notify  => Exec['restart-networking'],
    }

    exec { 'restart-networking':
        command     => 'service network restart',
        path        => '/usr/sbin',
        refreshonly => true,
    }
	
}
