#Requires -RunAsAdministrator
#Requires -Version 5.1

<#PSScriptInfo

.VERSION 3.2.0

.GUID 35eb535b-7e54-4412-a58b-8a0c588c0b30

.AUTHOR Gavin Eke @GavinEke

.COMPANYNAME 

.COPYRIGHT 

.TAGS TronNG

.LICENSEURI 

.PROJECTURI https://github.com/GavinEke/TronNG

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.DESCRIPTION 
 Performs a collection of tasks that should speed-up a computers performance. 

#>

$VerbosePreference = 'Continue'
$LogFile = "$env:LOCALAPPDATA\TronNG\TronNG.log"

If (-not (Test-Path -Path $LogFile)) {
	New-Item -Path $($LogFile | Split-Path -Parent) -ItemType Directory -ErrorAction SilentlyContinue
	New-Item -Path $($LogFile | Split-Path -Parent) -Name $($LogFile | Split-Path -Leaf) -ItemType File -ErrorAction SilentlyContinue
	Write-Output 'TronNG Log' | Out-File -FilePath $LogFile
}
Write-Output "Start of TronNG - $(Get-Date)" | Tee-Object -FilePath $LogFile -Append

If ([Environment]::OSVersion.Version.Major -eq 10) {
	#Prerequisite Check
	# Step 0 - Create Checkpoint
	If (-not ($args.Contains('-SkipStep0'))) {
		Write-Output -InputObject 'Step 0 - Create Checkpoint' | Tee-Object -FilePath $LogFile -Append
		Checkpoint-Computer -Description 'TronNG' -ErrorAction SilentlyContinue
	}
	
	# Step 1 - Update
	If (-not ($args.Contains('-SkipStep1'))) {
		Write-Output -InputObject 'Step 1 - Update' | Tee-Object -FilePath $LogFile -Append
		UsoClient.exe ScanInstallWait
	}
	
	# Step 2 - Virus Scan
	If (-not ($args.Contains('-SkipStep2'))) {
		Write-Output -InputObject 'Step 2 - Virus Scan' | Tee-Object -FilePath $LogFile -Append
		Update-MpSignature -ErrorAction SilentlyContinue
		Start-MpScan -ErrorAction SilentlyContinue
	}
	
	# Step 3 - Clean-up
	If (-not ($args.Contains('-SkipStep3'))) {
		Write-Output -InputObject 'Step 3 - Clean-up' | Tee-Object -FilePath $LogFile -Append
		Remove-Item "$env:temp\*" -Recurse -ErrorAction SilentlyContinue | Tee-Object -FilePath $LogFile -Append
		Remove-Item "$env:tmp\*" -Recurse -ErrorAction SilentlyContinue | Tee-Object -FilePath $LogFile -Append
		Clear-RecycleBin -Confirm:$False
	}
	
	# Step 4 - Repair
	If (-not ($args.Contains('-SkipStep4'))) {
		Write-Output -InputObject 'Step 4 - Repair' | Tee-Object -FilePath $LogFile -Append
		Repair-Volume -DriveLetter C –Scan
	}
	
	# Step 5 - Defrag
	If (-not ($args.Contains('-SkipStep5'))) {
		Write-Output -InputObject 'Step 5 - Defrag' | Tee-Object -FilePath $LogFile -Append
		$IsSSD = Get-Disk | Where-Object Model -match 'ssd'
		If (-not ($IsSSD)) { #SSD Check
			Optimize-Volume -DriveLetter C -Defrag
		}
	}
	
	# Step 6 - Drive Health Check
	If (-not ($args.Contains('-SkipStep6'))) {
		Write-Output -InputObject 'Step 6 - Drive Health Check' | Tee-Object -FilePath $LogFile -Append
		If ((Get-Disk).HealthStatus -ne 'Healthy') { #Failing Drive Check
			Write-Output 'A hard drive in this computer might be failing, it is suggested you investigate all connected hard drives.' | Tee-Object -FilePath $LogFile -Append
		}
	}
} Else {
	Write-Error 'Prerequisite Check Failed - This script can only be run on Windows 10 in an elevated shell' | Tee-Object -FilePath $LogFile -Append
}

Write-Output "End of TronNG - $(Get-Date)" | Tee-Object -FilePath $LogFile -Append
Write-Output '---------------------------' | Tee-Object -FilePath $LogFile -Append
