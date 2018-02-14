Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName LCMRebootNodeIfNeeded

    Node $AllNodes.NodeName
    {
        LCMRebootNodeIfNeeded DisableAutoReboot
        {
            RebootNodeIfNeeded = $false
            TaskName           = 'LCM_RebootNodeIfNeeded_to_False'
        }
    }
}