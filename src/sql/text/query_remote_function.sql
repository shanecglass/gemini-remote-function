SELECT
  text_prompt AS text_input,
  `${project_id}.${dataset_id}.${bq_function_name}` (text_prompt) AS landmark_description
FROM
  `${project_id}.${dataset_id}.sample_text_prompts`
