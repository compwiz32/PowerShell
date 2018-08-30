#function Get-PCGroupMembership {

# Param $input

# Get-ADPrincipalGroupMembership (Get-ADComputer $input).distinguishedname | select name | sort name
# }




$input = SRVWIN0979
# a$ = Get-ADPrincipalGroupMembership (Get-ADComputer $input).distinguishedname | select name | sort name
a$ = Get-ADComputer $input
a$ 
