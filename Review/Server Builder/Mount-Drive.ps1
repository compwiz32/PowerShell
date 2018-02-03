Initialize-Disk -Number 1 -PartitionStyle GPT

New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter D