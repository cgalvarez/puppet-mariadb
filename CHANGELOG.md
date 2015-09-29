## ?? - Next release

- Allow holding a specific version/branch of MariaDB (both, RedHat and Debian families).
- Related to management of the official repositories by MariaDB Foundation:
   - Added support for 32 bits systems (for both, RedHat and Debian families).
   - Added support for other yum distros than RedHat (CentOS, Fedora, openSUSE).
   - Added mirrors support for Debian family (through hierable parameter `mariadb::mirror`).
- Classes `mariadb::repo::redhat` and `mariadb::repo::debian` have been converted into defined types.
- Removed dependency of standardized set of run stages for Puppet from [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) (it is no longer necessary to include stdlib to avoid error `Could not find stage` on Debian family).
- Prevention of [installation issues](https://mariadb.com/kb/en/mariadb/installing-mariadb-deb-files/#installation-issues).
- Fixed some templates issues.

## 2015-09-25 - Fork from NeCTAR-RC/puppet-mariadb (master)

- Initial fork from NeCTAR-RC/puppet-mariadb (master)