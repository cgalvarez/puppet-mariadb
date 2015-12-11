# Debian Family (apt): Debian, Ubuntu, Mint
define mariadb::repo::debian (
  $os      = 'ubuntu',
  $os_ver  = 'trusty',
  $arch    = 'amd64',
  $branch  = '10.0',
  $version = undef,
  $hold    = false,
  $ensure  = 'present',
) {

  $mirror         = $mariadb::mirror
  $escaped_branch = regsubst("${branch}", '\.', '_', 'G')

  apt::source { "mariadb_mariadb_${escaped_branch}":
    before       => Class['mariadb::package'],
    ensure       => $ensure,
    comment      => "PPA for latest official MariaDB ${branch} packages by MariaDB Foundation",
    location     => "${mirror}/repo/${branch}/${os}",
    release      => $::lsbdistcodename,
    repos        => 'main',
    architecture => $::architecture,
    key          => {
      server     => 'pgp.mit.edu',  # 'keyserver.ubuntu.com',
      id         => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
      options    => ($::http_proxy and $::rfc1918_gateway == 'true') ? {
        true     => "http-proxy=${::http_proxy}",
        default  => false,
      },
    },
  }

  $pin_packages = split(join(regsubst($mariadb::repo::pin_pkg, '^.*$', "\\0,\\0-${branch},\\0-core-${branch}", ''), ','), ',')

  # Pin version when requested or repo branch instead
  # More info: http://manpages.ubuntu.com/manpages/precise/es/man5/apt_preferences.5.html
  apt::pin { "pin_mariadb_${escaped_branch}":
    packages    => $mariadb::repo::pin_pkg ? {
      undef     => "mariadb-client-#{branch}",
      default   => $pin_packages,
    },
    version     => $ensure ? {
      'absent'  => '*',
      'present' => $version ? {
        undef   => "${branch}.*",
        default => "/^${version}[-+].*/",
      },
    },
    ensure      => $ensure,
    priority    => 1001,
    before      => Class['mariadb::package'],
    order       => 50,
  }

  if !$hold and $ensure == 'present' and ($version or $branch) {
    $_setting_type = 'pref'
    $_path         = $::apt::params::config_files[$_setting_type]['path']
    $_ext          = $::apt::params::config_files[$_setting_type]['ext']
    $_base_name    = regsubst("pin_mariadb_${escaped_branch}", '[^0-9a-z\-_\.]', '_', 'IG')
    $_priority     = 50

    if defined(Class['mariadb::cluster']) {
      $require = [
        Package[$mariadb::cluster::galera_name],
        Service['mariadb'],
        Class['mariadb::package'],
      ]
    } elsif defined(Class['mariadb::server']) {
      $require = [
        Service['mariadb'],
        Class['mariadb::package'],
      ]
    } else {
      $require = Class['mariadb::package']
    }

    exec { "pin_mariadb_${escaped_branch}_postremoval":
      command => "/bin/rm -f ${_path}/${_priority}${_base_name}${_ext} ${_path}/${_base_name}${_ext}",
      user    => 'root',
      group   => 'root',
      require => $require,
    }
  }

}
