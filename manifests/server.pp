# Class: mariadb::server
#
# manages the installation of the mariadb server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_ensure*]
#     Ensure value for the server packages. Set to `present` or a version number.
#     If setting a version number see note below on `repo_version`. Ex.
#     '5.5.37'.
#   [*package_names*]
#     Array of names of the mariadb server packages.
#   [*service_name*]
#     Name of the mariadb service
#   [*service_provider*]
#     Service type's provider
#   [*client_package_names*]
#     Array of names of the mariadb client packages.
#   [*client_package_ensure*]
#     Ensure value for the client packages. Set to `present` or a version number.
#     If setting a version number see note below on `repo_version`. Ex.
#     '5.5.37'.
#   [*config_hash*]
#     hash of config parameters that need to be set.
#   [*enabled*]
#     If true, enable the service to start on boot.
#   [*repo_version*]
#     Sets the version string for the repo URL. For Debian-based systems a
#     'major.minor' version is expected. Ex. '5.5'. Set a more specific
#     version using `package_ensure` parameter. For RedHat-based systems a
#     full version is required. Ex. '5.5.37'. This is due to the way the
#     yum package repo is configured.
#   [*manage_service*]
#     If true, manage the service.
#   [*manage_repo*]
#     If true, manage the yum or apt repo.
#   [*config_hash*]   - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::server (
  $package_version         = $mariadb::params::server_package_version,
  $package_ensure          = $mariadb::params::server_package_ensure,
  $package_names           = $mariadb::params::server_package_names,
  $service_name            = $mariadb::params::service_name,
  $service_provider        = $mariadb::params::service_provider,
  $client_package_names    = $mariadb::params::client_package_names,
  $client_package_ensure   = $mariadb::params::client_package_ensure,
  $client_package_version  = $mariadb::params::client_package_version,
  $debiansysmaint_password = undef,
  $config_hash             = {},
  $enabled                 = true,
  $manage_service          = true,
  $manage_repo             = true,
  $pin_pkg                 = $mariadb::params::server_package_names,
) inherits mariadb::params {

  class { 'mariadb':
    package_names   => $client_package_names,
    package_ensure  => $client_package_ensure,
    package_version => $client_package_version,
    manage_repo     => $manage_repo,
    pin_pkg         => $pin_pkg,
    before          => Class['mariadb::config'],
  }

  Class['mariadb::server'] -> Class['mariadb::config']

  $config_class = { 'mariadb::config' => $config_hash }

  create_resources( 'class', $config_class )

  $repo_branch = validate_and_extract('repo_branch', $package_version, $mariadb::params::repo_branch)
  $real_package_names = $::osfamily ? {
    #'Debian' => regsubst($package_names, '^.*$', "\\0-${repo_branch}", ''),
    'Debian' => suffix($package_names, "-${repo_branch}"),
    'RedHat' => $package_names,
    default  => undef,
  }

  package { $real_package_names:
    require   => Package[$client_package_names],
    ensure    => (is_string($package_version) and $package_version =~ /^\d+\.\d+\.\d+/) ? {
      true    => regsubst($package_version, '^(\d+\.\d+\.\d+).*$', '\1*'),
      default => $package_ensure,
    },
  }

  file { '/var/log/mysql/error.log':
    owner   => 'mysql',
    require => Package[$real_package_names],
  }

  #if $debiansysmaint_password != undef {
  #  file { '/etc/mysql/debian.cnf':
  #    content => template('mariadb/debian.cnf.erb'),
  #  }
  #}

  $service_ensure = $enabled ? {
    true    => 'running',
    default => 'stopped',
  }

  if $manage_service {
    $piddir = dirname($mariadb::params::pidfile)

    file { $piddir:
      ensure    => directory,
      owner     => 'mysql',
      group     => 'mysql',
      mode      => '0755',
      require   => Package[$real_package_names],
    }

    -> service { 'mariadb':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $enabled,
      require  => Package[$real_package_names],
      provider => $service_provider,
    }
  }
}
