<#Author       : Jean-Marc Pigeon
# Usage        : Install software for IQ AVD
#>

<# Script basé sur les scripts existant de Jonathan Pitre, modifié pour IQ
- synopsis : installation scripter pour IQ Software AVD
    custom image template
#>

#region psadt, Evergreen
Function Initialize-Module
{
    <#
    .SYNOPSIS
        Initialize-Module install and import modules from PowerShell Galllery.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Module
    )
    Write-Host -Object "Importing $Module module..." -ForegroundColor Green

    # If module is imported say that and do nothing
    If (Get-Module | Where-Object { $_.Name -eq $Module })
    {
        Write-Host -Object "Module $Module is already imported." -ForegroundColor Green
    }
    Else
    {
        # If module is not imported, but available on disk then import
        If ( [boolean](Get-Module -ListAvailable | Where-Object { $_.Name -eq $Module }) )

        {
            $InstalledModuleVersion = (Get-InstalledModule -Name $Module).Version
            $ModuleVersion = (Find-Module -Name $Module).Version
            $ModulePath = (Get-InstalledModule -Name $Module).InstalledLocation
            $ModulePath = (Get-Item -Path $ModulePath).Parent.FullName
            If ([version]$ModuleVersion -gt [version]$InstalledModuleVersion)
            {
                Update-Module -Name $Module -Force
                Remove-Item -Path $ModulePath\$InstalledModuleVersion -Force -Recurse
                Write-Host -Object "Module $Module was updated." -ForegroundColor Green
            }
            Import-Module -Name $Module -Force -Global -DisableNameChecking
            Write-Host -Object "Module $Module was imported." -ForegroundColor Green
        }
        Else
        {
            # Install Nuget
            If (-not(Get-PackageProvider -ListAvailable -Name NuGet))
            {
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                Write-Host -Object "Package provider NuGet was installed." -ForegroundColor Green
            }

            # Add the Powershell Gallery as trusted repository
            If ((Get-PSRepository -Name "PSGallery").InstallationPolicy -eq "Untrusted")
            {
                Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
                Write-Host -Object "PowerShell Gallery is now a trusted repository." -ForegroundColor Green
            }

            # Update PowerShellGet
            $InstalledPSGetVersion = (Get-PackageProvider -Name PowerShellGet).Version
            $PSGetVersion = [version](Find-PackageProvider -Name PowerShellGet).Version
            If ($PSGetVersion -gt $InstalledPSGetVersion)
            {
                Install-PackageProvider -Name PowerShellGet -Force
                Write-Host -Object "PowerShellGet Gallery was updated." -ForegroundColor Green
            }

            # If module is not imported, not available on disk, but is in online gallery then install and import
            If (Find-Module -Name $Module | Where-Object { $_.Name -eq $Module })
            {
                # Install and import module
                Install-Module -Name $Module -AllowClobber -Force -Scope AllUsers
                Import-Module -Name $Module -Force -Global -DisableNameChecking
                Write-Host -Object "Module $Module was installed and imported." -ForegroundColor Green
            }
            Else
            {
                # If the module is not imported, not available and not in the online gallery then abort
                Write-Host -Object "Module $Module was not imported, not available and not in an online gallery, exiting." -ForegroundColor Red
                EXIT 1
            }
        }
    }
}

#endregion
$Modules = @("PSADT", "Evergreen") # Modules list

Foreach ($Module in $Modules)
{
    Initialize-Module -Module $Module
}

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

######################################### test ###############################
function add-software{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$namesoftware,
        [string]$appArchitecture,
        [string]$appType
    )
    $LocalWVDpath            = "c:\IQ\"

    $evergreen = Get-EvergreenApp -Name $namesoftware | Where-Object { $_.Architecture -eq $appArchitecture -and $_.Type -eq $appType }
    $appURL = $Evergreen.URI
    $appSetup = "c:\IQ\"+ (Split-Path -Path $appURL -Leaf)
    Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appSetup
    return $appSetup
}

########## Execution ########

#############################
$filename = add-software -namesoftware "NotepadPlusPLus" -appArchitecture "x64" -appType "exe"
$appInstallParameters = "/S"
Write-Host "AVD AIB Customization - Install $filename : Starting to install notepad++"    
$fslogix_deploy_status = Start-Process `
    -FilePath "$filename" `
    -ArgumentList "$appInstallParameters" `
    -Wait `
    -Passthru

$filename = add-software -namesoftware "microsoftpowershell" -appArchitecture "x64" -appType "msi"
#Install powershell silently
Write-Host "AVD AIB Customization - Install Powershell 7 : Starting to install powershell 7"
$fslogix_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/package $($filename) /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1" `
    -Wait
 