# Class: mariadb::repo
#
#   This generic class prepare required data to add/pin/hold official
#   MariaDB Foundation repositories for Debian/RedHat families.
#
# Parameters:
#   [*branch*]
#     Sets the version string for the repo URL.
#   [*version*]
#     Specific version/branch to install.
#   [*hold*]
#     Whether to hold the provided `version` or not.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::repo (
  $branch  = '10.0',
  $version = undef,
  $hold    = false,
  $pin_pkg = undef,
) {

  # Validate input parameters
  validate_numeric($branch)
  case $branch {
    '5.5', '10.0', '10.1': {}
    default: {
      fail("Provided branch '${branch} is not supported")
    }
  }

  # Workaround for fact osfamily when facter < 1.6.1
  if $::osfamily {
    $osfamily = $::osfamily
  } else {
    $osfamily = $::operatingsystem ? {
      /(RedHat|Fedora|CentOS|Scientific|SLC|Ascendos|CloudLinux|PSBM|OracleLinux|OVS|OEL)/ => 'RedHat',
      /(Ubuntu|Debian)/                                                                    => 'Debian',
      /(SLES|SLED|OpenSuSE|SuSE)/                                                          => 'Suse',
      /(Solaris|Nexenta)/                                                                  => 'Solaris',
      default                                                                              => $::operatingsystem  
    }
  }

  $os = $::operatingsystem ? {
    'RedHat' => 'rhel',
    default  => downcase($::operatingsystem),
  }

  # Capture the major version of the operative system
  # release when semver provided
  $os_ver = $::operatingsystemrelease ? {
    /(\d+)\..+/ => "${1}",
    default     => $::operatingsystemrelease,
  }

  $arch = $::architecture ? {
    'i386'   => 'x86',
    'x86_64' => 'amd64',
    default  => $::architecture,
  }

  if ($os == 'fedora' and $os_ver == '21') or
      ($os == 'ubuntu' and member(['utopic', 'vivid'], $::lsbdistcodename)) or
      ($os == 'debian' and member(['jessie', 'sid'], $::lsbdistcodename)) {
    $repo_branches = ['10.0', '10.1']
  } else {
    $repo_branches = ['5.5', '10.0', '10.1']
  }

  $repo_branches.each |$repo_branch| {
    ensure_resource($mariadb::params::repo_class,
      regsubst("${mariadb::params::repo_class}_${repo_branch}", '\.', '_', 'G'),
      {
        os        => $os,
        os_ver    => $os_ver,
        arch      => $arch,
        hold      => $hold,
        branch    => $repo_branch,
        version   => $version,
        ensure    => ($repo_branch == $branch) ? {
          true    => 'present',
          default => 'absent',
        },
      }
    )
  }

}
