# Class: mariadb
#
#   This class installs mariadb client software.
#
# Parameters:
#   [*package_ensure*]
#     Ensure value for the package. Set to `present` or a version number.
#     If setting a version number see note below on `repo_version`. Ex.
#     '5.5.37'.
#   [*package_names*]
#     Array of names of the mariadb client packages.
#   [*repo_version*]
#     Sets the version string for the repo URL. For Debian-based systems a
#     'major.minor' version is expected. Ex. '5.5'. Set a more specific
#     version using `package_ensure` parameter. For RedHat-based systems a
#     full version is required. Ex. '5.5.37'. This is due to the way the
#     yum package repo is configured.
#   [*manage_repo*]
#     If true, manage the yum or apt repo.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb (
  $package_ensure  = 'present',
  $package_version = undef,
  $package_names   = $mariadb::params::client_package_names,
  $repo_version    = '10.0',
  $manage_repo     = true,
  $pin_pkg         = undef,
  $mirror          = $mariadb::params::mirror,
) inherits mariadb::params {

  # Extract branch from package version when provided
  if $package_version {
    if $package_version =~ /(\d+\.[xX]|\d+\.\d+\.[xX])/ {
      $branch  = regsubst($package_version, '\.[xX]', '', 'G')
    } elsif $package_version =~ /^\d+\.\d+\.\d+/ {
      $branch  = regsubst($package_version, '^(\d+\.\d+).*$', '\1')
      $version = regsubst($package_version, '^(\d+\.\d+\.\d+).*$', '\1')
    } else {
      fail("Provided version does not follow semver rules: ${package_version}")
    }
  } else {
    $branch  = '10.0'
    $version = undef
  }

  # Filter only the allowed branches
  $extracted_repo_version = "${branch}" ? {
    /(5|5\.5)/   => '5.5',
    /(10|10\.0)/ => '10.0',
    '10.1'       => '10.1',
    default      => undef,
  }

  if $package_version and !$extracted_repo_version {
    fail("There is no support for the requested branch: ${branch}")
  }

  if $manage_repo == true {
    # Set up repositories
    class { 'mariadb::repo':
      branch    => $extracted_repo_version ? {
        undef   => '10.0',
        default => $extracted_repo_version,
      },
      version   => $version,
      hold      => $package_ensure ? {
        'held'  => true,
        default => false,
      },
      pin_pkg   => $pin_pkg,
      before    => Class['mariadb::package'],
    }
  }

  # Packages
  class { 'mariadb::package':
    package_names  => $package_names,
    package_ensure => 'present',
  }

}
