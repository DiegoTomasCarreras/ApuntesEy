cd C:\Apuntes\Ejercicios\PowerShell\powershell-excercises\excercises\ex02\content_generator
Clear-Content applog.log
Start-Process -FilePath "ContentGenerator.exe"

$success= 0
$fails= 0
$demas=0
while ($success -lt 5)
{
Write-Output "EN EL WHILE"
$line = Get-Content applog.log -Wait|Where-Object { $_ -like "successful"}  
if($line -eq "failed")
{
Write-Output "1 falla"
    $fails += 1
}
elseif($line == "successful")
{
Write-Output "1 success"
    $success += 1
}
else {
Write-Output "1 demas"
    $demas+=1
}

}
Write-Output "Success: "  $success  "fails: "  $fails + "demas: "  $demas
Stop-Process -Name "ContentGenerator"
