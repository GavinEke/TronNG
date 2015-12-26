# Step 1 - Update
wuauclt.exe /detectnow /updatenow

# Step 2 - Virus Scan
Update-MpSignature
Start-MpScan

# Step 3 - Clean-up
Remove-Item $env:temp\* -Recurse
Clear-RecycleBin

# Step 4 - Repair
Repair-Volume -DriveLetter C –Scan

# Step 5 - Defrag
Optimize-Volume -DriveLetter C -Defrag
