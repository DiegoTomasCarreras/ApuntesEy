$Directory =Read-Host -Prompt "Input directory"
cd $Directory
$files = (ls -n) -split "`n"
$aux
Get-ChildItem | Where-Object {$_.Name -match 'log' -and !$_.Name.EndsWith(".log")  } | Rename-Item -NewName {$_.Name + ".log"}
<#
Foreach($file in $files)
{
if($file -like '*log*')
{
$aux=$Directory + "\" + $file
Write-Output $aux
Write-Output "Reconoci el archivo $file"
Rename-Item -Path "$aux" -NewName {$_.name+ ".log"}
Write-Output $file "Renamed"
}
}#>
