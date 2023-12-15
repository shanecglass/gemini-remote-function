CREATE OR REPLACE FUNCTION
  `${project_id}.${dataset_id}.${bq_function_name}` (input_text STRING) RETURNS STRING
  REMOTE WITH CONNECTION `${project_id}.${region}.${bq_connection_id}`
  OPTIONS (
    endpoint = '${remote_function_url}',
    max_batching_rows = 1
  )
