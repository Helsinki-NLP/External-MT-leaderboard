from langcodes import *
import os
from huggingface_hub import HfApi, ModelSearchArguments, ModelFilter
from itertools import combinations
from transformers import pipeline, AutoModel
import re
import pandas as pd

def obtain_models():
    # Searches HF API for available models for the selected languages and returns a list of modelnames
    api = HfApi()

    model_args = ModelSearchArguments()

    all_langs = list(model_args.language)
    
    filt = ModelFilter(task=model_args.pipeline_tag.Translation)     

    models = api.list_models(filter=filt)

    print("All translation models, including Helsinki-NLP: ",len(models))
    
    translation_models = [model for model in models if model.author != 'Helsinki-NLP'] # Discard HelsinkiNLP models
    
    print("Helsinki models: ",len(models)-len(translation_models))
    
    print('Translation models found for candidate selection:',len(translation_models))

    return(translation_models, all_langs)

def evaluate_metadata(models, all_langs):
    
    no_metadata = []
    insuff_metadata = []
    good_metadata = []

    for model in models:
        model_langs = [tag for tag in model.tags if tag in all_langs] # We can only process models that have metadata
        if len(model_langs) == 0:
            no_metadata.append(model)
        elif len(model_langs) < 2:
            insuff_metadata.append(model)
        else:
            good_metadata.append([model, model_langs])

    print('Translation models without any language metadata:',len(no_metadata))
    print('Translation models with only one language:',len(insuff_metadata))
    print('Translation models with good metadata:',len(good_metadata))

    return good_metadata

def guess_langdir(modelname, model_langs):
    # Select only the modelname after the "/"
    if "/" in modelname:
        author, modelname = modelname.split('/')
    
    langdirs = []
    # Obtain all possible language combinations from the model's languages
    lang_combinations = list(combinations(model_langs, 2))

    for lang1, lang2 in lang_combinations:
        # Try to guess langdirection from modelname
        regex = lang1+"|"+lang2
        langdir = re.findall(regex,modelname)[-2:]
        if len(langdir) > 1:
            langdirs.append(langdir)
    return langdirs

def get_good_langdir_models(good_metadata_models):
    good_langdir_models = []

    for model, model_langs in good_metadata_models:
        modelname = model.modelId
        langdirs = guess_langdir(modelname,model_langs) #["ca","en"] or [("ca","en"),("ca","es")]
        for langdir in langdirs:
            src_lang, tgt_lang = langdir
            good_langdir_models.append([modelname,src_lang,tgt_lang])
    
    return good_langdir_models

def test_pipeline(models):
    pipeline_models = []

    for modelname, src, tgt in models:
        try:
            translator = pipeline("translation", model=modelname, src_lang=src, tgt_lang=tgt)
            pipeline_models.append([modelname,src,tgt])
        except Exception as e: print("\n\n"+modelname+"\n", e)

    return pipeline_models

def main():
    # Search the HF hub for all available translation models
    translation_models, all_langs = obtain_models()
    
    # Filter out those that have no metadata at all or only one language
    good_metadata_models = evaluate_metadata(translation_models, all_langs)

    # Keep those whose langauge direction can be inferred from the name
    good_langdir_models = get_good_langdir_models(good_metadata_models)

    # Create a dataframe to save results
    good_langdir_models_df = pd.DataFrame(good_langdir_models, columns = ["modelname","src_lang","tgt_lang"])
    good_langdir_models_df.to_csv("good_langdir_models.csv",sep="\t",index=None)
    print("Unique models with identifiable language direction: ",len(good_langdir_models_df.modelname.unique()))

    # Test if the models are working with the pipeline() object so that they can be use straight away
    pipeline_models = test_pipeline(good_langdir_models)

    # Create a dataframe to save results
    pipeline_models_df = pd.DataFrame(pipeline_models, columns = ["modelname","src_lang","tgt_lang"])
    pipeline_models_df.to_csv("pipeline_models.csv",sep="\t",index=None)
    print("Unique models working with the pipeline: ",len(pipeline_models_df.modelname.unique()))

main()
