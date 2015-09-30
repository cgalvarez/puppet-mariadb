## 2015-09-30 - Release 1.0.0

- Allow holding a specific version/branch of MariaDB (both, RedHat and Debian families).
   - New parameters `mariadb::server::pin_pkg` and `mariadb::server::pin_pkg` added in case of any installation issue.
   - Upgrades/downgrades successfully executed if other version/branch than present is requested.
- Related to management of the official repositories by MariaDB Foundation:
   - Added support for 32 bits systems (for both, RedHat and Debian families).
   - Added support for other yum distros than RedHat (CentOS, Fedora, openSUSE).
   - Added mirrors support for Debian family (through hierable parameter `mariadb::mirror`).
   - `repo_version` taken from `mariadb::params::repo_version`, and tuneable through Hiera, although it is dynamically extracted and set from `package_version` when provided.
- Classes `mariadb::repo::redhat` and `mariadb::repo::debian` have been converted into defined types.
- Removed dependency of standardized set of run stages for Puppet from [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) (it is no longer necessary to include stdlib to avoid error `Could not find stage` on Debian family).
- Prevented [installation issues](https://mariadb.com/kb/en/mariadb/installing-mariadb-deb-files/#installation-issues).
- New custom function created to extract semver/branch from package version string.
- Fixed some templates issues.

## 2015-09-25 - Fork from NeCTAR-RC/puppet-mariadb (master)

- Initial fork from NeCTAR-RC/puppet-mariadb (master)