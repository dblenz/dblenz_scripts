$hostname = PowerShell.exe {
    function Validate_Hostname($hostname){
        try {
            [System.Net.DNS]::GetHostByName($hostname).HostName
            }
        catch [System.Exception] {
            #write-host $_.Exception.GetType().FullName; 
            $_.Exception.Message
            }
    }
     
    $hostname = "\`d.T.~Ed/{0497A831-DC03-4BB0-891D-A468FDBA333E}.{A73AE281-6EA9-41C8-A416-2F97ACE15ED8}\`d.T.~Ed/"
    $token = "taken"
    $i = 1

    Do {


		host1 = Validate_HostName($hostname)
        $cysemiresult = $host1 -eq $hostname + ".cysemi.com"
        $spsnresult = $host1 -eq $hostname + ".spansion.com"

        if ($cysemiresult -or $spsnresult) {
            #$token = "avaliable"
            $hostname = $hostname -replace ".$"
            $hostname = $hostname += $i.toString()
            $i ++
        }

        else {
            $token = "avaliable"
            #$hostname = $hostname -replace ".$"
            #$hostname = $hostname += $i.toString()
            #$i ++
        }

    } while ($token -eq "taken")

    $hostname
}