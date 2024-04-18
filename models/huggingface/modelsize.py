
import argparse
from transformers import pipeline

parser = argparse.ArgumentParser()
parser.add_argument("-m", "--model", type=str, default="allenai/wmt19-de-en-6-6-base", help="model name")
args = parser.parse_args()

translation_pipeline = pipeline('translation', model=args.model)
parameters = translation_pipeline.model.num_parameters()
parameters/=1e6
print(f"parameters: {parameters:.1f}M")
