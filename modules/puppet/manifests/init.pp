## @init.pp, ensure puppet service enabled, and running on successive reboot.

## puppet service
service { 'puppet':
    ensure  => running,
    enable  => true,
}
