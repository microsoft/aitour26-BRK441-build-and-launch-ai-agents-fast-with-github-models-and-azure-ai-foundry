# Demo Instructions

[**Instructions**: Select the **Evaluation** tab.]
Here within the Agent Builder, I’ll switch over to the Evaluation tab so that we can do a few manual evaluations for Cora. The Toolkit requires a minimum of one variable within the user prompt for the model to generate a response.

[**Instructions** Delete all but 1 user prompt. Modify the remaining prompt to read: Recommend {{product}} products.]
I’m going to clean up the prompts that I have here and just use the prompt “Recommend {{product}} products.” whereas {{product}} in brackets it the variable. This way, we can swap out any value for the variable within the Evaluation tab. 

[**Instructions**: Select the **Generate data** icon. View the UI and then exit the feature.]
This also enables us to use the AI Toolkit Generate Data feature to generate synthetic data, in the form of user prompts, for us to use for the evaluation.​ So, why is this helpful? Well, you may not always have evaluation data readily available, especially if you’re just at the prototyping phase. When you use the Generate Data feature, the Toolkit provides a prompt that’ll be used by the LLM to generate variable values with respect to the context of the variable. It takes the system prompt into consideration as context to help guide which sort of variable values to generate.​

​[**Instructions**: Select the **upload** icon and select the dataset located at **data/evals-data.csv**. Next, review the rows of data.]
Alternatively, you could upload your own dataset or manually add rows of data. I have the dataset here that Serena used, so I’ll upload it now. You may notice that some of the variable values don’t quite inquire about relevant information. We want to have this sort of user input because it’s imperative to see just how the model handles those sort of queries.​

​[**Instructions**: Select all rows and select **Run Evaluation**. Review the output.]
When I run to get the model’s response, the model follows all the configurations on the left and takes the prompts as context before generating its response.​

​[**Instructions**: Select thumbs up or thumbs down for each row.]
After running all 5 rows of data, I can start the manual evaluation process.​ Now that I’ve done the manual evaluation, I can export the results as a .JSONL file to save as a reference for future iterations of Cora. I could also save this entire version of Cora and come back to it later to compare evaluation results against a different version of Cora’s configuration.​ So, that covers manual evaluation which keeps a human in the loop for evaluating responses.​

[**Instructions**: Select **Add Evaluation** to create a new evaluation. View the list of evaluators. Select all evaluators in the **Agents** section. Also select **Coherence**.]
As mentioned, I could also automate this process with an automated evaluation that uses a language model (or AI) as the judge. To do so, I’ll begin by creating a new evaluation and then selecting the evaluators that are going to be best for my specific agent scenario. The toolkit organizes the evaluators by categories to provide ease of figuring out which evaluator is best for your scenario. Since Cora is an agent, I’ll select all 3 agent evaluators which are intent resolution, tool call accuracy, and task adherence. I’ll also select Coherence which is going to be useful to evaluating the quality of the agent’s response.​

​[**Instructions**: Select the **GPT-4o model**.]

Although I’m using GPT-4o to power Cora, I have the option to select a different model as the AI-judge. I’m going to stick w/ my Azure AI Foundry’s GPT-4o deployment.​

​[**Instructions**: Run the evaluation and view the results.]
Now that the evaluation is ready to be run, lets’ start the evaluation run and see what we get.​ From here, I could tweak some of Cora’s settings to see how that impacts the agent’s output. But when you’re doing evaluations, you don’t just want to start tweaking anything. I have a few tips for you to consider when you’re at the stage of evaluating your agent.​