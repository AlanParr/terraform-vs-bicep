targetScope = 'resourceGroup'

param appname string
param environment string

//app insights
resource appin 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'appi-${appname}-${environment}'
  location: resourceGroup().location
  kind: 'Web'
}

//storage account
resource mainstorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sa${appname}${environment}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource appserviceplan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'plan-${appname}-${environment}'
  location: resourceGroup().location
  kind: 'Windows'

  sku: {
    tier: 'Free'
    size: 'F1'
  }
}

resource appservice 'Microsoft.Web/sites@2020-12-01' = {
  name: 'app-${appname}-${environment}'
  location: resourceGroup().location
  
  dependsOn: [
    appserviceplan
  ]

  properties: {
    serverFarmId: appserviceplan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'ApplicationInsights:InstrumentationKey'
          value: appin.properties.InstrumentationKey
        }
      ]
      ftpsState: 'Disabled'
      use32BitWorkerProcess: true
    }
  }

  identity: {
    type: 'SystemAssigned'
  }
}
