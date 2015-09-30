# RPM Family (yum): RedHat, CentOS, Fedora, openSUSE
define mariadb::repo::redhat (
  $os      = 'rhel',
  $os_ver  = '6',
  $arch    = 'amd64',
  $branch  = '10.0',
  $version = undef,
  $hold    = false,
  $ensure  = 'present',
) {

  $escaped_branch = regsubst("${branch}", '\.', '_', 'G')

  yumrepo { "mariadb_mariadb_${escaped_branch}":
    before     => Class['mariadb::package'],
    baseurl    => ($hold and $ensure == 'present') ? {
      #true    => "http://archive.mariadb.org/mariadb-${hold}/yum/${os}${os_ver}-${arch}/",
      true     => "https://downloads.mariadb.com/files/MariaDB/mariadb-${version}/yum/${os}${os_ver}-${arch}/",
      default  => "http://yum.mariadb.org/${branch}/${os}${os_ver}-${arch}/",
    },
    enabled    => $ensure ? {
      'absent' => 'absent',
      default  => '1',
    },
    gpgcheck   => '1',
    gpgkey     => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    descr      => "PPA for latest official MariaDB ${branch} packages by MariaDB Foundation",
    ensure     => $ensure,
  }

}
