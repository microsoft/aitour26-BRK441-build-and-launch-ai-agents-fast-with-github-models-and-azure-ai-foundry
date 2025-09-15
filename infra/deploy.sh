#!/bin/bash

echo "Deploying the Azure resources..."

# Define resource group parameters
RG_LOCATION="westus"
AI_PROJECT_FRIENDLY_NAME="Zava Agent Service Workshop"

# Deploy the Azure resources and save output to JSON
echo "Starting Azure deployment..."
DEPLOYMENT_NAME="azure-ai-agent-service-lab-$(date +%Y%m%d%H%M%S)"
az deployment sub create \
  --name "$DEPLOYMENT_NAME" \
  --location "$RG_LOCATION" \
  --template-file main.bicep \
  --parameters @main.parameters.json \
  --parameters location="$RG_LOCATION" \
  --output json > output.json

# Check if deployment was successful
if [ $? -ne 0 ]; then
  echo "Deployment failed. Check output.json for details."
  exit 1
fi

# Parse the JSON file
if [ ! -f output.json ]; then
  echo "Error: output.json not found."
  exit 1
fi

PROJECTS_ENDPOINT=$(jq -r '.properties.outputs.projectsEndpoint.value' output.json)
RESOURCE_GROUP_NAME=$(jq -r '.properties.outputs.resourceGroupName.value' output.json)
SUBSCRIPTION_ID=$(jq -r '.properties.outputs.subscriptionId.value' output.json)
AI_SERVICE_NAME=$(jq -r '.properties.outputs.aiAccountName.value' output.json)
AI_PROJECT_NAME=$(jq -r '.properties.outputs.aiProjectName.value' output.json)
AZURE_OPENAI_ENDPOINT=$(jq -r '.properties.outputs.projectsEndpoint.value' output.json | sed 's|api/projects/.*||')
APPLICATIONINSIGHTS_CONNECTION_STRING=$(jq -r '.properties.outputs.applicationInsightsConnectionString.value' output.json)
APPLICATION_INSIGHTS_NAME=$(jq -r '.properties.outputs.applicationInsightsName.value' output.json)

if [ -z "$PROJECTS_ENDPOINT" ] || [ "$PROJECTS_ENDPOINT" = "null" ]; then
  echo "Error: projectsEndpoint not found. Possible deployment failure."
  exit 1
fi

ENV_FILE_PATH="../src/python/workshop/.env"

# Delete the file if it exists
[ -f "$ENV_FILE_PATH" ] && rm "$ENV_FILE_PATH"

# Create workshop directory if it doesn't exist
mkdir -p "$(dirname "$ENV_FILE_PATH")"

# Write to the workshop .env file
{
  echo "PROJECT_ENDPOINT=$PROJECTS_ENDPOINT"
  echo "GPT_MODEL_DEPLOYMENT_NAME=\"gpt-4o-mini\""
  echo "EMBEDDING_MODEL_DEPLOYMENT_NAME=\"text-embedding-3-small\""
  echo "APPLICATIONINSIGHTS_CONNECTION_STRING=\"$APPLICATIONINSIGHTS_CONNECTION_STRING\""
} > "$ENV_FILE_PATH"

# Update the root .env file with Azure OpenAI endpoint
ROOT_ENV_FILE_PATH="../.env"
if [ -f "$ROOT_ENV_FILE_PATH" ]; then
  # Update existing AZURE_OPENAI_ENDPOINT line or append if not found
  if grep -q "^AZURE_OPENAI_ENDPOINT=" "$ROOT_ENV_FILE_PATH"; then
    sed -i "s|^AZURE_OPENAI_ENDPOINT=.*|AZURE_OPENAI_ENDPOINT=\"$AZURE_OPENAI_ENDPOINT\"|" "$ROOT_ENV_FILE_PATH"
  else
    echo "AZURE_OPENAI_ENDPOINT=\"$AZURE_OPENAI_ENDPOINT\"" >> "$ROOT_ENV_FILE_PATH"
  fi
  # Update PROJECT_ENDPOINT as well
  if grep -q "^PROJECT_ENDPOINT=" "$ROOT_ENV_FILE_PATH"; then
    sed -i "s|^PROJECT_ENDPOINT=.*|PROJECT_ENDPOINT=\"$PROJECTS_ENDPOINT\"|" "$ROOT_ENV_FILE_PATH"
  else
    echo "PROJECT_ENDPOINT=\"$PROJECTS_ENDPOINT\"" >> "$ROOT_ENV_FILE_PATH"
  fi
  # Update APPLICATIONINSIGHTS_CONNECTION_STRING as well
  if grep -q "^APPLICATIONINSIGHTS_CONNECTION_STRING=" "$ROOT_ENV_FILE_PATH"; then
    sed -i "s|^APPLICATIONINSIGHTS_CONNECTION_STRING=.*|APPLICATIONINSIGHTS_CONNECTION_STRING=\"$APPLICATIONINSIGHTS_CONNECTION_STRING\"|" "$ROOT_ENV_FILE_PATH"
  else
    echo "APPLICATIONINSIGHTS_CONNECTION_STRING=\"$APPLICATIONINSIGHTS_CONNECTION_STRING\"" >> "$ROOT_ENV_FILE_PATH"
  fi
else
  # Create new root .env file if it doesn't exist
  {
    echo "AZURE_OPENAI_ENDPOINT=\"$AZURE_OPENAI_ENDPOINT\""
    echo "PROJECT_ENDPOINT=\"$PROJECTS_ENDPOINT\""
    echo "GPT_MODEL_DEPLOYMENT_NAME=\"gpt-4o-mini\""
    echo "EMBEDDING_MODEL_DEPLOYMENT_NAME=\"text-embedding-3-small\""
    echo "APPLICATIONINSIGHTS_CONNECTION_STRING=\"$APPLICATIONINSIGHTS_CONNECTION_STRING\""
  } > "$ROOT_ENV_FILE_PATH"
fi

CSHARP_PROJECT_PATH="../src/csharp/workshop/AgentWorkshop.Client/AgentWorkshop.Client.csproj"

# Set the user secrets for the C# project (if the project exists)
if [ -f "$CSHARP_PROJECT_PATH" ]; then
  dotnet user-secrets set "ConnectionStrings:AiAgentService" "$PROJECTS_ENDPOINT" --project "$CSHARP_PROJECT_PATH"
  dotnet user-secrets set "Azure:ModelName" "gpt-4o-mini" --project "$CSHARP_PROJECT_PATH"
fi

# Delete the output.json file
rm -f output.json

echo "Adding Azure AI Developer user role"

# Set Variables
subId=$(az account show --query id --output tsv)
objectId=$(az ad signed-in-user show --query id -o tsv)

echo "Ensuring Azure AI Developer role assignment..."

# Try to create the role assignment and capture both stdout and stderr
roleResult=$(az role assignment create --role "f6c7c914-8db3-469d-8ca1-694a8f32e121" \
                                       --assignee-object-id "$objectId" \
                                       --scope "subscriptions/$subId/resourceGroups/$RESOURCE_GROUP_NAME" \
                                       --assignee-principal-type 'User' 2>&1)

exitCode=$?

# Check if it succeeded or if the role assignment already exists
if [ $exitCode -eq 0 ]; then
    echo "✅ Azure AI Developer role assignment created successfully."
elif echo "$roleResult" | grep -q "RoleAssignmentExists\|already exists"; then
    echo "✅ Azure AI Developer role assignment already exists."
else
    echo "❌ User role assignment failed with unexpected error:"
    echo "$roleResult"
    exit 1
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Resource Information:"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  AI Project: $AI_PROJECT_NAME"
echo "  Application Insights: $APPLICATION_INSIGHTS_NAME"
echo ""