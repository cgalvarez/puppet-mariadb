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
  $package_names   = $::mariadb::params::client_package_names,
  $manage_repo     = true,
  $repo_version    = $::mariadb::params::repo_branch,
  $pin_pkg         = undef,
  $mirror          = $::mariadb::params::mirror,
) inherits ::mariadb::params {

  $version     = validate_and_extract('version', $package_version)
  $repo_branch = validate_and_extract('repo_branch', $package_version, $repo_version)
  if $repo_branch != undef and $repo_version != undef and $repo_branch != $repo_version {
    fail("Provided version ${package_version} does not belong to the provided branch ${repo_version}")
  }

  if $manage_repo == true {
    # Set up repositories
    class { 'mariadb::repo':
      branch    => $repo_branch ? {
        undef   => $repo_version,
        default => $repo_branch,
      },
      version   => $version,
      hold      => $package_ensure ? {
        'held'  => true,
        default => false,
      },
      pin_pkg   => $pin_pkg,
    }
  }

  # Packages
  class { 'mariadb::package':
    package_names  => $package_names,
    package_ensure => 'present',
  }

}
