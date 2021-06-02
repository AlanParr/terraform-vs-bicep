param appname string = 'testapp'
param environment string = 'staging'
param region string = 'ukwest'

targetScope = 'subscription'

resource sa 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-${appname}-${environment}'
  location: region
}

module res './resources.bicep' = {
  name: 'resourceDeploy'
  params: {
    appname: appname
    environment: environment
  }
  scope: resourceGroup(sa.name)
}
