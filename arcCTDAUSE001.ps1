#Variables imagen linux
$vmImg="$($vmPublisherName):$($vmOffer):$($vmSku):$($vmVersion)" #Imagen linux
$vmOffer = "UbuntuServer"
$vmSku = "18.04-LTS"
$vmVersion = "latest"
$vmPublisherName = "Canonical"
$vmName = "WebServerLin"
#Variables globales VM
$vmSize = "Standard_DS2_v2"
#Variables USA
$rgName = "CTDAUSE001"
$location = "eastus"
$subnetName = "subnetNameTest"
$subnetAdressPrefix = "192.168.0.0/24"
$vnetName = "IAASVNTUSE"
$vnetAdressPrefix = "192.168.0.0/24"
$nsgName = "PAASNSGUSEdiego"
$kvName = "PAASKVUSEdiego"
$rsvName = "IAASVNTBCKPUKSdiego"
$vmIpName = "PAASLINUSE"
$b1Name = "staging"
$b2Name = "production"
$sqlName = "PAASSQLUSEdiego"
$databaseName = "datadiego"
$saName = "strgtestlab001diego"
#Variables UK
$ukRgName = "CTDAUKS001"
$ukLocation = "uksouth"
$ukVmName1 = "WebServerLin"
$ukVmName2 = "serverdwin"
$ukRsvName = "IAASVNTBCKPUKS"
$ukKvName = "IAASVNTKVTUKSd"
$ukSubName1 = "SubLinux"
$ukSubName2 = "SubWin"
$ukSubRange1 = "10.10.0.0/25"
$ukSubRange2 = "10.100.0.0/25"
$ukNsgName = "IAASNSGUKS"
$ukVnetName = "IAASVNTUKS"
$ukCidrRange = "10.0.0.0/8"
$ukVm2Name="WSWin"
$ukVm2Publisher="MicrosoftWindowsServer"
$ukVm2Offer="WindowsServer"
$ukVm2Sku="2019-Datacenter"
$ukVm2Version="latest"
$ukVm2Img="$($ukVm2Publisher):$($ukVm2Offer):$($ukVm2Sku):$($ukVm2Version)"
#Commands

#Connects to azure
#Connect-AzAccount

#Creates a resource group
New-AzResourceGroup -Name $rgName -Location $location
New-AzResourceGroup -Name $ukRgName -Location $ukLocation 

#Gets credentials

$cred = Get-Credential -Message "Enter a username and password for the virtual machine" #// La contra tendria que ser algo generado random
#New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

#Gets subnet configuration
$subnetconfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAdressPrefix
$ukSubnetconfig = New-AzVirtualNetworkSubnetConfig -Name $ukSubName1 -AddressPrefix $ukSubRange1
$ukSubnetconfig2 = New-AzVirtualNetworkSubnetConfig -Name $ukSubName2 -AddressPrefix $ukSubRange2
#Creates a virtual network
$virtualnetwork =  New-AzVirtualNetwork -ResourceGroupName $rgName -Location $location -Name $vnetName -AddressPrefix $vnetAdressPrefix -Subnet $subnetconfig
$ukVirtualnetwork = New-AzVirtualNetwork -ResourceGroupName $ukRgName -Location $ukLocation -Name $ukVnetName -AddressPrefix $ukCidrRange -Subnet $ukSubnetconfig,$ukSubnetconfig2

#Creates a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgName -Location $location -Name $nsgName
$ukNsg = New-AzNetworkSecurityGroup -ResourceGroupName $ukRgName -Location $ukLocation -Name $ukNsgName
#Create virtual machine
New-AzVm -ResourceGroupName $rgName -Location $location -Credential $cred -Name $vmName -VirtualNetworkName $virtualnetwork.Name -SubnetName $subnetName -SecurityGroupName $nsgName -Image $vmImg -Size $vmSize
New-AzVm -ResourceGroupName $ukRgName -Location $ukLocation -Credential $cred -Name $ukVmName1 -VirtualNetworkName $ukVirtualnetwork.Name -SubnetName $ukSubName1 -SecurityGroupName $ukNsgName -Image $vmImg -Size $vmSize
New-AzVm -ResourceGroupName $ukRgName -Location $ukLocation -Credential $cred -Name $ukVmName2 -VirtualNetworkName $ukVirtualnetwork.Name -SubnetName $ukSubName2 -SecurityGroupName $ukNsgName -Image $ukVm2Img -Size $vmSize
#Create keyvault
$keyVault = New-AzKeyVault -Name $kvName -ResourceGroupName $rgName -Location $location 
$ukKeyVault = New-AzKeyVault -Name $ukKvName -ResourceGroupName $ukRgName -Location $ukLocation
#Agregando un secreto
Set-AzKeyVaultSecret -VaultName $kvName -Name $cred.UserName -SecretValue $cred.Password
Set-AzKeyVaultSecret -VaultName $ukKvName -Name $cred.UserName -SecretValue $cred.Password


$rsv = New-AzRecoveryServicesVault -Name $rsvName -ResourceGroupName $rgName -Location $location
$ukRsv = New-AzRecoveryServicesVault -Name $ukRsvName -ResourceGroupName $ukRgName -Location $ukLocation


#Set RSV's context, no se bien para que es #Set backup policy #Enable backups for the VM // Esto se podria hacer con una lista y un for mucho mas facil
Set-AzRecoveryServicesVaultContext -Vault $rsv
$bp=Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $rgName -Name $vmName -Policy $bp

Set-AzRecoveryServicesVaultContext -Vault $ukRsv
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $ukRgName -Name $ukVmName1 -Policy $bp #si esto falla probar hacer una segunda $bp
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $ukRgName -Name $ukVmName2 -Policy $bp
## Backup VMs
$container=Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName $vmName
$item=Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item

$container=Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName $ukVmName1
$item=Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item

$container=Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName $ukVmName2
$item=Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item
## Create Azure SQL Server
$sql1=New-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlName.ToLower() -Location $location -SqlAdministratorCredentials $cred

## Create Azure SQL Database
$database1=New-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlName.ToLower() -DatabaseName $databaseName

## Create Storage Account
$sa1=New-AzStorageAccount -ResourceGroupName $rgName -AccountName $saName.ToLower() -Location $location -Kind BlobStorage -SkuName Standard_LRS -AccessTier Cool

## Create Blob Containers
$container1=New-AzStorageContainer -Name $b1Name -Context $sa1.Context
$container2=New-AzStorageContainer -Name $b2Name -Context $sa1.Context
#create peering
Add-AzVirtualNetworkPeering -Name "ustouk" -VirtualNetwork $virtualnetwork -RemoteVirtualNetworkId $ukVirtualnetwork.Id
Add-AzVirtualNetworkPeering -Name "uktous" -VirtualNetwork $ukVirtualnetwork -RemoteVirtualNetworkId $virtualnetwork.Id
