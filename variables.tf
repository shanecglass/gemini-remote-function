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

variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "region" {
  type        = string
  description = "Google Cloud Region"
}

variable "image_object_path" {
  type        = string
  description = "URI for the GCS bucket containing the images to be analyzed. This is connected to BigQuery as a GCS object table"
  default     = "[gs://gemini-image-recognition-demo/images/*.jpg]"
}

variable "connection_id" {
  type        = string
  description = "Default ID for the BigQuery connection that is created"
  default     = "gcf-connection"
}

variable "image_function_name" {
  type        = string
  description = "Name of the BigQuery remote function for image analysis"
  default     = "gemini_bq_demo_image"
}

variable "text_function_name" {
  type        = string
  description = "Name of the BigQuery remote function for text analysis"
  default     = "gemini_bq_demo_text"
}

variable "enable_apis" {
  type        = string
  description = "Whether or not to enable underlying apis in this solution."
  default     = true
}

variable "force_destroy" {
  type        = string
  description = "Whether or not to protect BigQuery resources from deletion when solution is modified or changed."
  default     = false
}

variable "deletion_protection" {
  type        = string
  description = "Whether or not to protect GCS resources from deletion when solution is modified or changed."
  default     = true
}
