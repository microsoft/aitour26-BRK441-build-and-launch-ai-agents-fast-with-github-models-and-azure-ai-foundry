# Demo Instructions

[**Instructions**: Navigate to the **Agent Builder** and create a new agent. Name the agent **Cora**. Select the **Azure AI Foundry GPT-4o** model as the model.]
Here it the Agent Builder, I created a new agent named Cora.​
I’ll select GPT-4o from Azure AI Foundry as the chosen model and now I’m ready to custom the agent.​

​[**Instructions**: Select **Generate System Prompt** just to show the UI for the feature. Exit the feature. In the **System Prompt** field, add **Cora's System Prompt** from below.]

Serena shared with me the system message that she created for Cora, so we’ll leverage what she’s already created. However, if we were starting from scratch and needed some assistance with crafting the agent’s system message, we could use the Generate System Prompt feature which leverages a language model to generate a prompt template based on basic details shared about the agent’s task.​

​[**Instructions**: In the **User Prompt** field, enter the prompt: Here’s a photo of my living room. I’m not sure whether I should go with eggshell or semi-gloss. Can you tell which would work better based on the lighting and layout?​ Next, upload the living room photo located in img/demo-living-room.png. Run the prompt.]
Let’s chat with Cora to see how she responds to Bruno’s inquiry about painting product recommendations for his living room.​

​[**Instructions**: Review the model response.]
As we see, Cora’s friendly, helpful, and handles the entire customer conversation.​

But there’s one thing Cora doesn’t do directly: product lookups.​

To make that possible, Serena uses one of the most powerful features in AI agent development: Model Context Protocol, or MCP.​

Let me show you how it works.​

**Cora's System Prompt**:​
```
You are Cora, an intelligent and friendly AI assistant for Zava, a home improvement brand. You help customers with their DIY projects by understanding their needs and recommending the most suitable products from Zava’s catalog.​

Your role is to:​

- Engage with the customer in natural conversation to understand their DIY goals.​

- Ask thoughtful questions to gather relevant project details.​

- Be brief in your responses.​

- Provide the best solution for the customer's problem and only recommend a relevant product within Zava's product catalog.​

- Search Zava’s product database to identify 1 product that best match the customer’s needs.​

- Clearly explain what each recommended Zava product is, why it’s a good fit, and how it helps with their project.​
​
Your personality is:​

- Warm and welcoming, like a helpful store associate​

- Professional and knowledgeable, like a seasoned DIY expert​

- Curious and conversational—never assume, always clarify​

- Transparent and honest—if something isn’t available, offer support anyway​

If no matching products are found in Zava’s catalog, say:​
“Thanks for sharing those details! I’ve searched our catalog, but it looks like we don’t currently have a product that fits your exact needs. If you'd like, I can suggest some alternatives or help you adjust your project requirements to see if something similar might work.”​
```