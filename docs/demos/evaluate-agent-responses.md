# Demo Instructions

**Instructions**: View the updates made to the agent instructions.

**Script**: Back here in the Agent Builder, you  may notice that the instructions look a little different. The reason being is that when you're going to do evaluations, you need to have at least 1 variable defined in your instructions. As you can see, the variable Serena's chosen is **product**. That makes the **product** value dynamic so that whenever I run an evaluation, it's going to pass in the value for **product** in it's place and it'll become part of the instructions for that iteration of the evaluation run.

---

**Instructions**: Scroll down to the **Variables** section to view the list of variables.

**Script**: If I scroll down to the **Variables** section, I can see that it includes the variable **product**.

---

**Instructions**: Switch to the **Evaluation** tab. Select the **Generate Data** button.

**Script**: Switching over to the Evaluation tab, the first thing that I want to call out is the Generate Data feature. The feature enable us to generate data in the form of user prompts and values for the variable. So, why is this helpful? Well, you may not always have evaluation data readily available, especially if you’re just at the prototyping phase. When you use the Generate Data feature, the Toolkit provides a prompt that’ll be used by the LLM to generate variable values with respect to the context of the variable. It takes the system prompt into consideration as context to help guide which sort of variable values to generate.​

---

​**Instructions**: Select the **Import** icon to upload the dataset located at `data/evals-data.csv`. Review the imported data.

**Script**: Alternatively, you could upload your own dataset or manually add rows of data. I have the dataset here that Serena used, so I’ll upload it now. You may notice that some of the variable values don’t quite inquire about relevant information. We want to have this sort of user input because it’s imperative to see just how the model handles those sort of queries.​

---

​**Instructions**: Select all rows and select **Run Evaluation**. Review the output. Alternatively, run one run of data at a time and review the response.

**Script**: Let's now run each row of data to generate the model's response. After running all 5 rows of data, I can start the manual evaluation process.

---

​**Instructions**: Select thumbs up or thumbs down for each row.

**Script**: ​Now that I’ve done the manual evaluation, I can export the results as a .JSONL file to save as a reference for future iterations of Cora. I could also save this entire version of Cora and come back to it later to compare evaluation results against a different version of Cora’s configuration.​ So, that covers manual evaluation which keeps a human in the loop for evaluating responses.​

---

**Instructions**: Select **Add Evaluation** to create a new evaluation. View the list of evaluators. Select all evaluators in the **Agents** section. Also select **Coherence**.

**Script**: As mentioned, I could also automate this process with an automated evaluation that uses a language model (or AI) as the judge. To do so, I’ll begin by creating a new evaluation and then selecting the evaluators that are going to be best for my specific agent scenario. The toolkit organizes the evaluators by categories to provide ease of figuring out which evaluator is best for your scenario. Since Cora is an agent, I’ll select all 3 agent evaluators which are intent resolution, tool call accuracy, and task adherence. I’ll also select Coherence which is going to be useful to evaluating the quality of the agent’s response.​

---

​**Instructions**: Select the **GPT-4o model**.

**Script**: Although I’m using GPT-4o to power Cora, I have the option to select a different model as the AI-judge. I’m going to stick w/ my Azure AI Foundry’s GPT-4o deployment.​

---

​**Instructions**: Run the evaluation and view the results.

**Script**: Now that the evaluation is ready to be run, lets’ start the evaluation run and see what we get.​ From here, I could tweak some of Cora’s settings to see how that impacts the agent’s output. But when you’re doing evaluations, you don’t just want to start tweaking anything. I have a few tips for you to consider when you’re at the stage of evaluating your agent.​
