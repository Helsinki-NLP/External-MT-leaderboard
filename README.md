
# External MT leaderboard

A repository of scores and leaderboard for MT models and benchmarks.

* [model scores for various benchmarks](models)
* [leaderboards per benchmark](scores)
* [recipes for automatic model evaluation](models)
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
* the model name

For example, the BLEU-score leaderboard for the Flores200 devtest benchmark in German-English is stored in [scores/deu-eng/flores200-devtest/bleu-scores.txt](scores/deu-eng/flores200-devtest/bleu-scores.txt) and includes lines like:

```
45.1	huggingface/facebook/wmt19-de-en
43.5	huggingface/facebook/nllb-200-1.3B
43.4	huggingface/facebook/nllb-200-distilled-1.3B
41.9	huggingface/allenai/wmt19-de-en-6-6-big
41.2	huggingface/facebook/nllb-200-distilled-600M
40.7	huggingface/facebook/m2m100_1.2B
38.7	huggingface/allenai/wmt19-de-en-6-6-base
34.4	huggingface/facebook/m2m100_418M
...
```

The best performaning models for each benchmark for a given language pair are listed with the following format: TAB-separated plain text files with 3 columns:

* the name of the benchmark
* the top score among all models
* the name of the top-scoring model

To give an example, the top BLEU score for German-English benchmarks is stored in [scores/deu-eng/top-bleu-scores.txt](scores/deu-eng/top-bleu-scores.txt) with lines like:

```
flores101-devtest	45.1	huggingface/facebook/wmt19-de-en
flores200-devtest	45.1	huggingface/facebook/wmt19-de-en
multi30k_task2_test_2016	4.8	huggingface/facebook/nllb-200-3.3B
multi30k_test_2016_flickr	43.9	huggingface/facebook/nllb-200-1.3B
multi30k_test_2017_flickr	45.4	huggingface/facebook/wmt19-de-en
multi30k_test_2017_mscoco	37.0	huggingface/facebook/nllb-200-3.3B
multi30k_test_2018_flickr	40.4	huggingface/facebook/wmt19-de-en
news2008	29.8	huggingface/facebook/wmt19-de-en
newssyscomb2009	29.9	huggingface/allenai/wmt19-de-en-6-6-big
newstest2009	28.3	huggingface/facebook/wmt19-de-en
newstest2010	34.3	huggingface/facebook/wmt19-de-en
newstest2011	29.5	huggingface/facebook/wmt19-de-en
newstest2012	33.1	huggingface/facebook/wmt19-de-en
...
```


To make it easier to compare model performance, we also keep model lists sorted by scores averaged over a selected number of benchmarks. Those files start with a line that list the selected benchmarks used for computing the score and the following lines follow the standard leaderboard file format with TAB-separated values for the (averaged score and the download link of the model. For example, [scores/deu-ukr/avg-bleu-scores.txt](scores/deu-ukr/avg-bleu-scores.txt) starts like this:


```
flores multi30k news tatoeba
44.655	huggingface/facebook/wmt19-de-en
43.2980769230769	huggingface/facebook/nllb-200-3.3B
43.1928571428571	huggingface/facebook/nllb-200-distilled-1.3B
43.1416666666667	huggingface/facebook/nllb-200-1.3B
41.41625	huggingface/allenai/wmt19-de-en-6-6-big
...
```



## Model Scores


The repository includes recipes for evaluating MT models and scores coming from systematically running MT benchmarks. 
Each sub directory in `models` corresponds to a specific model type and includes tables of automatic evaluation results.

Currently, we store results for models that are available from the [huggingface model hub](https://huggingface.co/models) provided by various users of the platform, for example

```
allanai
facebook
...
```

The structure corresponds to the repository of OPUS-MT models with separate tables for different evaluation metrics (like BLEU, chrF and COMET):

```
models/provider/model-release-name.bleu-scores.txt
models/provider/model-release-name.spbleu-scores.txt
models/provider/model-release-name.chrf-scores.txt
models/provider/model-release-name.chrf++-scores.txt
models/provider/model-release-name.comet-scores.txt
```

The `provider` specifies the name of the provider and may include some sub-structures like `huggingface/facebook` (models provided by facebook/meta AI through huggingface). The `model-release-name` corresponds to the release name of the model (for example `nllb-200-1.3B`).

There is also another file that combines BLEU and chrF scores together with some other information about the test set and the model (see further down below).

```
models/provider/model-release-name.scores.txt
```

Additional metrics can be added using the same format replacing `metric` in `model-release-name.metric-scores.txt` with a descriptive unique name of the metric.

Note that chrF scores should for historical reasons be with decimals and not in percentages as they are given by current versions of sacrebleu. This is to match the implementation of the web interface of the OPUS-MT leaderboard.



### File Formats

Each model score file for each specific evaluation metric follows a very simple format: The file is a plain text file with TAB-separated values in three columns specifying

* the language pair of the benchmark (e.g. `eng-rus`)
* the name of the benchmark (e.g. `flores200-devtest`)
* the score

As an example, the English - Russian wmt19 model from facebook [models/huggingface/facebook/wmt19-en-ru.bleu-scores.txt](models/huggingface/facebook/wmt19-en-ru.bleu-scores.txt) includes the following lines:

```
eng-rus	flores101-devtest	30.4
eng-rus	flores200-devtest	30.4
eng-rus	newstest2012	36.7
eng-rus	newstest2013	29.7
eng-rus	newstest2014	43.1
eng-rus	newstest2015	40.3
eng-rus	newstest2016	35.8
eng-rus	newstest2017	42.2
eng-rus	newstest2018	34.9
eng-rus	newstest2019	33.4
eng-rus	newstest2020	23.8
eng-rus	tatoeba-test-v2020-07-28	41.8
eng-rus	tatoeba-test-v2021-03-30	40.6
eng-rus	tatoeba-test-v2021-08-07	40.8
eng-rus	tico19-test	28.9
```


The only file that differs from this general format is the `src-trg/model-release-name.scores.txt` that combines BLEU and chrF scores. In addition to the scores, this file also includes

* the link to the actual model for downloading
* the size of the benchmark in terms of the number of sentences
* the size of the benchmark in terms of the number of tokens

Here is an example from [models/huggingface/facebook/wmt19-en-ru.scores.txt](models/huggingface/facebook/wmt19-en-ru.scores.txt):

```
eng-rus	flores101-devtest	0.56716	30.4	https://huggingface.co/facebook/wmt19-en-ru	1012	23295
eng-rus	flores200-devtest	0.56716	30.4	https://huggingface.co/facebook/wmt19-en-ru	1012	23295
eng-rus	newstest2012	0.60413	36.7	https://huggingface.co/facebook/wmt19-en-ru	3003	64790
eng-rus	newstest2013	0.54522	29.7	https://huggingface.co/facebook/wmt19-en-ru	3000	58560
eng-rus	newstest2014	0.66648	43.1	https://huggingface.co/facebook/wmt19-en-ru	3003	61603
eng-rus	newstest2015	0.63969	40.3	https://huggingface.co/facebook/wmt19-en-ru	2818	55915
eng-rus	newstest2016	0.6048	35.8	https://huggingface.co/facebook/wmt19-en-ru	2998	62014
eng-rus	newstest2017	0.65147	42.2	https://huggingface.co/facebook/wmt19-en-ru	3001	60253
eng-rus	newstest2018	0.60928	34.9	https://huggingface.co/facebook/wmt19-en-ru	3000	61907
eng-rus	newstest2019	0.56979	33.4	https://huggingface.co/facebook/wmt19-en-ru	1997	48147
eng-rus	newstest2020	0.51394	23.8	https://huggingface.co/facebook/wmt19-en-ru	2002	47083
eng-rus	tatoeba-test-v2020-07-28	0.62986	41.8	https://huggingface.co/facebook/wmt19-en-ru	10000	66872
eng-rus	tatoeba-test-v2021-03-30	0.62753	40.6	https://huggingface.co/facebook/wmt19-en-ru	15118	101983
eng-rus	tatoeba-test-v2021-08-07	0.62707	40.8	https://huggingface.co/facebook/wmt19-en-ru	19425	134296
eng-rus	tico19-test	0.54915	28.9	https://huggingface.co/facebook/wmt19-en-ru	2100	55843
```


# Related work and links

* [MT-ComparEval](https://github.com/ondrejklejch/MT-ComparEval) with live instances for [WMT submissions](http://wmt.ufal.cz/) and [other experiments](http://mt-compareval.ufal.cz/)
* [compare-mt](https://github.com/neulab/compare-mt) - command-line tool for MT output comparison [pip package](https://pypi.org/project/compare-mt/)
* [intento report on the state of MT](https://inten.to/machine-translation-report-2022/)
