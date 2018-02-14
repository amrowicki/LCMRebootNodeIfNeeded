# LCMRebootNodeIfNeeded
DSC module to manage RebootNodeIfNeeded parameter in Local Configuration Manager 

## Overview ##
The **LCMRebootNodeIfNeeded** is class-based module containing one resource:
- **LCMRebootNodeIfNeeded**: Used to change RebootNodeIfNeeded parameter in Local Configuration Manager

This resource creates a scheduled task that sets the desired parameter value. The task is run after occurrence of event 4115 from the Desired State Configuration source in the Microsoft-Windows-Desired State Configuration/Operational log.
The task is automatically deleted after setting the desired value.

### RebootNodeIfNeeded ###
*Note: This is a required parameter*
The new desired value of the RebootNodeIfNeeded parameter

### TaskName ###
*Note: This is a required parameter*
The name of the scheduled task used to set the desired value

#### Examples

* [Disable Auto Reboot](https://github.com/amrowicki/LCMRebootNodeIfNeeded/blob/master/Examples/1-DisableAutoReboot.ps1)
* [Enable Auto Reboot](https://github.com/amrowicki/LCMRebootNodeIfNeeded/blob/master/Examples/2-EnableAutoReboot.ps1)