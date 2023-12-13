import functions_framework
import google.cloud.storage as gcs
from google.cloud.storage import Blob
import json
import os
import vertexai
from vertexai.preview.generative_models import GenerativeModel, Image


@functions_framework.http
def list_url(request):
  print(request)
  try:
    request_json = request.get_json()
    calls = request_json['calls']
    for call in calls:
      image_url = str(call[0])
      print(image_url)
    return image_url
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400


def analyze_image(image_file):
  multimodal_model = GenerativeModel("gemini-pro-vision")
  image = multimodal_model.Part.from_uri(
      image_file, mime_type="image/jpeg")
  responses = multimodal_model.generate_content([
      'Describe and summarize this image. Use no more than 5 sentences to do so', image],
      stream=True
  )
  for response in responses:
    print(response.text)
    output = json.loads(response.text)
    return output

def run_it(request):
  try:
    project_id = os.environ.get("PROJECT_ID")
    region = os.environ.get("REGION")
    vertexai.init(project=project_id, location=region)
    return_value = []
    file_to_analyze = list_url(request)
    image_description = analyze_image(file_to_analyze)
    return_value.append(image_description)
    return_json = json.dumps({"replies": return_value})
    return return_json
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400
