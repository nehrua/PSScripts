<#
    .SYNOPSIS
        Used to add a log analytics workspace to an MMA configuration 
#>

param
(
    [parameter(Mandatory=$true)]
    [string]
    $WorkspaceId,
        
    [parameter(Mandatory=$true)]
    [string]
    $WorkspaceKey,

    [parameter()]
    [string]
    $ProxyUrl
) 

$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'

# check for workspace
if ($mma.GetCloudWorkspace($workspaceId).workspaceid -ne $workspaceId)
{
    $mma.AddCloudWorkspace($workspaceId, $workspaceKey, 1)
    $mma.ReloadConfiguration()
    $mma.GetCloudWorkspace($workspaceId).ConnectionStatusText
        
    if ($ProxyUrl)
    {
        $mma.SetProxyUrl($ProxyUrl)
    }

    Write-Verbose "Host $env:COMPUTERNAME is now configured for $workspaceId" -Verbose
}
else
{
    Write-Warning "Host $env:COMPUTERNAME already configured for $workspaceId"
}



