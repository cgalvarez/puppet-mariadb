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
  #$version = $mariadb::repo_version

  # Validate input parameters
  #validate_numeric($branch)
  #case $branch {
  #  '5.5', '10.0', '10.1': {}
  #  default: {
  #    fail("Provided branch '${branch} is not supported")
  #  }
  #}

  # Workaround for fact osfamily when facter < 1.6.1
  #if $::osfamily {
  #  $osfamily = $::osfamily
  #} else {
  #  $osfamily = $::operatingsystem ? {
  #    /(RedHat|Fedora|CentOS|Scientific|SLC|Ascendos|CloudLinux|PSBM|OracleLinux|OVS|OEL)/ => 'RedHat',
  #    /(Ubuntu|Debian)/                                                                    => 'Debian',
  #    /(SLES|SLED|OpenSuSE|SuSE)/                                                          => 'Suse',
  #    /(Solaris|Nexenta)/                                                                  => 'Solaris',
  #    default                                                                              => $::operatingsystem  
  #  }
  #}

  #$os = $::operatingsystem ? {
  #  'RedHat' => 'rhel',
  #  default  => downcase($::operatingsystem),
  #}

  # Capture the major version of the operative system
  # release when semver provided
  #$os_ver = $::operatingsystemrelease ? {
  #  /(\d+)\..+/ => "${1}",
  #  default     => $::operatingsystemrelease,
  #}

  #$arch = $::architecture ? {
  #  'i386'   => 'x86',
  #  'x86_64' => 'amd64',
  #  default  => $::architecture,
  #}

  #$repo_branches = ($os == 'fedora' and $os_ver == '21') ? {
  #  true    => ['10.0', '10.1'],
  #  default => ['5.5', '10.0', '10.1'],
  #}

  #$repo_branches.each |$repo_branch| {
  #  yumrepo { 'mariadb':
  #    baseurl   => $hold ? {
  #      undef   => "http://yum.mariadb.org/${branch}/${os}${os_ver}-${arch}/",
  #      default => "https://downloads.mariadb.com/files/MariaDB/mariadb-${hold}/yum/${os}${os_ver}-${arch}/",
  #      #default => "http://archive.mariadb.org/mariadb-${hold}/yum/${os}${os_ver}-${arch}/",
  #    },
  #    enabled   => '1',
  #    gpgcheck  => '1',
  #    gpgkey    => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
  #    descr     => 'MariaDB Yum Repository ',
  #    ensure    => $ensure$repo_branch == $branch ? {
  #      true    => 'present',
  #      default => 'absent',
  #    },
  #  }
  #}

}
