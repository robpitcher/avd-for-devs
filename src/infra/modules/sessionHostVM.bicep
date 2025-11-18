// Session Host VM Module
// Creates and configures an AVD session host VM using Azure Verified Modules

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

@description('Tags to apply to resources')
param tags object = {}

// Construct VM name with zero-padded index
var vmName = '${vmNamePrefix}-${padLeft(vmIndex, 3, '0')}'

// Deploy Virtual Machine using Azure Verified Module
module vm 'br/public:avm/res/compute/virtual-machine:0.20.0' = {
  name: '${vmName}-deployment'
  params: {
    name: vmName
    location: location
    tags: tags
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    availabilityZone: -1
    osType: 'Windows'
    imageReference: imageReference
    nicConfigurations: [
      {
        nicSuffix: '-nic'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnetId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      createOption: 'FromImage'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    licenseType: 'Windows_Client'
    patchMode: 'AutomaticByOS'
    enableAutomaticUpdates: true
    extensionDSCConfig: {
      enabled: true
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
}

@description('The resource ID of the VM')
output vmId string = vm.outputs.resourceId

@description('The name of the VM')
output vmName string = vm.outputs.name
