
# OPUS-MT leaderboard

A repository of scores and leaderboard for MT models and benchmarks.

* [model scores for various benchmarks](models)
* [leaderboards per benchmark](scores)
* [recipes for automatic model evaluation](models)
* [merged benchmark translations for better comparison](compare)
* [web-based dashboard](https://github.com/Helsinki-NLP/OPUS-MT-dashboard)


## Leaderboards

The `scores` directory includes leaderboards for each evaluated benchmark in [OPUS-MT-testsets](https://github.com/Helsinki-NLP/OPUS-MT-testsets/). The benchmark-specific leaderboards are stored as plain text files with TAB-separated values using the following file structure:

```
scores/src-trg/benchmark/metric-scores.txt
```

`src` and `trg` correspond to the language pair, `benchmark` is the name of the benchmark and `metric` is the name of evaluation metric such as bleu, chrf or comet. The file names and structure corresponds to the benchmark files in [OPUS-MT-testsets](https://github.com/Helsinki-NLP/OPUS-MT-testsets). 

Furthermore, we also keep lists of the top-scoring models per benchmark for each language pair and a list of model score averages aggregated over selected benchmarks for each language pair. There are separate lists for each evaluation metric. For example, for [German - Ukrainian](scores/deu-ukr), there are score files like

```
scores/deu-ukr/avg-bleu-scores.txt
scores/deu-ukr/avg-chrf-scores.txt
scores/deu-ukr/avg-comet-scores.txt

scores/deu-ukr/top-bleu-scores.txt
scores/deu-ukr/top-chrf-scores.txt
scores/deu-ukr/top-comet-scores.txt
```

Scores for other models than OPUS-MT will be stored in the same way in the sub-directory `external-scores`.


### File Formats

All leaderboard files follow a very simple format with two TAB-separated values and rows sorted by score. The columns are:

* the actual score
* the download link of the model

For example, the BLEU-score leaderboard for the Flores200 devtest benchmark in German-Ukrainian is stored in [scores/deu-ukr/flores200-devtest/bleu-scores.txt](scores/deu-ukr/flores200-devtest/bleu-scores.txt) and includes lines like:

```
24.2	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-23.zip
24.0	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip
23.6	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-ukr/opusTCv20210807+pbt_transformer-align_2022-03-07.zip
23.5	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-13.zip
14.6	https://object.pouta.csc.fi/Tatoeba-MT-models/gmw-zle/opus1m-2021-02-12.zip
...
```

The best performaning models for each benchmark for a given language pair are listed with the following format: TAB-separated plain text files with 3 columns:

* the name of the benchmark
* the top score among all models
* the download link for the top-scoring model

To give an example, the top BLEU score for German-Ukrainian benchmarks is stored in [scores/deu-ukr/top-bleu-scores.txt](scores/deu-ukr/top-bleu-scores.txt) with lines like:


```
flores200-dev	23.3	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-23.zip
flores200-devtest	24.2	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-23.zip
tatoeba-test-v2021-08-07	40.8	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip
```


To make it easier to compare model performance, we also keep model lists sorted by scores averaged over a selected number of benchmarks. Those files start with a line that list the selected benchmarks used for computing the score and the following lines follow the standard leaderboard file format with TAB-separated values for the (averaged score and the download link of the model. For example, [scores/deu-ukr/avg-bleu-scores.txt](scores/deu-ukr/avg-bleu-scores.txt) starts like this:


```
flores tatoeba
32.2583333333333	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-23.zip
32.2333333333333	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip
31.8166666666667	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-13.zip
31.225	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-ukr/opusTCv20210807+pbt_transformer-align_2022-03-07.zip
29.8125	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-ukr/opusTCv20210807+nopar+ftmono+ft95-sepvoc_transformer-tiny11-align_2022-03-23.zip
...
```



## Model Scores


The repository includes recipes for evaluating MT models and scores coming from systematically running MT benchmarks. 
Each sub directory in `models` corresponds to a specific model type and includes tables of automatic evaluation results.

Currently, we store results for [OPUS-MT models](https://github.com/Helsinki-NLP/Opus-MT) trained on various subsets of [OPUS](https://github.com/Helsinki-NLP/OPUS) and on the compilation distributed in connection with the [Tatoeba translation challenge](https://github.com/Helsinki-NLP/Tatoeba-Challenge/). Recently added are also evaluations of the NLLB model by Meta AI using the integration into the transformers library at huggingface.

```
OPUS-MT-models
Tatoeba-MT-models
facebook
```

The structure corresponds to the repository of OPUS-MT models with separate tables for different evaluation metrics (like BLEU, chrF and COMET):

```
Tatoeba-MT-models/src-trg/model-release-name.bleu-scores.txt
Tatoeba-MT-models/src-trg/model-release-name.spbleu-scores.txt
Tatoeba-MT-models/src-trg/model-release-name.chrf-scores.txt
Tatoeba-MT-models/src-trg/model-release-name.chrf++-scores.txt
Tatoeba-MT-models/src-trg/model-release-name.comet-scores.txt
```

`src` and `trg` typically correspond to source and target language identifiers but may also refer to sets of languages or other characteristics of the model (for example, `gmw` for Western Germanic languages or `de+en+sv` for specific language combinations). The `model-release-name` corresponds to the release name of the model.

There is also another file that combines BLEU and chrF scores together with some other information about the test set and the model (see further down below).

```
Tatoeba-MT-models/src-trg/model-release-name.scores.txt
```

Additional metrics can be added using the same format replacing `metric` in `src-trg/model-release-name.metric-scores.txt` with a descriptive unique name of the metric.

Note that chrF scores should for historical reasons be with decimals and not in percentages as they are given by current versions of sacrebleu. This is to match the implementation of the web interface of the OPUS-MT leaderboard.



### File Formats

Each model score file for each specific evaluation metric follows a very simple format: The file is a plain text file with TAB-separated values in three columns specifying

* the language pair of the benchmark (e.g. `deu-ukr`)
* the name of the benchmark (e.g. `flores200-devtest`)
* the score

As an example, the German - Eastern Slavic languages model [models/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.bleu-scores.txt](models/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.bleu-scores.txt) includes the following lines:

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

Here is an example from [models/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.scores.txt](models/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.scores.txt):

```
deu-bel	flores101-devtest	0.38804	9.6	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	1012	24829
deu-ukr	flores200-devtest	0.53137	24.0	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	1012	22810
deu-ukr	tatoeba-test-v2021-08-07	0.62852	40.8	https://object.pouta.csc.fi/Tatoeba-MT-models/deu-zle/opusTCv20210807_transformer-big_2022-03-19.zip	10319	56287
```


# Related work and links

* [MT-ComparEval](https://github.com/ondrejklejch/MT-ComparEval) with live instances for [WMT submissions](http://wmt.ufal.cz/) and [other experiments](http://mt-compareval.ufal.cz/)
* [compare-mt](https://github.com/neulab/compare-mt) - command-line tool for MT output comparison [pip package](https://pypi.org/project/compare-mt/)
* [intento report on the state of MT](https://inten.to/machine-translation-report-2022/)
