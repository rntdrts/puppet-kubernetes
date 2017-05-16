exec { "apt-get update":
    command => "/usr/bin/apt-get remove docker docker-engine",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
    logoutput => true,
}

exec { "install packages":
    command => "/usr/bin/apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common iptables sysv-rc libapparmor1 libc6 libdevmapper1.02.1 libltdl7 libsystemd-journal0",
    logoutput => true,
    require => Exec["apt-get update"],
}

exec { "download docker":
    command => "/usr/bin/curl -L https://download.docker.com/linux/ubuntu/dists/trusty/pool/stable/amd64/docker-ce_17.03.0~ce-0~ubuntu-trusty_amd64.deb -o /tmp/docker.deb",
    creates => '/tmp/docker.deb',
    logoutput => true,
    require => Exec["install packages"],
}

exec { "install docker":
    command => "/usr/bin/dpkg -i /tmp/docker.deb",
    logoutput => true,
    require => Exec["download docker"],
}

exec { "restart-docker":
    group => "docker",
    command => "/usr/bin/service docker restart",
    logoutput => true,
    require => Exec["install docker"],
}

exec { "install-kvm":
    command => "/usr/bin/curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.7.0/docker-machine-driver-kvm -o /usr/local/bin/docker-machine-driver-kvm",
    logoutput => true,
    require => Exec["restart-docker"],
}

exec { "chmod-kvm":
    command => "/bin/chmod +x /usr/local/bin/docker-machine-driver-kvm",
    logoutput => true,
    require => Exec["install-kvm"],
}

exec { "install libvirt-bin qemu-kvm":
    command => "/usr/bin/apt-get install -y libvirt-bin qemu-kvm",
    logoutput => true,
    require => Exec["chmod-kvm"],
}

exec { "libvirt-bin restart":
    command => "/usr/bin/service libvirt-bin restart",
    logoutput => true,
    require => Exec["install libvirt-bin qemu-kvm"],
}

exec { "download minikube":
    command => "/usr/bin/curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube",
    logoutput => true,
    require => Exec["libvirt-bin restart"],
}

exec { "install minikube":
    command => "/bin/chmod +x /usr/local/bin/minikube",
    logoutput => true,
    require => Exec["download minikube"],
}

exec { "download kubectl":
    command => "/usr/bin/curl -L https://storage.googleapis.com/kubernetes-release/release/$(/usr/bin/curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl",
    logoutput => true,
    require => Exec["install minikube"],
}

exec { "install kubectl":
    command => "/bin/chmod +x /usr/local/bin/kubectl",
    logoutput => true,
    require => Exec["download kubectl"],
    returns => 0,
}

group { 'docker':
    ensure => 'present',
    gid    => '998',
}

user { 'docker':
    ensure           => 'present',
    gid              => '998',
    uid              => '998',
}