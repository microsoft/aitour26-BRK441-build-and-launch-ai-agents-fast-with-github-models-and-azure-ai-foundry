Write-Host "Deploying the Azure resources..."

# Define resource group parameters
$RG_LOCATION = "westus"
$AI_PROJECT_FRIENDLY_NAME = "Zava DIY Agent Service Workshop"

# Deploy the Azure resources and save output to JSON
$deploymentName = "azure-ai-agent-service-lab-$(Get-Date -Format 'yyyyMMddHHmmss')"
az deployment sub create `
  --name "$deploymentName" `
  --location "$RG_LOCATION" `
  --template-file main.bicep `
  --parameters "@main.parameters.json" `
  --parameters location="$RG_LOCATION" | Out-File -FilePath output.json -Encoding utf8

# Parse the JSON file using native PowerShell cmdlets
if (-not (Test-Path -Path output.json)) {
    Write-Host "Error: output.json not found."
    exit -1
}

$jsonData = Get-Content output.json -Raw | ConvertFrom-Json
$outputs = $jsonData.properties.outputs

# Extract values from the JSON object
$projectsEndpoint = $outputs.projectsEndpoint.value
$resourceGroupName = $outputs.resourceGroupName.value
$subscriptionId = $outputs.subscriptionId.value
$aiAccountName = $outputs.aiAccountName.value
$aiProjectName = $outputs.aiProjectName.value
$azureOpenAIEndpoint = $projectsEndpoint -replace 'api/projects/.*$', ''
$applicationInsightsConnectionString = $outputs.applicationInsightsConnectionString.value
$applicationInsightsName = $outputs.applicationInsightsName.value

if ([string]::IsNullOrEmpty($projectsEndpoint)) {
    Write-Host "Error: projectsEndpoint not found. Possible deployment failure."
    exit -1
}

# Set the path for the .env file
$ENV_FILE_PATH = "../src/python/workshop/.env"

# Create workshop directory if it doesn't exist
$workshopDir = Split-Path -Parent $ENV_FILE_PATH
if (-not (Test-Path $workshopDir)) {
    New-Item -ItemType Directory -Path $workshopDir -Force
}

# Delete the file if it exists
if (Test-Path $ENV_FILE_PATH) {
    Remove-Item -Path $ENV_FILE_PATH -Force
}

# Create a new workshop .env file and write to it
@"
PROJECT_ENDPOINT=$projectsEndpoint
GPT_MODEL_DEPLOYMENT_NAME="gpt-4o-mini"
EMBEDDING_MODEL_DEPLOYMENT_NAME="text-embedding-3-small"
APPLICATIONINSIGHTS_CONNECTION_STRING="$applicationInsightsConnectionString"
"@ | Set-Content -Path $ENV_FILE_PATH

# Update the root .env file with Azure OpenAI endpoint
$ROOT_ENV_FILE_PATH = "../.env"
if (Test-Path $ROOT_ENV_FILE_PATH) {
    # Read existing content
    $envContent = Get-Content $ROOT_ENV_FILE_PATH
    $updatedContent = @()
    $azureEndpointUpdated = $false
    $projectEndpointUpdated = $false
    $appInsightsUpdated = $false
    
    foreach ($line in $envContent) {
        if ($line -match '^AZURE_OPENAI_ENDPOINT=') {
            $updatedContent += "AZURE_OPENAI_ENDPOINT=`"$azureOpenAIEndpoint`""
            $azureEndpointUpdated = $true
        }
        elseif ($line -match '^PROJECT_ENDPOINT=') {
            $updatedContent += "PROJECT_ENDPOINT=`"$projectsEndpoint`""
            $projectEndpointUpdated = $true
        }
        elseif ($line -match '^APPLICATIONINSIGHTS_CONNECTION_STRING=') {
            $updatedContent += "APPLICATIONINSIGHTS_CONNECTION_STRING=`"$applicationInsightsConnectionString`""
            $appInsightsUpdated = $true
        }
        else {
            $updatedContent += $line
        }
    }
    
    # Add missing entries
    if (-not $azureEndpointUpdated) {
        $updatedContent += "AZURE_OPENAI_ENDPOINT=`"$azureOpenAIEndpoint`""
    }
    if (-not $projectEndpointUpdated) {
        $updatedContent += "PROJECT_ENDPOINT=`"$projectsEndpoint`""
    }
    if (-not $appInsightsUpdated) {
        $updatedContent += "APPLICATIONINSIGHTS_CONNECTION_STRING=`"$applicationInsightsConnectionString`""
    }
    
    # Write updated content back to file
    $updatedContent | Set-Content -Path $ROOT_ENV_FILE_PATH
}
else {
    # Create new root .env file if it doesn't exist
    @"
AZURE_OPENAI_ENDPOINT="$azureOpenAIEndpoint"
PROJECT_ENDPOINT="$projectsEndpoint"
GPT_MODEL_DEPLOYMENT_NAME="gpt-4o-mini"
EMBEDDING_MODEL_DEPLOYMENT_NAME="text-embedding-3-small"
APPLICATIONINSIGHTS_CONNECTION_STRING="$applicationInsightsConnectionString"
"@ | Set-Content -Path $ROOT_ENV_FILE_PATH
}

# Set the C# project path
$CSHARP_PROJECT_PATH = "../src/csharp/workshop/AgentWorkshop.Client/AgentWorkshop.Client.csproj"

# Set the user secrets for the C# project (if the project exists)
if (Test-Path $CSHARP_PROJECT_PATH) {
    dotnet user-secrets set "ConnectionStrings:AiAgentService" "$projectsEndpoint" --project "$CSHARP_PROJECT_PATH"
    dotnet user-secrets set "Azure:ModelName" "gpt-4o-mini" --project "$CSHARP_PROJECT_PATH"
}

# Delete the output.json file
Remove-Item -Path output.json -Force

Write-Host "Adding Azure AI Developer user role"

# Set Variables
$subId = az account show --query id --output tsv
$objectId = az ad signed-in-user show --query id -o tsv

Write-Host "Ensuring Azure AI Developer role assignment..."

# Try to create the role assignment and capture the result
try {
    $roleResult = az role assignment create --role "f6c7c914-8db3-469d-8ca1-694a8f32e121" `
                            --assignee-object-id "$objectId" `
                            --scope "subscriptions/$subId/resourceGroups/$resourceGroupName" `
                            --assignee-principal-type 'User' 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Azure AI Developer role assignment created successfully." -ForegroundColor Green
    }
    else {
        # Check if the error is about existing role assignment
        $errorOutput = $roleResult -join " "
        if ($errorOutput -match "RoleAssignmentExists|already exists") {
            Write-Host "✅ Azure AI Developer role assignment already exists." -ForegroundColor Green
        }
        else {
            Write-Host "❌ User role assignment failed with unexpected error:" -ForegroundColor Red
            Write-Host $errorOutput -ForegroundColor Red
            exit 1
        }
    }
}
catch {
    # Handle any PowerShell exceptions
    $errorMessage = $_.Exception.Message
    if ($errorMessage -match "RoleAssignmentExists|already exists") {
        Write-Host "✅ Azure AI Developer role assignment already exists." -ForegroundColor Green
    }
    else {
        Write-Host "❌ User role assignment failed: $errorMessage" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resource Information:" -ForegroundColor Cyan
Write-Host "  Resource Group: $resourceGroupName"
Write-Host "  AI Project: $aiProjectName"
Write-Host "  Application Insights: $applicationInsightsName"
Write-Host ""
