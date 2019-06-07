function Get-NestedGroupMember {

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory)]
    [string]$Group
  )


  ## Find all members  in the group specified
  $members = Get-ADGroupMember -Identity $Group

  foreach ($member in $members)

    {
    ## If any member in  that group is another group just call this function again

    if ($member.objectClass -eq 'group'){
      Get-NestedGroupMember -Group $member.Name
      }

      ## otherwise, just  output the non-group object (probably a user account)
    else {
      $member.Name
      }

    }

  }