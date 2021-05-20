pam_access
=============
[![yamllint](https://github.com/ncsa/puppet-pam_access/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-pam_access/actions/workflows/yamllint.yml)
[![pdk-validate](https://github.com/ncsa/puppet-pam_access/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-pam_access/actions/workflows/pdk-validate.yml)

This module manages **pam_access** entries stored in `/etc/security/access.conf`.  It
requires Augeas >= 0.8.0.

Sample usage:

    class { 'pam_access':
      exec => true,
    }

    pam_access::entry { 'mailman-cron':
      user   => 'mailman',
      origin => 'cron',
    }

    pam_access::entry { 'root-localonly':
      permission => '-',
      user       => 'root',
      origin     => 'ALL EXCEPT LOCAL',
    }

    pam_access::entry { 'lusers-revoke-access':
      create => false,
      user   => 'lusers',
      group  => true,
    }
