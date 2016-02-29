Start-Transcript -Path ~\TronNG.log -Append
Write-Output "Start of TronNG - $(Get-Date)"

Function Test-Administrator {  
    $AdminUserTest = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $AdminUserTest).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

If ((Test-Administrator -eq $True) -and ([Environment]::OSVersion.Version.Major -eq 10)) { #Prerequisite Check
    # Step 0 - Create Checkpoint
    Write-Verbose "Step 0 - Create Checkpoint"
    Checkpoint-Computer -Description "TronNG"

    # Step 1 - Update
    Write-Verbose "Step 1 - Update"
    wuauclt.exe /detectnow /updatenow

    # Step 2 - Virus Scan
    Write-Verbose "Step 2 - Virus Scan"
    Update-MpSignature
    Start-MpScan

    # Step 3 - Clean-up
    Write-Verbose "Step 3 - Clean-up"
    Remove-Item $env:temp\* -Recurse
    Clear-RecycleBin

    # Step 4 - Repair
    Write-Verbose "Step 4 - Repair"
    Repair-Volume -DriveLetter C –Scan

    # Step 5 - Defrag
    Write-Verbose "Step 5 - Defrag"
    $IsSSD = Get-Disk | Where-Object Model -match 'ssd'
    If ($IsSSD -eq $Null) { #SSD Check
        Optimize-Volume -DriveLetter C -Defrag
    }

    # Step 6 - Drive Health Check
    Write-Verbose "Step 6 - Drive Health Check"
    If ((Get-Disk).HealthStatus -ne 'Healthy') { #Failing Drive Check
        Write-Output "A hard drive in this computer might be failing, it is suggested you investigate all connected hard drives."
    }
} Else {
    Write-Error "Prerequisite Check Failed - This script can only be run on Windows 10 in an elevated shell"
}

Write-Output "End of TronNG - $(Get-Date)"
Write-Output "---------------------------"
Stop-Transcript
