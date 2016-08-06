#Requires -RunAsAdministrator
#Requires -Version 5

<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance. Windows 10 Only.
    .VERSION 
    3.0.0.0
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Gavin Eke @GavinEke
    .TAGS 
    TronNG
    .RELEASENOTES
    https://github.com/GavinEke/TronNG/blob/master/CHANGELOG.md
#>

$LogFile = "~\TronNG.log"
If (!(Test-Path -Path $LogFile)) {
    Write-Output "TronNG Log" | Out-File -FilePath $LogFile
}
Write-Output "Start of TronNG - $(Get-Date)" | Tee-Object -FilePath $LogFile -Append

If ([Environment]::OSVersion.Version.Major -eq 10) { #Prerequisite Check
    # Step 0 - Create Checkpoint
    If(!($args.Contains("-SkipStep0"))) {
        Write-Verbose "Step 0 - Create Checkpoint" | Tee-Object -FilePath $LogFile -Append
        Checkpoint-Computer -Description "TronNG" -ErrorAction SilentlyContinue
    }

    # Step 1 - Update
    If(!($args.Contains("-SkipStep1"))) {
        Write-Verbose "Step 1 - Update" | Tee-Object -FilePath $LogFile -Append
        (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
    }

    # Step 2 - Virus Scan
    If(!($args.Contains("-SkipStep2"))) {
        Write-Verbose "Step 2 - Virus Scan" | Tee-Object -FilePath $LogFile -Append
        Update-MpSignature
        Start-MpScan
    }

    # Step 3 - Clean-up
    If(!($args.Contains("-SkipStep3"))) {
        Write-Verbose "Step 3 - Clean-up" | Tee-Object -FilePath $LogFile -Append
        Remove-Item $env:temp\* -Recurse | Tee-Object -FilePath $LogFile -Append
        Clear-RecycleBin
    }

    # Step 4 - Repair
    If(!($args.Contains("-SkipStep4"))) {
        Write-Verbose "Step 4 - Repair" | Tee-Object -FilePath $LogFile -Append
        Repair-Volume -DriveLetter C –Scan
    }

    # Step 5 - Defrag
    If(!($args.Contains("-SkipStep5"))) {
        Write-Verbose "Step 5 - Defrag" | Tee-Object -FilePath $LogFile -Append
        $IsSSD = Get-Disk | Where-Object Model -match 'ssd'
        If ($IsSSD -eq $Null) { #SSD Check
            Optimize-Volume -DriveLetter C -Defrag
        }
    }

    # Step 6 - Drive Health Check
    If(!($args.Contains("-SkipStep6"))) {
        Write-Verbose "Step 6 - Drive Health Check" | Tee-Object -FilePath $LogFile -Append
        If ((Get-Disk).HealthStatus -ne 'Healthy') { #Failing Drive Check
            Write-Output "A hard drive in this computer might be failing, it is suggested you investigate all connected hard drives." | Tee-Object -FilePath $LogFile -Append
        }
    }
} Else {
    Write-Error "Prerequisite Check Failed - This script can only be run on Windows 10 in an elevated shell" | Tee-Object -FilePath $LogFile -Append
}

Write-Output "End of TronNG - $(Get-Date)" | Tee-Object -FilePath $LogFile -Append
Write-Output "---------------------------" | Tee-Object -FilePath $LogFile -Append
