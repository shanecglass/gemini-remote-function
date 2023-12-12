import bigframes.pandas as bpd
import functions_framework
import google.cloud.bigquery as bigquery
import google.cloud.storage as gcs
from google.cloud.storage import Blob
from google.cloud import aiplatform
from google.cloud.aiplatform.private_preview.generative_models import GenerativeModel, Image
import json
import logging
import os.path
import pandas as pd
import subprocess
import sys
import tempfile
import vertexai

tmpdir = tempfile.mkdtemp()
multimodal_model = GenerativeModel("gemini-pro-vision")

# #Download package
# def download_package(destdir):
#   client = gcs.Client()
#   blob = Blob.from_string("gs://vertex_sdk_internal_releases/Gemini/Python/google_cloud_aiplatform-1.37.dev20231201+generative.models-py2.py3-none-any.whl", client=client)
#   logging.info('Downloading {}'.format(blob))
#   dest = os.path.join(destdir, "google_cloud_aiplatform-1.37.dev20231201+generative.models-py2.py3-none-any.whl")
#   blob.download_to_filename(dest)
#   return dest

# def install_package(input_file):
#   subprocess.check_call([sys.executable, "-m", "pip", "install", input_file])
#   print("Package install successful")

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
  pandas_df = pd.DataFrame(columns=["name", "is_bridge"])
  for index, image in enumerate(images_to_analyze, start=1):
    if index < 3:
      continue
    else:
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
    # install_package(download_package(tmpdir))
    local_file_to_analyze = download_to_local(request, tmpdir)
    image_description = analyze_image(local_file_to_analyze)
    return_value.append(image_description)
    return_json = json.dumps({"replies": return_value})
    return return_json
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400
