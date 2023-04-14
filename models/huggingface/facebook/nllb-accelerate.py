
import sys
import argparse

from transformers import pipeline
from transformers import AutoConfig, AutoTokenizer, AutoModelForSeq2SeqLM
from accelerate import init_empty_weights, load_checkpoint_and_dispatch


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

config = AutoConfig.from_pretrained(checkpoint)

with init_empty_weights():
    model = AutoModelForSeq2SeqLM.from_config(config)

model = load_checkpoint_and_dispatch(model, checkpoint, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(checkpoint)


text = []
for line in sys.stdin:
    text.append(line.rstrip())

translation_pipeline = pipeline('translation', 
                                model=model, 
                                tokenizer=tokenizer, 
                                src_lang=args.input_lang, 
                                tgt_lang=args.output_lang, 
                                max_length=500,
                                device=0)

for output in translation_pipeline(text, batch_size=args.batch_size):
    print(output['translation_text'])
