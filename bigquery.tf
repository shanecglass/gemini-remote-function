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

#Create dataset to host the GCS object table
resource "google_bigquery_dataset" "demo_dataset" {
  project    = module.project-services.project_id
  dataset_id = "gemini_demo"
  location   = var.region
  depends_on = [time_sleep.wait_after_apis]
}

#Create BigQuery connection for Cloud Functions and GCS
resource "google_bigquery_connection" "function_connection" {
  connection_id = var.connection_id
  project       = module.project-services.project_id
  location      = var.region
  friendly_name = "Gemini connection"
  description   = "Connecting to the remote function that analyzes imges using Gemini"
  cloud_resource {}
  depends_on = [time_sleep.wait_after_apis]
}

#Grant the connection service account necessary permissions
resource "google_project_iam_member" "functions_invoke_roles" {
  for_each = toset([
    "roles/run.invoker",            // Service account role to invoke the remote function
    "roles/cloudfunctions.invoker", // Service account role to invoke the remote function
    "roles/storage.objectViewer",   // View GCS objects to create object tables
    "roles/iam.serviceAccountUser"
    ]
  )

  project = module.project-services.project_id
  role    = each.key
  member  = format("serviceAccount:%s", google_bigquery_connection.function_connection.cloud_resource[0].service_account_id)

  depends_on = [google_bigquery_connection.function_connection]
}

#Create GCS object table for your images. This will be the input table for the remote function
resource "google_bigquery_table" "object_table" {
  project             = module.project-services.project_id
  dataset_id          = google_bigquery_dataset.demo_dataset.dataset_id
  table_id            = "image_object_table"
  deletion_protection = var.deletion_protection

  external_data_configuration {
    autodetect      = false
    connection_id   = google_bigquery_connection.function_connection.id
    source_uris     = ["${google_storage_bucket.demo_images.url}/*"]
    object_metadata = "Simple"
  }

  depends_on = [google_project_iam_member.functions_invoke_roles, google_storage_bucket_object.image_upload]
}

# Create a series of stored procedures to connect to the remote function and call it
## Create the image remote function. This stored procedure will be called by the workflow
resource "google_bigquery_routine" "image_create_remote_function_sp" {
  project      = module.project-services.project_id
  dataset_id   = google_bigquery_dataset.demo_dataset.dataset_id
  routine_id   = "image_remote_function_sp"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile("${path.module}/src/sql/image/provision_remote_function.sql", {
    project_id          = module.project-services.project_id,
    dataset_id          = google_bigquery_dataset.demo_dataset.dataset_id
    bq_function_name    = var.image_function_name
    region              = var.region
    bq_connection_id    = var.connection_id
    remote_function_url = google_cloudfunctions2_function.image_remote_function.service_config[0].uri
    }
  )
}

#Sample query to call the image remote function
resource "google_bigquery_routine" "image_query_remote_function_sp" {
  project      = module.project-services.project_id
  dataset_id   = google_bigquery_dataset.demo_dataset.dataset_id
  routine_id   = "image_query_remote_function_sp"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile("${path.module}/src/sql/image/query_remote_function.sql", {
    project_id       = module.project-services.project_id,
    dataset_id       = google_bigquery_dataset.demo_dataset.dataset_id
    bq_function_name = var.image_function_name
    object_table_id  = google_bigquery_table.object_table.table_id
    }
  )
  depends_on = [
    google_bigquery_routine.image_create_remote_function_sp
  ]
}

## Create the sample text input table. This stored procedure will be called by the workflow
resource "google_bigquery_routine" "provision_text_sample_table_sp" {
  project      = module.project-services.project_id
  dataset_id   = google_bigquery_dataset.demo_dataset.dataset_id
  routine_id   = "provision_text_sample_table_sp"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile("${path.module}/src/sql/provision_text_sample_table.sql", {
    project_id = module.project-services.project_id,
    dataset_id = google_bigquery_dataset.demo_dataset.dataset_id
    }
  )
}

## Create the image remote function. This stored procedure will be called by the workflow
resource "google_bigquery_routine" "text_create_remote_function_sp" {
  project      = module.project-services.project_id
  dataset_id   = google_bigquery_dataset.demo_dataset.dataset_id
  routine_id   = "text_remote_function_sp"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile("${path.module}/src/sql/text/provision_remote_function.sql", {
    project_id          = module.project-services.project_id,
    dataset_id          = google_bigquery_dataset.demo_dataset.dataset_id
    bq_function_name    = var.text_function_name
    region              = var.region
    bq_connection_id    = var.connection_id
    remote_function_url = google_cloudfunctions2_function.text_remote_function.service_config[0].uri
    }
  )
}

#Sample query to call the image remote function
resource "google_bigquery_routine" "text_query_remote_function_sp" {
  project      = module.project-services.project_id
  dataset_id   = google_bigquery_dataset.demo_dataset.dataset_id
  routine_id   = "text_query_remote_function_sp"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile("${path.module}/src/sql/text/query_remote_function.sql", {
    project_id       = module.project-services.project_id,
    dataset_id       = google_bigquery_dataset.demo_dataset.dataset_id
    bq_function_name = var.text_function_name
    object_table_id  = google_bigquery_table.object_table.table_id
    }
  )
  depends_on = [
    google_bigquery_routine.text_create_remote_function_sp,
    google_bigquery_routine.provision_text_sample_table_sp
  ]
}
