<#Author       : Jean-Marc Pigeon
# Usage        : Install software for IQ AVD
#>


####################################
#    Test/Create Temp Directory    #
####################################
if((Test-Path c:\IQ) -eq $false) {
    Write-Host "AVD AIB Customization - Creating temp directory"
    New-Item -Path c:\IQ -ItemType Directory
}
else {
    Write-Host "AVD AIB Customization - c:\IQ already exists"
}

######################
#    WVD Variables   #
######################
$LocalWVDpath            = "c:\IQ\"
$FSInstaller             = 'npp.8.6.8.Installer.x64.exe'
$templateFilePathFolder = "C:\AVDImage"


#Download notepad++
$Filename = "npp.8.6.8.Installer.x64.exe"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.8/npp.8.6.8.Installer.x64.exe" -OutFile "$localwvdpath$Filename"

#Install notepad++
#########################
Write-Host "AVD AIB Customization - Install FSLogix : Starting to install notepad++"
$fslogix_deploy_status = Start-Process `
    -FilePath "$LocalWVDpath\$Filename" `
    -ArgumentList '/S' `
    -Wait `
    -Passthru


#Remove install file
#Remove-Item $Filename

#Download powershell
$Filename1 = "powershell7.msi"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi" -OutFile "$LocalWVDpath\$Filename"

#Install powershell silently
$fslogix_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/package $($Filename1) /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1" `
    -Wait
 

#Remove install file
#Remove-Item $Filename1