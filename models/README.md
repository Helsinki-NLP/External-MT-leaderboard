
# MT Model Benchmark Scores

Here are recipes for evaluating MT models and scores coming from systematically running MT benchmarks.
Each sub directory corresponds to a specific model type and includes tables of automatic evaluation results.

Currently, we store results for [OPUS-MT models](https://github.com/Helsinki-NLP/Opus-MT) trained on various subsets of [OPUS](https://github.com/Helsinki-NLP/OPUS) and on the compilation distributed in connection with the [Tatoeba translation challenge](https://github.com/Helsinki-NLP/Tatoeba-Challenge/).

```
OPUS-MT-models
Tatoeba-MT-model
```

The structure corresponds to the repository of OPUS-MT models with separate tables for different evaluation metrics.

```
src-trg/model-release-name.bleu-scores.txt
src-trg/model-release-name.spbleu-scores.txt
src-trg/model-release-name.chrf-scores.txt
src-trg/model-release-name.chrf++-scores.txt
src-trg/model-release-name.comet-scores.txt
```

`src` and `trg` typically correspond to source and target language identifiers but may also refer to sets of languages or other characteristics of the model (for example, `gmw` for Western Germanic languages or `de+en+sv` for specific language combinations). The `model-release-name` corresponds to the release name of the model.

There is also another file that combines BLEU and chrF scores together with some other information about the test set and the model (see further down below).

```
src-trg/model-release-name.scores.txt
```

Additional metrics can be added using the same format replacing `metric` in `src-trg/model-release-name.metric-scores.txt` with a descriptive unique name of the metric.

Note that chrF scores should for historical reasons be with decimals and not in percentages as they are given by current versions of sacrebleu. This is to match the implementation of the web interface of the OPUS-MT leaderboard.



## Model Score File Format

Each model score file for each specific evaluation metric follows a very simple format: The file is a plain text file with TAB-separated values in three columns specifying

* the language pair of the benchmark (e.g. 'deu-ukr')
* the name of the benchmark (e.g. `flores200-devtest`)
* the score

As an example, the German - Eastern Slavic languages model `Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.bleu-scores.txt` includes the following lines:

```
deu-bel	flores200-devtest	9.6
deu-rus	flores200-devtest	25.9
deu-ukr	flores200-devtest	24.0
deu-ukr	tatoeba-test-v2021-08-07	40.8
```


The only file that differs from this general format is the `src-trg/model-release-name.scores.txt` that combines BLEU and chrF scores. In addition to the scores, this file also includes

* the link to the actual model for downloading
* the size of the benchmark in terms of the number of sentences
* the size of the benchmark in terms of the number of tokens

Here is an example from `Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.scores.txt`:

```
deu-bel	flores101-devtest	0.38804	9.6	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	1012	24829
deu-ukr	flores200-devtest	0.53137	24.0	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	1012	22810
deu-ukr	tatoeba-test-v2021-08-07	0.62852	40.8	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	10319	56287
```


## Model Evaluation

The repository also comes with recipes for evaluating MT models. For example, the `Tatoeba-MT-models` sub directory includes makefile recipes for systematically testing released OPUS-MT models that use the Tatoeba translation challenge data. You can add new recipes for additional model types by creating a new sub directory in this folder and implementing the scripts that are necessary to create all necessary files for registering the benchmark results.

When evaluating a model you need to create or update all relevant model score files in the same format as specified before. Additionally, you should place the new results in the language score directory to be registered in the leaderboards of individual benchmarks.




## Model-Specific Notes


Settings language IDs in models from the Huggingface model hub is a bit tricky as metadata is not always consistent and documentation is lacking. Here some notes about selected models:

* Models based on fine-tuning mbart need to use language IDs with regional extensions like `it_IT` or generic ones like `en_XX`. Check https://huggingface.co/facebook/mbart-large-50 for a list of supported languages and their language IDs.
* NLLB requires 3-letter ISO codes for language IDs plus extension for the script the language is written in. See flores200 for more details.
* bert2bert does not seem to work with pipelines, does it?