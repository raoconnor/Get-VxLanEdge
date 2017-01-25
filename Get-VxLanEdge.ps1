<# 
Get-VxLanEdge

.Description
    Get the names of the edge devices using a vxlan
	usefull when removing dhcp assignments
	russ 13/01/2017
	
.Acknowledgments 

    
.Example
    ./Get-VxLanEdge.ps1
	./Get-VxLanEdge.ps1 -vmName <vm> 
#>


# Set variables for vm input
[CmdletBinding()]
param (
[string]$vm = " "
)

Write-host "Get virtualwires and find the associated edge device "  -ForegroundColor Yellow  

# Collect vm name from input
if ($vm -ne " "){  
$vmName = Get-VM -name $vm

}
else{
$vm = read-host "Enter vm name:" 
$vmName = Get-VM -name $vm
}


# Additional code to fix issue with multiple vms being collected by Get-View 
"`n" 
$vmInfo = Get-vm $vm
$vmId =  $vmInfo.ExtensionData.MoRef.Value


# Collect individual vm networks
$vmview = get-view -viewtype VirtualMachine -filter @{"Name"="$vmName"}

$net0 = $vmview.Guest.Net.Network[0]
$Address0 = $vmview.Guest.Net.IpAddress[0,1] |  where {([IpAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
$net1 = $vmview.Guest.Net.Network[1]
$Address1 = $vmview.Guest.Net.IpAddress[2,3] |  where {([IpAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
$net2 = $vmview.Guest.Net.Network[2]
$Address2 =  $vmview.Guest.Net.IpAddress[4,5] |  where {([IpAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}


Write-host $vmname  -ForegroundColor White
Write-host $Address0 " - " $net0 
Write-host $Address1 " - " $net1 
Write-host $Address2 " - " $net2 

"`n" 

# Collect edge vms in folder
$folder = (Get-Folder vShield_Edge | Get-View)
$edgevms = Get-View -SearchRoot $folder.MoRef -ViewType "VirtualMachine" 

Write-Host "Remove the following IPs from these edges"  -ForegroundColor Yellow  "`n" 

  
foreach($edge in $edgevms)
{
#$edgeName = $edge.name
#$edgeNetworkView = get-view $edge.Network

	foreach($virtualwire in $edge.Guest.Net.Network)
	{
		if ($virtualwire -eq $net0 ){
		Write-Host $net0 
		Write-Host $edge.name "  >  " $vmId "  " $vmName "  " $Address0  -ForegroundColor White
		"`n" 
		}
	
		if ($virtualwire -eq $net1 ){
		Write-Host $net1 
		Write-Host $edge.name "  >  " $vmId "  " $vmName "  " $Address1  -ForegroundColor White   
		"`n" 
		}
		
		if ($virtualwire -eq $net2 ){
		Write-Host $net2  
		Write-Host $edge.name "  >  " $vmId "  " $vmName "  " $Address2  -ForegroundColor White  
		"`n" 
		}
		
	}
}


Write-host "Finished"  "`n" 



<# 

NOTES: 
IPv6 addresses are omitted - see $vmview.Guest.Net.IpAddress[x]

#>