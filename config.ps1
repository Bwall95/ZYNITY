# Path to the config.json file
$configPath = "C:\app\config.json"

# Check if the configuration file exists
if (-Not (Test-Path $configPath)) {
    Write-Host "Configuration file not found at $configPath. Exiting..." -ForegroundColor Red
    #exit 1
}

# Load the JSON configuration file
$config = Get-Content $configPath | ConvertFrom-Json

# Extract configuration values
$containerName = $config.containerName
$imageName = $config.imageName
$CYBERSECURITY = $config.CYBERSECURITY
$UserName = $config.UserName
$Password = $config.Password

#Map to the CYBERSECURITY folder as drive Z
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

New-PSDrive -Name "Z" -PSProvider FileSystem -Root $CYBERSECURITY -Credential $credential
if (Test-Path -Path "Z:\") {
    Write-Host "PSDrive Z created successfully for CYBERSECURITY share."
} else { 
    Write-Host "Failed to create PSDrive Z, mapping to the CYBERSECURITY Share"
}
#Log Function
$date = Get-Date -Format "MM-dd-yyyy"

if (-not (Test-Path "Z:\EvalSTIG_Operational\Checklists\Logs\ZYNITY")) {
    Write-Host "Log directory was missing on the share, creating..."
    
    try {
        New-Item -Path "Z:\EvalSTIG_Operational\Checklists\Logs\ZYNITY" -ItemType Directory -ErrorAction Stop
        Write-Host "Log directory successfully created on the share."
    } catch {
        Write-Host "Failed to create the log directory on the share: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Log directory located on the share."
}

<#$logfile = "Z:\EvalSTIG_Operational\Checklists\Logs\ZYNITY\ConfigLog.$date.txt"
Function LogMsg ($Message, $TimeStamp = (Get-Date).ToString("yyyyMMdd HH:mm:ss")) {
    $Message = $Message.Replace("`n", "")
    $Line = "ZYNITY-Config: $TimeStamp - $Message"
    Add-Content -Path $Logfile -Value $Line
}#>

# Define the destination directory for production files inside the container
$SourceProduction = "Z:\Tools\Scripts\Eval-STIG\Production"
$Production = "C:\app\production"

# Check if the source production path exists
if (-Not (Test-Path $SourceProduction)) {
    #LogMsg "Source path $SourceProduction does not exist." -ForegroundColor Red
     Write-Host "Source path $SourceProduction does not exist."
    #exit 1
} else {
    Write-Host "Verified $($SourceProduction) Path. It contains the following items:"
    (Get-ChildItem -Path $SourceProduction) | ForEach-Object { Write-Host $_.Name } 
}

# Create the destination directory if it doesn't exist
if (-Not (Test-Path $Production)) {
    New-Item -Path $Production -ItemType Directory
    Write-Host "Local Production folder created"
    #LogMsg "Local Production folder created"
}

# Copy files from source to destination
#LogMsg "Copying files from $SourceProduction to $Production..."
Write-Host "Copying files from $SourceProduction to $Production..."
Copy-Item -Path "$SourceProduction\*" -Destination $Production -Recurse -Force

if ((Get-ChildItem -Path $Production).Count -gt 1) {
    Write-Host "Verified Local Production folder contains $((Get-ChildItem -Path $Production).Count) Items"

    Add-Content -Path "Z:\EvalSTIG_Operational\Checklists\Logs\ZYNITY\ConfigLog.$date.txt" -Value "Test"
}
#keep container alive for troubleshooting
Start-Sleep -Seconds 3600  # Or use an infinite loop if needed
#Check file structure

