Param(
$Option,
$Command
     )
function RunningServices
{
Get-Service | Where-Object Status -eq 'Running'
}
function StartService
{
Start-Service $Command
}
function StopService
{
Stop-Service $Command
}
function RestartService
{
Restart-Service $Command
}
switch($Option)
{
r {RunningServices}
s {StartService}
ss{StopService}
rr{RestartService}
h{Write-Output "r to show all running services, s to start a specified service, ss to stop a specified service and rr to restart a specified service"}
default{Write-Output "Wrong parameter"}
}

