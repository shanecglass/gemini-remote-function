import functions_framework
from google.cloud import aiplatform
from vertexai.preview.generative_models import GenerativeModel, Image
import json
import os.path
import subprocess
import tempfile
import vertexai

tmpdir = tempfile.mkdtemp()
multimodal_model = GenerativeModel("gemini-pro-vision")

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

def download_to_local(request, tmpdir):
  images_to_analyze = []
  analysis_list = []
  for gsc_uri in (list_url(request)):
    analysis_list.append(gsc_uri)
  print(f"List of files to analze from GCS: ", analysis_list)
  for index, gsc_uri in enumerate(analysis_list, start = 1):
    image_name = f'image_{index}.png'
    dest_path = os.path.join(tmpdir, image_name)
    subprocess.run(f'gsutil cp {gsc_uri} ./{dest_path}')
    vars()['image_'+str(index)] = Image.load_from_file(image_name)
    images_to_analyze.append(vars()['image_'+str(index)])
    print(f'{image_name} downloaded')
  return images_to_analyze

def analyze_image(images_to_analyze):
  for image in images_to_analyze:
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
    local_file_to_analyze = download_to_local(request, tmpdir)
    image_description = analyze_image(local_file_to_analyze)
    return_value.append(image_description)
    return_json = json.dumps({"replies": return_value})
    return return_json
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400
