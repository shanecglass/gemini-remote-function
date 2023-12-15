import functions_framework
import json
import os
import vertexai
from vertexai.preview import generative_models
from vertexai.preview.generative_models import GenerativeModel


@functions_framework.http
def list_text_input(request):
  print(request)
  try:
    request_json = request.get_json()
    calls = request_json['calls']
    for call in calls:
      text_prompt = str(call[0])
      print(text_prompt)
    return text_prompt
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400


def generate_text_from_prompt(text_string):
  text_model = GenerativeModel("gemini-pro")  # this is the text-to-text model
  responses = text_model.generate_content(text_string,
                                          stream=True
                                          )
  for response in responses:
    output = response.text
    output = output.strip()
    output = output.split("\n")
    output = " ".join(output)
    print(output)
    return output


def check_string(input_string):
  if not input_string:
    return "Unable to generate description"
  return input_string


def run_it(request):
  try:
    project_id = os.environ.get("PROJECT_ID")
    region = os.environ.get("REGION")
    vertexai.init(project=project_id, location=region)
    text_to_analyze = list_text_input(request)
    text_output = generate_text_from_prompt(text_to_analyze)
    return_value = []
    result = check_string(text_output)
    return_value.append(result)
    return_json = json.dumps({"replies": return_value})
    return return_json
  except Exception as e:
    return json.dumps({"errorMessage": str(e)}), 400
