[DscResource(RunAsCredential = 'NotSupported')]
class LCMRebootNodeIfNeeded
{
    [DscProperty(Key)]
    [string]$TaskName

    [DscProperty(Mandatory)]
    [bool]$RebootNodeIfNeeded

    [void] Set()
    {
        $ScheduledTaskCommand = Get-Content (Join-Path -Path $PSScriptRoot -ChildPath "ScheduledTask\ScheduledTaskCommand.ps1")
        $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$TaskName', $($this.TaskName))
        $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$RebootNodeIfNeeded', "`$$($this.RebootNodeIfNeeded)")

        if ($this.RebootNodeIfNeeded)
        {
            $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$OldValue', 'RebootNodeIfNeeded = False;')
            $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$NewValue', 'RebootNodeIfNeeded = True;')
        }
        else
        {
            $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$OldValue', 'RebootNodeIfNeeded = True;')
            $ScheduledTaskCommand = $ScheduledTaskCommand.Replace('$NewValue', 'RebootNodeIfNeeded = False;')
        }

        [xml]$scheduledTaskXML = Get-Content (Join-Path -Path $PSScriptRoot -ChildPath "ScheduledTask\ScheduledTask.xml")
        $scheduledTaskXML.Task.RegistrationInfo.Date = $(Get-Date -Format o).ToString()
        $scheduledTaskXML.Task.RegistrationInfo.Description = "Sets the RebootNodeIfNeeded parameter in Local Configuration Manager to $($this.RebootNodeIfNeeded)."
        $scheduledTaskXML.Task.Actions.Exec.Arguments = "-enc $([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScheduledTaskCommand)))"
    
        if (([Environment]::OSVersion.Version.Major -eq 6 -and [Environment]::OSVersion.Version.Minor -ge 2) -or ([Environment]::OSVersion.Version.Major -gt 6))
        {
            Register-ScheduledTask -Xml $scheduledTaskXML.OuterXml -TaskName $this.TaskName -Force
        }
        else
        {
            $fileName = [System.IO.Path]::GetTempFileName()
            $scheduledTaskXML | Out-File -FilePath $fileName
            Start-Process schtasks.exe -ArgumentList "/Create /XML $fileName /tn $($this.TaskName)" -NoNewWindow -Wait
            Remove-Item $fileName -Force
        }
    }
    
    [LCMRebootNodeIfNeeded] Get()
    {
        $this.RebootNodeIfNeeded = (Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration –ClassName MSFT_DSCLocalConfigurationManager –MethodName GetMetaConfiguration).MetaConfiguration.RebootNodeIfNeeded
        return $this
    }

    [bool] Test()
    {
        $currentRebootNodeIfNeeded = (Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration –ClassName MSFT_DSCLocalConfigurationManager –MethodName GetMetaConfiguration).MetaConfiguration.RebootNodeIfNeeded

        if (([Environment]::OSVersion.Version.Major -eq 6 -and [Environment]::OSVersion.Version.Minor -ge 2) -or ([Environment]::OSVersion.Version.Major -gt 6))
        {
            $task = Get-ScheduledTask -TaskName $this.TaskName -ErrorAction SilentlyContinue
        }
        else
        {
            $task = [xml](. schtasks.exe /Query /TN $this.TaskName /XML 2>$null)
        }
    
        if ($this.RebootNodeIfNeeded)
        {
            if ($currentRebootNodeIfNeeded -or ![string]::IsNullOrEmpty($task))
            {
                return $true
            }
            else
            {
                return $false
            }
        }
        else
        {
            if (!$currentRebootNodeIfNeeded -or ![string]::IsNullOrEmpty($task))
            {
                return $true
            }
            else
            {
                return $false
            }
        }
    }
}