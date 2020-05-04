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

$globalsubnet = '192.168.1.0/24' # Global Subnet will be used in DNS Reverse Record and AD Sites and Services Subnet
$subnetlocation = 'Sydney'

# NTP Variables
$ntpserver1 = '0.au.pool.ntp.org'
$ntpserver2 = '1.au.pool.ntp.org'

#------------
#- Settings -
#------------

# Add DNS Reverse Record
Try{
    Add-DnsServerPrimaryZone -NetworkId $globalsubnet -DynamicUpdate Secure -ReplicationScope Domain -ErrorAction Stop
    Write-Host "Successfully added in $($globalsubnet) as a reverse lookup within DNS" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to create reverse DNS lookups zone for network $($globalsubnet). Error: "+ $_.Exception.Message)
     Break;
     }

# Add DNS Scavenging
Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -Verbose

Set-DnsServerZoneAging vlab.local -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose

Set-DnsServerZoneAging 1.168.192.in-addr.arpa -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose

Get-DnsServerScavenging

# Create Active Directory Sites and Services Subnet
Try{
    New-ADReplicationSubnet -Name $globalsubnet -Site "Default-First-Site-Name" -Location $subnetlocation -ErrorAction Stop
    Write-Host "Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services" -ForegroundColor Green
    }
Catch{
     Write-Warning -Message $("Failed to create Subnet $($globalsubnet) in AD Sites and Services. Error: "+ $_.Exception.Message)
     Break;
     }

# Add NTP settings to PDC

$serverpdc = Get-AdDomainController -Filter * | Where {$_.OperationMasterRoles -contains "PDCEmulator"}

IF ($serverpdc)
    {
    Try{
        Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList "/config /manualpeerlist:$($ntpserver1),$($ntpserver2) /syncfromflags:MANUAL /reliable:yes /update" -ErrorAction Stop
        Stop-Service w32time -ErrorAction Stop
        sleep 2
        Start-Service w32time -ErrorAction Stop
        Write-Host "Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2)" -ForegroundColor Green
        }
    Catch{
          Write-Warning -Message $("Failed to set NTP Servers. Error: "+ $_.Exception.Message)
     Break;
     }
    }