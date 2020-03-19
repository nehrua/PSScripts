
function Run-ExeOrMsi
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $SourcePath,
    
        [Parameter(Mandatory=$true)]
        [String[]]
        $Executables
    )

    # Disable UAC
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

    # Create staging dir
    $stagingDir = $env:SystemDrive +'\TEMPINSTALL'
    $path = Test-Path $stagingDir

    if (!(Test-Path $stagingDir))
    {
        New-Item -Path $stagingDir -ItemType Directory 
    }
    else
    {
        Write-Warning "Cannot continue because $stagingDir exists. Delete this dir and re-run"
        Exit
    }

    # Retrieve binaries and copy them to staging
    if (Test-Path $SourcePath)
    {
        try
        {
            foreach ($Executable in $Executables)
            {
                $file = $SourcePath + '\' + $Executable
                Copy-Item -Path $file $stagingDir -ErrorAction Stop                
                
                $installFile = $stagingDir + '\' + $Executable
                dir $installFile | Unblock-File
                
                if ($Executable -match 'java')
                {
                    Start-Process "$installFile" -ArgumentList /s -Wait 
                }
                elseif ($Executable -match 'chrome')
                {
                    Start-Process "$installFile" -ArgumentList /quiet -Wait
                }
                else
                {
                    Start-Process "$installFile" -ArgumentList /silent -Wait
                }
            }
        }
        catch
        {
            Write-Warning "Install failed, verify that $Executable exists"
        }
    }
    else 
    {
        Write-Warning "$SourcePath is invalid"
    }

    # Cleanup
    Remove-Item $stagingDir -Recurse -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
}

$params = @{
    Sourcepath  = '<enter source path>'
    Executables = @('JavaSetup8u231.exe','DoS_AdobeReader(17.011.30156).EXE','GoogleChromeStandaloneEnterprise64.msi')
}

Run-ExeOrMsi @params


