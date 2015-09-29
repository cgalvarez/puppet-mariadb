## ?? - Next release

- Ability to hold packages to a fixed provided version/branch (both, RedHat and Debian families).
- Added support for 32 bits systems when managing the official repositories.
- Added support for official respositories of other yum distros than RedHat (CentOS, Fedora, openSUSE).
- Added mirrors support for Debian family (through parameter `mariadb::repo::debian::mirror`).
- Classes `mariadb::repo::redhat` and `mariadb::repo::debian` have been converted into defined types.
- Removed dependency of standardized set of run stages for Puppet from [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) (no more needed to include stdlib to avoid error `Could not find stage` on Debian family).
- Prevention of [installation issues](https://mariadb.com/kb/en/mariadb/installing-mariadb-deb-files/#installation-issues).
- Fixed some templates.

## 2015-09-25 - Fork from NeCTAR-RC/puppet-mariadb (master)

- Initial fork from NeCTAR-RC/puppet-mariadb (master)