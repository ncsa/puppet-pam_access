# @summary Configure pam_access on RHEL7 and earlier
#
# @param enable_pamaccess_flags
#   Valid only for RHEL7 and lower.
#
#   Default:
#   * `--enablelocauthorize`
#   * `--enablepamaccess`
#
# @param disable_pamaccess_flags
#   Valid only for RHEL7 and lower.
#   Default:
#   * `--enablelocauthorize`
#   * `--disablepamaccess`
#
class pam_access::pam::redhat7 (
  Array[String] $enable_pamaccess_flags,
  Array[String] $disable_pamaccess_flags,
) {
  $_ensure = lookup( 'pam_access::ensure' )

  # RHEL7 and earlier use authconfig
  $authconfig_flags = $_ensure ? {
    'present' => join($enable_pamaccess_flags, ' '),
    'absent'  => join($disable_pamaccess_flags, ' '),
  }
  $authconfig_update_cmd = "/usr/sbin/authconfig ${authconfig_flags} --update"
  $authconfig_test_cmd   = "/usr/sbin/authconfig ${authconfig_flags} --test"
  $authconfig_check_cmd  = "/usr/bin/test \"`${authconfig_test_cmd}`\" = \"`/usr/sbin/authconfig --test`\""

  exec { 'authconfig-access':
    command => $authconfig_update_cmd,
    unless  => $authconfig_check_cmd,
  }
}
