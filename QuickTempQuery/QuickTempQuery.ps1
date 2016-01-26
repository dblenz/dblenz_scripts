Param(
 #[Parameter(Mandatory=$false,Position=1)] [string]$zabbix_hostname = "vmware1.local.net",
  [Parameter(Mandatory=$false,Position=1)] [string]$vmware_host = "192.168.1.11",
  [Parameter(Mandatory=$false,Position=2)] [string]$vmware_userid = "root",
  [Parameter(Mandatory=$false,Position=3)] [string]$vmware_password = "D3ll1234!",
  [switch]$test
  )

$HostInfo = ""
$HostView = ""

Function SaveSensorNumeric([string]$sensorname, $itemdefault) {
  $val = $itemdefault
  $sen1 = $sensors.Get_Item($sensorname)
  If ($sen1 -ne $null) {
     $val = $sen1.CurrentReading
     switch ($sen1.UnitModifier) { 
        -4 {$val = $val / 10000} 
        -3 {$val = $val / 1000} 
        -2 {$val = $val / 100} 
        -1 {$val = $val / 10} 
        1 {$val = $val * 10} 
        2 {$val = $val * 100} 
        3 {$val = $val * 1000}
        4 {$val = $val * 10000} 
        default { }
        }
    }
  $val
  }

Function Custom_ProLiant_DL360_G5 {
  "Current Power Consumption: " + (SaveSensorNumeric "System Board 2 Power Meter" "sysboardpwr") + " watts"
  "CPU Temp #1: " + (((SaveSensorNumeric "Processor 6 Temp 7" "proc6tmp7")*1.8)+32) + "F"
  "CPU Temp #2: " + (((SaveSensorNumeric "Processor 5 Temp 6" "proc5tmp6")*1.8)+32) + "F"
  "CPU Temp #3: " + (((SaveSensorNumeric "Processor 4 Temp 4" "proc4tmp4")*1.8)+32) + "F"
  "CPU Temp #4: " + (((SaveSensorNumeric "Processor 3 Temp 3" "proc3tmp3")*1.8)+32) + "F"

  "CPU 1 Fan Temp: " + (((SaveSensorNumeric "Processor 1 Fan Block 2" "fan3pct")*1.8)+32) + "F"
  "CPU 2 Fan Temp: " + (((SaveSensorNumeric "Processor 2 Fan Block 3" "fan2pct")*1.8)+32) + "F"
  "Power Supply Temp: " + (((SaveSensorNumeric "Power Supply 4 Fan Block 1" "ps4fan1")*1.8)+32) + "F"
  "Internal Expansion Temp: " + (((SaveSensorNumeric "System Internal Expansion Board 1 Temp 1" "sysint1pct")*1.8)+32) + "F"

  "External Environment Temp " + (((SaveSensorNumeric "External Environment 1 Temp 2" ambienttemp -999)*1.8)+32) + "F"

  #SaveSensorHealthState "System Board 1 Fans" "fanredundancy"
  #SaveSensorHealthState "Power Supply 3 Power Supplies" "powerredundancy"

  #SaveSensorHealthState "Power Supply 2 Power Supply 2: Failure status" "ps2status"
 # SaveSensorHealthState "Power Supply 1 Power Supply 1: Failure status" "ps1status"
  
  }

Set-PowerCLIConfiguration -InvalidCertificateAction "Ignore" -Confirm:$false | out-null
Connect-VIServer -Server $vmware_host -User $vmware_userid -Password $vmware_password | out-null

$HostInfo = Get-VMHost
$HostView = $HostInfo | Get-View
 
"Hostname: " + $HostView.Name
"Overall Status: " + $HostView.OverallStatus
"Manufacturer: " + $HostInfo.Manufacturer
"Model: " + $HostInfo.Model
"Number of CPUs: " + $HostInfo.NumCpu
"Total CPU Mhz: " + $HostInfo.CpuTotalMhz
"CPU Usage: " + $HostInfo.CpuUsageMhz
"Total Memory: " + [Math]::Round($HostInfo.MemoryTotalMB/1024,2)
"Memory Usage: " + [Math]::Round($HostInfo.MemoryUsageMB/1024,2)

$HealthStatusSystem = Get-View $HostView.ConfigManager.HealthStatusSystem
$SystemHealthInfo = $HealthStatusSystem.Runtime.SystemHealthInfo
$sensors = new-object System.Collections.Hashtable

Disconnect-VIServer -Force -Confirm:$false | out-null

if ($test) {
$SystemHealthInfo.NumericSensorInfo
  }


foreach ($s in $SystemHealthInfo.NumericSensorInfo)  {
  # ignore the software components
  # create a key which is everything before the first ' -'
  $pos = $s.Name.IndexOf(" -")
  if ($pos -lt 0) {
    $mykey = $s.Name }
  else {
    $mykey = $s.Name.Substring(0,$pos).TrimEnd(" ")
    }
  if ($sensors.ContainsKey($mykey)) {
    write-host "Duplicate:" $mykey
    }
  if (($s.SensorType -ne "Software Components") -and ($sensors.ContainsKey($mykey) -eq $false)) {
    $sensors.add($mykey,$s)
    }
  }

#SaveSensorHealthState "VMware Rollup Health State" "rolluphealth"

switch ($HostInfo.Model) {
    "PowerEdge R720"    { Custom_PowerEdgeR720 }
    "PowerEdge R710"    { Custom_PowerEdgeR710 }
    "PowerEdge R910"    { Custom_PowerEdgeR910 }
    "PowerEdge 2900"    { Custom_PowerEdge2900 }
    "PowerEdge 2950"    { Custom_PowerEdge2950 }
    "ProLiant DL360 G5" { Custom_ProLiant_DL360_G5 }
    default { write-host "Missing model info for: " $HostInfo.Model }
  }

# --- all done!
