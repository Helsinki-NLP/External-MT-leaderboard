
import sys
import argparse
from transformers import pipeline

parser = argparse.ArgumentParser()
parser.add_argument("-m", "--model", type=str, default="allenai/wmt19-de-en-6-6-base", help="model name")
parser.add_argument("-b", "--batch-size", type=int, default=64, help="batch size")
parser.add_argument("-l", "--max-length", type=int, default=500, help="max length")
parser.add_argument("-i", "--input-lang", type=str, default="de", help="input language ID")
parser.add_argument("-o", "--output-lang", type=str, default="en", help="output language ID")
args = parser.parse_args()

text = []
for line in sys.stdin:
    text.append(line.rstrip())

translation_pipeline = pipeline('translation', 
                                model=args.model, 
                                src_lang=args.input_lang, 
                                tgt_lang=args.output_lang, 
                                max_length=args.max_length,
                                device=0)

for output in translation_pipeline(text, batch_size=args.batch_size):
    print(output['translation_text'])


# print(translation_pipeline.model.num_parameters())

