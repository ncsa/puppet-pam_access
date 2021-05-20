# @summary Implement pam_access on RHEL8 systems
#
# @param authselect_features
#   Valid only for RHEL8
#
#   Default:
#   * `with-pamaccess`
#
class pam_access::pam::redhat (
  Array[String] $authselect_features,
) {

  # RHEL8 (and newer?) use authselect

  $_ensure = lookup( 'pam_access::ensure' )

  # Only do work if a profile is active
  $_profile = $facts['authselect']['profile']
  if $facts['authselect']['profile'] =~ String[1] {

    $authselect_features.each | $feature_name | {
      if $feature_name in $facts['authselect']['features'] {
        if $_ensure == 'absent' {
          # feature is present but should be absent
          exec { "/usr/bin/authselect disable-feature ${feature_name}": }
        }
      } else {
        if $_ensure == 'present' {
          # feature is not present but should be
          exec { "/usr/bin/authselect enable-feature ${feature_name}": }
        }
      }
    }

  }

}
