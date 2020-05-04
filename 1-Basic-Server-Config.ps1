#--------------------------------------------------------------------------
#- Created by:             David Rodriguez                                -
#- Blog:                   www.sysadmintutorials.com                      -
#- Twitter:                @systutorials                                  -
#- Youtube:                https://www.youtube.com/user/sysadmintutorials -
#--------------------------------------------------------------------------

#-------------
#- Variables -                                         -
#-------------

# Network Variables
$ethalias = 'Ethernet0'
$ethipaddress = '192.168.1.222'
$ethprefixlength = '24'
$ethdefaultgw = '192.168.1.1'
$ethdns = '8.8.8.8' # for multiple DNS you can append DNS entries with comma's

# Remote Desktop Variable
$enablerdp = 'yes' # to enable RDP, set this variable to yes. to disable RDP, set this variable to no

# Disable IE Enhanced Security Configuration Variable
$disableiesecconfig = 'yes' # to disable IE Enhanced Security Configuration, set this variable to yes. to leave enabled, set this variable to no

# Hostname Variables
$computername = 'SERVERDC1'

#------------
#- Settings -
#------------

# Set Network
Try{
    New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $ethdefaultgw -InterfaceAlias $ethalias -ErrorAction Stop | Out-Null
    Set-DNSClientServerAddress -ServerAddresses $ethdns -InterfaceAlias $ethalias -ErrorAction Stop
    Write-Host "IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns)" -ForegroundColor Green
   }
Catch{
     Write-Warning -Message $("Failed to apply network settings. Error: "+ $_.Exception.Message)
     Break;
     }

# Set RDP
Try{
    IF ($enablerdp -eq "yes")
        {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -ErrorAction Stop
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
        Write-Host "RDP Successfully enabled" -ForegroundColor Green
        }
    }
Catch{
     Write-Warning -Message $("Failed to enable RDP. Error: "+ $_.Exception.Message)
     Break;
     }

IF ($enablerdp -ne "yes")
    {
    Write-Host "RDP remains disabled" -ForegroundColor Green
    }

# Disable IE Enhanced Security Configuration 
Try{
    IF ($disableiesecconfig -eq "yes")
        {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
        Write-Host "IE Enhanced Security Configuration successfully disabled for Admin and User" -ForegroundColor Green
        }
    }
Catch{
     Write-Warning -Message $("Failed to disable Ie Security Configuration. Error: "+ $_.Exception.Message)
     Break;
     }

If ($disableiesecconfig -ne "yes")
    {
    Write-Host "IE Enhanced Security Configuration remains enabled" -ForegroundColor Green
    }

# Set Hostname
Try{
    Rename-Computer -ComputerName $env:computername -NewName $computername -ErrorAction Stop
    Write-Host "Computer name set to $($computername)" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to set new computer name. Error: "+ $_.Exception.Message)
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
