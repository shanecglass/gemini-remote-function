/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "image_bucket" {
  value       = google_storage_bucket.demo_images.name
  description = "Raw bucket name"
}

output "bigquery_editor_url" {
  value       = "https://console.cloud.google.com/bigquery?project=${module.project-services.project_id}&ws=!1m5!1m4!6m3!1s${module.project-services.project_id}!2s${google_bigquery_dataset.demo_dataset.dataset_id}"
  description = "The URL to launch the BigQuery editor with the sample query procedure opened"
}

output "create_remote_function_query" {
  value = templatefile("${path.module}/src/sql/provision_remote_function.sql", {
    project_id           = module.project-services.project_id,
    dataset_id           = google_bigquery_dataset.demo_dataset.dataset_id
    remote_function_name = google_cloudfunctions2_function.remote_function.name
    region               = var.region
    bq_connection_id     = google_bigquery_connection.function_connection.id
    remote_function_url  = google_cloudfunctions2_function.remote_function.service_config[0].uri
    }
  )
}

output "run_remote_function_query" {
  value = templatefile("${path.module}/src/sql/query_remote_function.sql", {
    project_id           = module.project-services.project_id,
    dataset_id           = google_bigquery_dataset.demo_dataset.dataset_id
    remote_function_name = google_cloudfunctions2_function.remote_function.name
    object_table_id      = google_bigquery_table.object_table.table_id
  })
  description = "The URL to launch the in-console tutorial for the EDW solution"
}
