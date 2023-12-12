SELECT
  URI AS image_input,
  `${project_id}.${dataset_id}`.${remote_function_name}(URI) AS image_description
FROM
  `${project_id}.${dataset_id}`.${object_table_id}
