# Define: pam_access::entry
#
# Parameters:
#
#   $ensure = present (default), absent
#
#     If $ensure is present, an access.conf entry will be created; otherwise, one
#     (or more) will be removed.
#
#   $user = username, (groupname), ALL (EXCEPT)
#
#     Supply a valid user/group specification.
#
#   $origin = tty, hostname, domainname, address, ALL, LOCAL
#
#     Supply a valid origin specification.
#
#   $group = true, false (default)
#
#     If $group is true, the user specification $user will be interpreted as
#     a group name.
#
# Actions:
#
#   Creates an augeas resource to create or remove
#
# Requires:
#
#   Augeas >= 0.8.0 (access.conf lens is not present in earlier releases)
#
# Sample Usage:
#
#   pam_access::entry {
#     "mailman-cron":
#       user   => "mailman",
#       origin => "cron";
#     "root-localonly":
#       permission => "-",
#       user       => "root",
#       origin     => "ALL EXCEPT LOCAL";
#     "lusers-revoke-access":
#       ensure => absent,
#       user   => "lusers",
#       group  => true;
#   }
#
define pam_access::entry (
  $ensure     = present,
  $permission = '+',
  $user       = false,
  $group      = false,
  $origin     = 'LOCAL',
  $position   = undef,
) {

  include ::pam_access

  # validate params
  validate_re($ensure, ['\Aabsent|present\Z'])
  validate_re($permission, ['\A[+-]\Z'], "\$pam_access::entry::permission must be '+' or '-'; '${permission}' received")
  if $user and $group {
    fail("\$pam_access::entry::user and \$pam_access::entry::group can not both be set")
  }
  if $position {
    $real_position = $position
  } else {
    $real_position = $permission ? {
      '+' => 'before',
      '-' => 'after',
    }
  }
  validate_re($real_position, ['\Aafter|before|-1\Z'])

  Augeas {
    context => '/files/etc/security/access.conf/',
    incl    => '/etc/security/access.conf',
    lens    => 'Access.lns',
  }

  if $pam_access::manage_pam {
    Augeas {
      notify => Class['pam_access::pam'],
    }
  }

  if $user {
    $userstr = $user ? {
      true    => $title,
      default => $user,
    }
    $context = 'user'
  } elsif $group {
    $userstr = $group ? {
      true    => $title,
      default => $group,
    }
    $context = 'group'
  } else {
    $userstr = $title
    $context = 'user'
  }

  # Prepare origin match parts
  $origin_parts = $origin.split( / +/ )
  $origin_match_list = $origin_parts.map() | $i, $part | {
    $j = $i + 1
    "[origin[${j}] = '${part}']"
  }
  $origin_matches = join( $origin_match_list )

  # Make augeas cmds
  case $ensure {
    'present': {
      case $real_position {
        'after': {
          $location = 'last()'
          $ins_cmd = "set access[last()+1] ${permission}"
        }
        'before': {
          $location = '1'
          $ins_cmd = 'ins access before access[1]'
        }
        '-1': {
          $location = 'last()-1'
          $ins_cmd = 'ins access before access[last()]'
        }
        default: { fail("Invalid real_position ${real_position}") }
      }
      $set_cmds = [
        "set access[${location}] ${permission}",
        "set access[${location}]/${context} ${userstr}",
      ]
      $origin_cmds = $origin.split( / +/ ).map | $i, $val | {
        $j = sprintf( String( $i + 1 ), '%03d' )
        "set access[${location}]/origin[${j}] ${val}"
      }
      $create_cmds = [ $ins_cmd ] + $set_cmds + $origin_cmds
      augeas { "pam_access/${context}/${permission}:${userstr}:${origin}/${ensure}":
        changes => $create_cmds,
        onlyif  => "match access[. = '${permission}'][${context} = '${userstr}']${origin_matches} size == 0",
      }
    }
    'absent': {
      augeas { "pam_access/${context}/${permission}:${userstr}:${origin}/${ensure}":
        changes => [
          "rm access[. = '${permission}'][${context} = '${userstr}']${origin_matches}",
        ],
        onlyif  => "match access[. = '${permission}'][${context} = '${userstr}']${origin_matches} size > 0",
      }
    }
    default: { fail("Invalid ensure: ${ensure}") }
  }

}
