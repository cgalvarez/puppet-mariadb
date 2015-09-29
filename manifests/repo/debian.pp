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

  # Pin version when requested or repo branch instead
  apt::pin { "pin_mariadb_${escaped_branch}":
    packages      => $mariadb::repo::pin_pkg ? {
      undef       => "mariadb-client-#{branch}",
      default     => [
        $mariadb::repo::pin_pkg,
        "${mariadb::repo::pin_pkg}-${branch}",
        "${mariadb::repo::pin_pkg}-core-${branch}",
      ],
    },
    version       => $ensure ? {
      'absent'    => '*',
      'present'   => $hold ? {
        true      => $version ? {
          undef   => "${branch}.*",
          default => "${version}-*",
        },
        false     => "${branch}.*",
      },
    },
    ensure        => ($hold and $ensure == 'present') ? {
      true        => 'present',
      default     => 'absent',
    },
    priority      => 1001,
  }

}
