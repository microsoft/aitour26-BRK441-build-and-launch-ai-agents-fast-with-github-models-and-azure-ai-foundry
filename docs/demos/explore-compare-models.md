# Demo Instructions: Explore and Compare Models

[**Instructions**: Open the **Model Catalog** and scroll down to view models]
Here in the AI Toolkit, I’ll open up the Model Catalog to browse the models that are available. Since Serena began in the prototyping stage, she likely started w/ one of the GitHub models. They’re free to use and are a great option for figuring out which model may be best for powering the Cora agent.​

[**Instructions**: Apply the **Hosted by** filter and select **GitHub**. Then apply the **Feature** filter and select **Image Attachment**.]
I’ll apply the ‘Hosted by’ filter to narrow down the results to GitHub models. And as we can see, we have a good amount to choose from. However, if you recall, Serena needed a multi-modal model, specifically one that supports image attachments as input. Fortunately, we can drill down further into our model results by applying the Feature filter for Image Attachment. This now gives a better idea of which models may be use for Zava’s agent.​

[**Instructions**: Scroll to the **GPT-4o** model followed by the **o4-mini** model.]
Serena had heard a lot about GPT-4o, but had also recently read-up on the efficiencies of small language models. Therefore, o4-mini became another prime candidate. Rather than test each model’s output in isolation when handling image attachments, Serena was able to compare both models simultaneously in the Playground.​

[**Instructions**: Select **Add model** for both the **GPT-4o** model followed by the **o4-mini** model. Then open the **Playground**.]
Let’s add both models to ‘My models’ and assess how well they perform in the Playground.​

[**Instructions**: Select **Compare** and select to compare both the **GPT-4o** and **o4-mini** from the drop-down.]
Here in the Playground, I see that GPT-4o is currently selected as my model. Clicking the Compare button enables me to select another model, in this case the o4 mini, for comparison.​

[**Instructions**: Enter the Prompt: Describe what’s in the image, including colors of the objects.​ Next, select the living room photo located in img/demo-living-room.png. Run the prompt.]
Things are starting to get fun because now we can enter the same prompt once and view each model’s output in one view. Since we’re optimizing for the model’s ability to process the content of the image, I’ll pass in a photo of living room and ask each model to describe what’s in the image, including colors. After all, Cora is designed to help customers like Bruno resolve their home-DIY project needs. It’s only right that we test both models with a relevant prompt and scenario.​

[**Instructions**: Review the output from the models.]
From what I’m seeing in the output, I can see why Serena leaned towards using GPT-4o for Cora. Although o4-mini gives us a decent output, I much prefer the depth of 4o’s description.​

​[**Instructions**: Return to the **Model Catalog**. Navigate to the **Azure AI Foundry GPT-4o** model is located.]
With the model chosen, we can move forward w/ prototyping the agent. If you recall, Zava is an Azure customer and as such, Serena plans to use an Azure AI Foundry-hosted model in production. Fortunately, GPT-4o is also available w/ Azure AI Foundry and therefore, we’ll deploy GPT-4o w/ Azure AI Foundry now. With the AI Foundry model, Zava gains enhanced performance, scalability, and security. Not to mention, enterprise-grade Service Level Agreements.​
​
Now that the model has been deployed, it appears in My Models within my Azure AI Foundry models.​