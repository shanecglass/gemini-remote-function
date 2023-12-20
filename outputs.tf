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

output "image_function_url" {
  value       = google_cloudfunctions2_function.image_remote_function.url
  description = "The URL to invoke the image function"
}

output "text_function_url" {
  value       = google_cloudfunctions2_function.text_remote_function.url
  description = "The URL to invoke the text function"
}

output "vision_api_landmark_detection" {
  value = jsondecode(data.http.call_vision_api.response_body).responses[0].landmarkAnnotations[0].description
  description = "The JSON output of the Vision API analysis of the Grand Canyon photo"
  sensitive = true
}
