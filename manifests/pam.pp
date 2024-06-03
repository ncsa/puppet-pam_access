# @summary Private class - Not to be used directly
#
# See README.md for usage information
#
class pam_access::pam {

  $_os_ver = Integer.new( $facts['os']['release']['major'] )

  case $facts['os']['family'] {
    'RedHat': {
      if $_os_ver <= 7 {
        contain pam_access::pam::redhat7
      } else {
        contain pam_access::pam::authselect
      }
    }
    'Debian': {
      contain pam_access::pam::debian
    }
    'Suse': {
      contain pam_access::pam::authselect
    }
    default: {}
  }

}
