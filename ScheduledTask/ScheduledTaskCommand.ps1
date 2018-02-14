$configStatus = Get-DscConfigurationStatus
$currentLCM = Get-DscLocalConfigurationManager
if ($currentLCM.RebootNodeIfNeeded -ne $RebootNodeIfNeeded)
{
    if ($configStatus.Status -eq 'Success' -and $configStatus.Type -eq 'Consistency' -and $configStatus.Mode -eq 'Pull' -and $configStatus.RebootRequested -eq $false)
    {
        $LCMConfigFile = Get-Item $env:SystemRoot\system32\Configuration\MetaConfig.mof
        (Get-Content $LCMConfigFile -raw -Encoding Unicode).Replace('$OldValue', '$NewValue') | Set-Content $LCMConfigFile -NoNewline -Encoding Unicode
    }
}
else
{
    if (([Environment]::OSVersion.Version.Major -eq 6 -and [Environment]::OSVersion.Version.Minor -ge 2) -or ([Environment]::OSVersion.Version.Major -gt 6))
    {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    }
    else
    {
        Start-Process schtasks.exe -ArgumentList "/Delete /TN $TaskName /F" -NoNewWindow -ErrorAction SilentlyContinue
    }
}