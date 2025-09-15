targetScope = 'subscription'

// Parameters
@description('Prefix for the resource group and resources')
param resourcePrefix string = 'zava-agent-workshop'

@description('Location of the resource group to create or use for the deployment')
param location string = 'eastus'

@description('Friendly name for your Azure AI resource')
param aiProjectFriendlyName string = 'Agents standard project resource'

@description('Description of your Azure AI resource displayed in Azure AI Foundry')
param aiProjectDescription string = 'A standard project resource required for the agent setup.'

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Array of models to deploy')
param models array = [
  {
    name: 'gpt-4o-mini'
    format: 'OpenAI'
    version: '2024-07-18'
    skuName: 'GlobalStandard'
    capacity: 140
  }
  {
    name: 'text-embedding-3-small'
    format: 'OpenAI'
    version: '1'
    skuName: 'GlobalStandard'
    capacity: 120
  }
]

@description('Unique suffix for the resources')
@maxLength(4)
@minLength(0)
param uniqueSuffix string = substring(uniqueString(subscription().id, resourcePrefix), 0, 4)

var resourceGroupName = toLower('rg-${resourcePrefix}-${uniqueSuffix}')

var defaultTags = {
  source: 'Azure AI Foundry Agents Service lab'
}

var rootTags = union(defaultTags, tags)

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
}

// Calculate the unique suffix
var aiProjectName = toLower('project-${uniqueSuffix}')
var foundryResourceName = toLower('foundry-${uniqueSuffix}')
var applicationInsightsName = toLower('appi-${resourcePrefix}-${uniqueSuffix}')

module applicationInsights 'application-insights.bicep' = {
  name: 'application-insights-deployment'
  scope: rg
  params: {
    applicationInsightsName: applicationInsightsName
    location: location
    tags: rootTags
  }
}

module foundry 'foundry.bicep' = {
  name: 'foundry-account-deployment'
  scope: rg
  params: {
    aiProjectName: aiProjectName
    location: location
    tags: rootTags
    foundryResourceName: foundryResourceName
  }
}

module foundryProject 'foundry-project.bicep' = {
  name: 'foundry-project-deployment'
  scope: rg
  params: {
    foundryResourceName: foundry.outputs.accountName
    aiProjectName: aiProjectName
    aiProjectFriendlyName: aiProjectFriendlyName
    aiProjectDescription: aiProjectDescription
    location: location
    tags: rootTags
  }
}

@batchSize(1)
module foundryModelDeployments 'foundry-model-deployment.bicep' = [for (model, index) in models: {
  name: 'foundry-model-deployment-${model.name}-${index}'
  scope: rg
  dependsOn: [
    foundryProject
  ]
  params: {
    foundryResourceName: foundry.outputs.accountName
    modelName: model.name
    modelFormat: model.format
    modelVersion: model.version
    modelSkuName: model.skuName
    modelCapacity: model.capacity
    tags: rootTags
  }
}]

// Outputs
output subscriptionId string = subscription().subscriptionId
output resourceGroupName string = rg.name
output aiAccountName string = foundry.outputs.accountName
output aiProjectName string = foundryProject.outputs.aiProjectName
output projectsEndpoint string = '${foundry.outputs.endpoint}api/projects/${foundryProject.outputs.aiProjectName}'
output deployedModels array = [for (model, index) in models: {
  name: model.name
  deploymentName: foundryModelDeployments[index].outputs.modelDeploymentName
}]
output applicationInsightsName string = applicationInsights.outputs.applicationInsightsName
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey
