
function Write-Log {
    param(
        [string]$Message
    )
     $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
     "$timestamp - $Message" | Out-File -FilePath \\iqpocstorage.file.core.windows.net\avdcustomimagetemplateslogs\avdcit.logs -Append
}

<#logs files#>

Write-Log "mounting z drive"

#Download notepad++
$Filename = "npp.8.6.8.Installer.x64.exe"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.8/npp.8.6.8.Installer.x64.exe" -OutFile $Filename
Write-Log "Download $Filename"
#Install notepad++
Start-Process $Filename -ArgumentList "/S" -Wait -PassThru
Write-Log "installation de $Filename"

#Remove install file
Remove-Item $Filename

#Download powershell
$Filename = "powershell7.msi"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi" -OutFile $Filename

#Install powershell silently
Start-Process msiexec.exe -Wait -ArgumentList "/package $($Filename) /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1"

#Remove install file
Remove-Item $Filename