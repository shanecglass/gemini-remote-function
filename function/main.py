import functions_framework
import google.cloud.storage as gcs
from google.cloud.storage import Blob
import json
import logging
import os.path
import tempfile
import vertexai
from vertexai.preview.generative_models import GenerativeModel, Image

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


def copy_fromgcs(blob_name, destdir, basename):
  client = gcs.Client()
  blob = Blob.from_string(blob_name, client=client)
  logging.info('Downloading {}'.format(blob))
  dest = os.path.join(destdir, basename)
  blob.download_to_filename(dest)
  return dest

# def download_to_local(image_uri, tmpdir):
#   print(f"File to analze from GCS: ", image_uri)
#   dest_path = os.path.join(tmpdir, 'image.png')
#   download_command = f"gsutil cp {image_uri} .{dest_path}"
#   subprocess.run(download_command)
#   image = Image.load_from_file(image_name)
#   print(f'{image_name} downloaded')
#   return image


def analyze_image(image_name):
  image = Image.load_from_file(image_name)
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
    local_file_to_analyze = copy_fromgcs(
        list_url(request), tmpdir, "image.png")
    image_description = analyze_image(local_file_to_analyze)
    return_value.append(image_description)
    return_json = json.dumps({"replies": return_value})
    return return_json
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400
