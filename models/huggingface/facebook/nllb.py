
import sys
import argparse
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline

parser = argparse.ArgumentParser()
parser.add_argument("-m", "--model", type=str, default="nllb-200-distilled-600M", help="NLLB model name")
parser.add_argument("-b", "--batch-size", type=int, default=64, help="batch size")
parser.add_argument("-i", "--input-lang", type=str, default="deu_Latn", help="input language")
parser.add_argument("-o", "--output-lang", type=str, default="eng_Latn", help="output language")
args = parser.parse_args()

checkpoint = 'facebook/' + args.model
# checkpoint = 'facebook/nllb-200-1.3B'
# checkpoint = 'facebook/nllb-200-3.3B'
# checkpoint = 'facebook/nllb-200-distilled-1.3B'

text = []
for line in sys.stdin:
    text.append(line.rstrip())

model = AutoModelForSeq2SeqLM.from_pretrained(checkpoint)
tokenizer = AutoTokenizer.from_pretrained(checkpoint)

translation_pipeline = pipeline('translation', 
                                model=model, 
                                tokenizer=tokenizer, 
                                src_lang=args.input_lang, 
                                tgt_lang=args.output_lang, 
                                max_length=500,
                                device=0)

for output in translation_pipeline(text, batch_size=args.batch_size):
    print(output['translation_text'])
