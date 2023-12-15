SELECT
  uri AS image_input,
  `${project_id}.${dataset_id}.${bq_function_name}` (uri) AS image_description
FROM
  `${project_id}.${dataset_id}.${object_table_id}`
