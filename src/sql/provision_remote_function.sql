CREATE OR REPLACE FUNCTION(
  ${project_id}.${dataset_id}.${remote_function_name} (gcs_uri STRING) RETURNS STRING
  REMOTE WITH CONNECTION `${project_id}.${region}.${var.conection_id}`
  OPTIONS (endpoint = '${remote_function_url}')
)
