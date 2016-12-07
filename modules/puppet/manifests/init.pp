## @init.pp, ensure puppet service enabled, and running on successive reboot.

## local variables
$conf_dir = $::conf_dir

## puppet service
service { 'puppet':
    ensure    => running,
    enable    => true,
    subscribe => File["${conf_dir}/puppet.conf"],
}
