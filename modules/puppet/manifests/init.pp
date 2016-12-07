## @init.pp, ensure puppet service enabled, and running on successive reboot.

## local variables
$root_dir = $::conf_dir

## puppet service
service { 'puppet':
    ensure    => running,
    enable    => true,
    subscribe => File["${root_dir}/puppet.conf"],
}
