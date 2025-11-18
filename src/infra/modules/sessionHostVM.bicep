// Session Host VM Module
// Creates and configures an AVD session host VM

@description('The name prefix for the session host VM')
param vmNamePrefix string

@description('The index number for this session host')
param vmIndex int

@description('The location for the VM')
param location string

@description('The VM size')
param vmSize string = 'Standard_D2s_v5'

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('The subnet ID where the VM will be placed')
param subnetId string

@description('Host pool registration token')
@secure()
param hostPoolToken string

@description('Host pool name (passed directly instead of parsing token)')
param hostPoolName string

@description('Image reference object')
param imageReference object

@description('URI to VS Code installation script')
param vscodeInstallScriptUri string

@description('Tags to apply to resources')
param tags object = {}

// Construct VM name with zero-padded index
var vmName = '${vmNamePrefix}-${padLeft(vmIndex, 3, '0')}'
var nicName = '${vmName}-nic'
var osDiskName = '${vmName}-osdisk'

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

// AVD Agent Extension - registers VM to host pool
resource avdAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: 'Microsoft.PowerShell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_06-15-2022.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: hostPoolToken
        aadJoin: false
      }
    }
  }
}

// // VS Code Installation Extension - runs after AVD agent registration
// resource vscodeInstall 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
//   parent: vm
//   name: 'InstallVSCode'
//   location: location
//   dependsOn: [
//     avdAgent
//   ]
//   properties: {
//     publisher: 'Microsoft.Compute'
//     type: 'CustomScriptExtension'
//     typeHandlerVersion: '1.10'
//     autoUpgradeMinorVersion: true
//     settings: {
//       fileUris: [
//         vscodeInstallScriptUri
//       ]
//     }
//     protectedSettings: {
//       commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File install-vscode.ps1'
//     }
//   }
// }

@description('The resource ID of the VM')
output vmId string = vm.id

@description('The name of the VM')
output vmName string = vm.name
