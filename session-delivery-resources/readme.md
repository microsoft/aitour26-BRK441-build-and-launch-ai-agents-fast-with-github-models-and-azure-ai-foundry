## How to deliver this session

🥇 Thanks for delivering this session!

Prior to delivering the workshop please:

1.  Read this document and all included resources included in their entirety.
2.  Watch the video presentation
3.  Ask questions of the content leads! We're here to help!


## 📁 File Summary

| Resources          | Links                            | Description |
|-------------------|----------------------------------|-------------------|
| Workshop Slide Deck      |  [Presentation](https://aka.ms/)  | Presentation slides for this workshop with presenter notes and embedded demo video |
| Session Delivery Deck     |  [Deck](https://aka.ms/) | The session delivery slides |
| More Files     |  [Some More Files](https://aka.ms/) | More File Descriptions |


## 🚀Get Started

The breakout is divided into multiple sections including 32 slides and 6 demos.

### 🕐Timing

| Time        | Description 
--------------|-------------
0:00 - 0:00   | Intro and overview
0:00 - 0:00   | GenAI ops
0:00 - 0:00   | Meet the models
0:00 - 0:00   | Design your agent
0:00 - 0:00   | Evaluate your agent responses
0:00 - 0:00   | From prototype to production
0:00 - 0:00   | Wrap up and Q&A

### 🖥️Demos

| Demo        | Description 
--------------|-------------
[Explore and compare models](/docs/demos/explore-compare-models.md)   | Browse the model **Catalog** in the AI Toolkit and compare 2 models within the **Playground**
[Create agents with Agent Builder](/docs/demos/create-agents.md)   | Create the Cora agent in the **Agent Builder** and define it's system prompt
[Add tools to an agent in Agent Builder](/docs/demos/add-tools.md)   | Connect the Cora agent to the **Zava MCP server** and add the **get_products_by_name** tool
[Evaluate agent responses](/docs/demos/evaluate-agent-responses.md)   | Run both manual and AI-assisted evaluations for the agent output
[Export agent code](/docs/demos/export-agent-code.md)   | Export the code from the **Agent Builder** for the Cora agent
[Cora app](/docs/demos/cora-app.md)   | Chat with the Cora agent live via the agent UI

### 🏋️Preparation
This demo is designed to be run in a development container for easy setup. The container includes the following:
- PostgresSQL dataset for Zava
- **Customer Sales Server** that does basic product search using traditional name-based matching
- A web app of the Cora agent app

#### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- Azure AI Foundry project with a **GPT-4o** model deployment
- [Visual Studio Code](https://code.visualstudio.com)

**Open the repository in the dev container**

1. Open **Docker Desktop**.
1. Fork and clone this repository in Visual Studio Code.
1. When prompted by Visual Studio Code, select to "Reopen in Container". Alternatively, open the **Command Palette** (i.e. CTRL/CMD+Shift+P) and enter **Dev Containers: Reopen in Container**.
1. Wait for the setup to complete. The dev container will build automatically with all dependencies pre-installed. This includes PostgresSQL with pgvector extension, a Python environment, and all required packages.

**Confirm extensions are installed**

Confirm that the dev container has installed the following extensions:
- [Azure Resources](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureresourcegroups)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [AI Toolkit](https://aka.ms/AIToolkit)

If any extension is missing, install before moving forward.

*Note: The [Azure AI Foundry](https://marketplace.visualstudio.com/items?itemName=TeamsDevApp.vscode-ai-foundry) extension is installed as a bundle with the AI Toolkit*.

**Sign-in to the Azure Resources extension and set your default project.**

1. In the **Azure Resources** extension, select **Sign in to Azure**.
1. Sign-in to the account that has your Azure AI Foundry project and GPT-4o deployed model.
1. Open the **Azure AI Foundry** extension (*note: the Azure AI Foundry extension comes installed with the AI Toolkit*).
1. Under the **Resources** section, confirm whether your Azure AI Foundry project is set as the default project. The default project displays under **Resources** with a **Default** label.
1. If your project is **not** set as the default project, hover over the project name and click the **Switch Default Project in Azure Extension** icon (*note: the icon looks like 3 lines*).
1. In the **Pick a project** window, select the subscription that has your Azure AI Foundry project.
1. In the **Pick a project** window, select your Azure AI Foundry project.

**Setup environment variables**
1. In the terminal, run the command: `cp .env.example .env`
1. Open your new `.env` file.
1. Enter your `AZURE_AI_API_KEY="<your_Azure_AI_API_key>"` (note: The **Key** in the **Endpoint** section for your model deployment )
1. Enter your `AZURE_AI_ENDPOINT="<your_Azure_AI_endpoint>"` (note: The **Target URI** in the Endpoint section for your model deployment up until the deployment name; ex: https://{your-custom-endpoint}-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o)

**Start the Customer Sales Server**

1. Open the **.vscode/mcp.json** file.
1. Click **Start** above the **zava-customer-sales-stdio** server.

**Start the Cora web app**

1. In the terminal, run the command `python src/web_app/app.py`.
1. In the browser, navigate to [htts://localhost:8000](http://localhost:8000).
1. Confirm that the green **Connected** label displays in the top-right of the UI.