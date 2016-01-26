<# 
.SYNOPSIS 
   Currently a work in progress to potentially be merged with vCheck.

   .DESCRIPTION
   Intended use is to gather information regarding all VSAN hosts in a vCenter inventory
   and compare the data found to known good VSAN configurations and best practices.
   Currently being developed for Dell VSAN Ready Nodes and hardware as the majority of
   the data will come from vCenter this could eventually be vendor agnostic.

.NOTES 
   File Name  : VSAN Check Script.ps1 
   Author     : Dustin Lenz - @dblenz
   Version    : .01 Alpha

.INPUTS
   No inputs required

.OUTPUTS
   HTML formatted email

.PARAMETER ???
   ???
#>

Function main {
	$VSANHostData=@{}
	$VSANReadyNodes=@{}

	Build-ReadyNodeArray

	connect-viserver lab-vc201.vcloud.lab -user administrator@vcloudsso.local -password Dell1234!

	$vsanhosts = get-vsandiskgroup
	$VSANHostNames = $vsanhosts.VMHost.Name

	ForEach ($VSANHost in $VSANHostNames){

		$VSANHostView = Get-VMHost $VSANHost | Get-View

		$VSANHostData[$VSANHost]=@{}
		$VSANHostData[$VSANHost]["HostInfo"]=@{}
		$VSANHostData[$VSANHost]["HostInfo"]["Hostname"]=@{}
		$VSANHostData[$VSANHost]["HostInfo"]["Hostname"]=$VSANHost
		$VSANHostData[$VSANHost]["HostInfo"]["Vendor"]=@{}
		$VSANHostData[$VSANHost]["HostInfo"]["Vendor"]=$VSANHostView.Hardware.SystemInfo.Vendor
		$VSANHostData[$VSANHost]["HostInfo"]["Model"]=@{}
		$VSANHostData[$VSANHost]["HostInfo"]["Model"]=$VSANHostView.Hardware.SystemInfo.Model

		$VSANHostData[$VSANHost]["Hardware"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Model"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Model"]=$VSANHostView.hardware.Cpupkg[0].description
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Sockets"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Sockets"]=$VSANHostView.hardware.cpuinfo.numcpupackages
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Cores"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Cores"]=$VSANHostView.hardware.cpuinfo.numcpucores
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Threads"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["CPU"]["Threads"]=$VSANHostView.hardware.cpuinfo.numcputhreads
		$VSANHostData[$VSANHost]["Hardware"]["BIOS"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["BIOS"]["Version"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["BIOS"]["Version"]=$VSANHostView.hardware.biosinfo.biosversion
		$VSANHostData[$VSANHost]["Hardware"]["BIOS"]["ReleaseDate"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["BIOS"]["ReleaseDate"]=$VSANHostView.hardware.biosinfo.releasedate
		$VSANHostData[$VSANHost]["Hardware"]["Memory"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["Memory"]["SizeinGB"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["Memory"]["SizeInGB"]=[decimal]::round($VSANHostView.hardware.MemorySize / 1GB)
	
		$a = 0
		$CacheDiskNumber = $VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.ssd.count
		$VSANHostData[$VSANHost]["Hardware"]["Drives"]=@{}
		$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Cache"]=@{}
		DO 
			{
			$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Cache"]["Drive" + $a]=@{}
			$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Cache"]["Drive" + $a]=[decimal]::round(($VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.ssd.capacity.block[$a] * $VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.ssd.capacity.blocksize[$a]) / 1GB)
			$a++
			}While($a -le $CacheDiskNumber - 1)
	
		$i = 0
		$CapDiskNumber = $VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.nonssd.count
		$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Capacity"]=@{}
		DO 
			{
			$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Capacity"]["Drive" + $i]=@{}
			$VSANHostData[$VSANHost]["Hardware"]["Drives"]["Capacity"]["Drive" + $i]=[decimal]::round(($VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.nonssd.capacity.block[$i] * $VSANHostView.config.vsanhostconfig.storageinfo.Diskmapping.nonssd.capacity.blocksize[$i]) / 1GB)
			$i++
			}While($i -le $CapDiskNumber - 1)
	}
}

#Data Functions
function Build-ReadyNodeArray
{
	$VSANReadyNodes["13GHY2"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]["Name"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]["Name"]="HY-2 Series"
	$VSANReadyNodes["13GHY2"]["Info"]["DellStarID"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]["DellStarID"]="5531701.1"
	$VSANReadyNodes["13GHY2"]["Info"]["Platform"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]["Platform"]="PowerEdge R630"
	$VSANReadyNodes["13GHY2"]["Info"]["ESXiVer"]=@{}
	$VSANReadyNodes["13GHY2"]["Info"]["ESXiVer"]="6.0"
	$VSANReadyNodes["13GHY2"]["Hardware"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["CPUModel"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["CPUModel"]="Intel Xeon CPU E5-2609v3 @ 1.9GHz"
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Sockets"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Sockets"]="2"
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Cores"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Cores"]="12"
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Threads"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["CPUInfo"]["Threads"]="12"
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAMInfo"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAMInfo"]["RAM"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAMInfo"]["RAM"]="256"
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAIDInfo"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAIDInfo"]["RAIDController"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAIDInfo"]["RAIDController"]="PERC H730"
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAIDInfo"]["RAIDFW"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["RAIDInfo"]["RAIDFW"]="25.3.0.0016"
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CacheDiskCount"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CacheDiskCount"]="1"
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CacheDiskSize"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CacheDiskSize"]="200"
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CapDiskCount"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CapDiskCount"]="5"
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CapDiskSize"]=@{}
	$VSANReadyNodes["13GHY2"]["Hardware"]["Drives"]["CapDiskSize"]="1024"

	$VSANReadyNodes["12GHY8DENSE"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["Name"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["Name"]="12G HY-8 Dense Series"
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["DellStarID"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["DellStarID"]="0"
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["Platform"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["Platform"]="PowerEdge C6220 II"
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["ESXiVer"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Info"]["ESXiVer"]="5.5U1"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["CPUModel"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["CPUModel"]="Intel Xeon CPU E5-2697v2 @ 2.7GHz"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Sockets"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Sockets"]="2"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Cores"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Cores"]="24"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Threads"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["CPUInfo"]["Threads"]="48"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAMInfo"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAMInfo"]["RAM"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAMInfo"]["RAM"]="256"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAIDInfo"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAIDInfo"]["RAIDController"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAIDInfo"]["RAIDController"]="LSI 9265-8i"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAIDInfo"]["RAIDFW"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["RAIDInfo"]["RAIDFW"]="3.44.25-4055"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CacheDiskCount"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CacheDiskCount"]="1"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CacheDiskSize"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CacheDiskSize"]="400"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CapDiskCount"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CapDiskCount"]="5"
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CapDiskSize"]=@{}
	$VSANReadyNodes["12GHY8DENSE"]["Hardware"]["Drives"]["CapDiskSize"]="900"
}

#Run Main Script block
Build-ReadyNodeArray
main