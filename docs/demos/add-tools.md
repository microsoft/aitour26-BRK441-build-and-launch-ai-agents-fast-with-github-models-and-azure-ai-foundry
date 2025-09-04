# Demo Instructions

[**Instructions**: Scroll down to the **Tools** section in the **Agent Builder**.]
Back here in the Agent Builder, I can connect to Zava’s custom MCP server and add whichever tools will be relevant for Cora. Zava’s Basic Customer Sales Server enables Cora to do product searches by name with fuzzy matching, get store-specific product availability through row level security, and get real-time inventory levels and stock information. I already have the server running here in the background within VS Code and I can access it via the AI Toolkit.​

​[**Instructions**: Select the **+** icon next to **Tools**. Select the running server. Add the **get_products_by_name** tool. In the **User Prompt** section, enter the prompt: Here’s a photo of my living room. I’m not sure whether I should go with eggshell or semi-gloss. Can you tell which would work better based on the lighting and layout?​ Run the prompt.]
I’m going to add the get_products_by_name tool to Cora and submit another prompt to see whether Cora searches through Zava’s product catalog before generating its output to a customer.​

​[**Instructions**: Review the output. If Cora asks whether to recommend products, enter the prompt: Yes, recommend products.​]
Here in the model output, I can see the tool call and yes, Cora did call the get_products_by_name tool. Based on the information returned from the tool call, Cora generates a response which states [Cora’s response].​

Now that Cora is up and running and connected to Zava’s product catalog using MCP, Serena has a working prototype.​

But before she ships it, she needs to know:​
- Is Cora actually doing what she’s supposed to do?​
- Are the responses clear? Trustworthy? Helpful?​

In other words—can Serena trust this agent to interact with real customers like Bruno?​

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

Your personality is:​

- Warm and welcoming, like a helpful store associate​

- Professional and knowledgeable, like a seasoned DIY expert​

- Curious and conversational—never assume, always clarify​

- Transparent and honest—if something isn’t available, offer support anyway​

If no matching products are found in Zava’s catalog, say:​
“Thanks for sharing those details! I’ve searched our catalog, but it looks like we don’t currently have a product that fits your exact needs. If you'd like, I can suggest some alternatives or help you adjust your project requirements to see if something similar might work.”​
```