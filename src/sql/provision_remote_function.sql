CREATE OR REPLACE FUNCTION(
  ${project_id}.${dataset_id}.${remote_function_name} (gcs_uri STRING) RETURNS STRING
  REMOTE WITH CONNECTION `${project_id}.${region}.${bq_connection_id}`
  OPTIONS (endpoint = '${remote_function_url}')
)
