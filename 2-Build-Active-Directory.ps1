#--------------------------------------------------------------------------
#- Created by:             David Rodriguez                                -
#- Blog:                   www.sysadmintutorials.com                      -
#- Twitter:                @systutorials                                  -
#- Youtube:                https://www.youtube.com/user/sysadmintutorials -
#--------------------------------------------------------------------------

#-------------
#- Variables -                                         -
#-------------

# Active Directory Variables
$domainname = 'vlab.local'

#------------
#- Settings -
#------------

# Install Active Directory Services
Try{
    Add-WindowsFeature AD-Domain-Services -ErrorAction Stop
    Install-WindowsFeature RSAT-ADDS -ErrorAction Stop
    Write-Host "Active Directory Domain Services installed successfully" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to install Active Directory Domain Services. Error: "+ $_.Exception.Message)
     Break;
     }

# Configure Active Directory
Try{
    Install-ADDSForest -DomainName $domainname -InstallDNS -ErrorAction Stop -NoRebootOnCompletion
    Write-Host "Active Directory Domain Services have been configured successfully" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to configure Active Directory Domain Services. Error: "+ $_.Exception.Message)
     Break;
     }

# Reboot Computer to apply settings
Write-Host "Save all your work, computer rebooting in 30 seconds"
Sleep 30

Try{
    Restart-Computer -ComputerName $env:computername -ErrorAction Stop
    Write-Host "Rebooting Now!!" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to restart computer $($env:computername). Error: "+ $_.Exception.Message)
     Break;
     }
