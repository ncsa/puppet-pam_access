# @summary This module manages
#   * pam_access
#   * `/etc/security/access.conf`
#   * Provides ability to inject rules into `/etc/security/access.conf`
#   See pam_access::entry for more documentation.
#
# @param ensure
#   Determines "what" Puppet will do when managing pam_access. Only valid if
#   `manage_pam` is True.
#
#   If set to `present`, configure pam_access.
#
#   If set to `absent`, unconfigure pam_access.
#
#   Must be one of "absent" or "present".
#
# @param manage_pam
#   If true, Puppet will do what the `ensure` parameter dictates.
#   Default: False
#
# @option entries
#   Entries to add to `/etc/security/access.conf`
#
#   See pam_access::entry for more documentation.
#
class pam_access (
  String  $ensure,
  Boolean $manage_pam,
  Hash    $entries,
) {
  validate_re($ensure, ['\Aabsent|present\Z'])

  file { '/etc/security/access.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $manage_pam {
    contain pam_access::pam
    Class['pam_access::pam'] -> File['/etc/security/access.conf']
  }

  create_resources('pam_access::entry', $entries)
}
