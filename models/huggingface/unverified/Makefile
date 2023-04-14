# -*-makefile-*-
#
# template for evaluating user-contributed translations
#
# What you need to do is
#
#   * set the model-specific variables MODELS, MODEL_LANGPAIRS, MODEL_URL
#   * place the translations into a temporary work directory
#   * run make with appropriate settings
#
#-----------------------------------------------------------------------------
#
# Example: evaluate a user contributed translation of flores101-dev from English to Danish
#          for a user <username> and model <modelname>
#
#   mkdir -p work/unverified/username/modelname
#   cp translation-file.txt work/unverified/username/modelname/flores101-dev.eng-dan.output
#
#   make USER_NAME=username USER_MODEL=modelname \
#        TESTSETS=flores101-dev LANGPAIR=eng-dan \
#   eval
#
#
# After evaluating all benchmarks, create model score files with:
#
#   make USER_NAME=username USER_MODEL=modelname \
#        MODEL_URL=http://path/to/my/wonderful-model \
#   eval-model-files
#
#
# and finally pack everything together:
#
#   make USER_NAME=username USER_MODEL=modelname pack-model-scores
#
#-----------------------------------------------------------------------------

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

METRICS := bleu spbleu chrf chrf++

## specify all models

MODEL_HOME  := ${PWD}/..
USER_NAME   ?= testuser
USER_MODEL  ?= testmodel
MODELS      := $(patsubst %,unverified/${USER_NAME}/%,${USER_MODEL})
MODEL       ?= $(firstword ${MODELS})



## MODEL_URL: location of the public model (to be stored in the score files)
## MODEL_EVAL_URL: location of the storage space for the evaluation output files

MODEL_URL       := https://location.of.my.model/storage/${MODEL}
MODEL_STORAGE   := https://object.pouta.csc.fi/External-MT-models
MODEL_EVAL_URL  := ${MODEL_STORAGE}/${MODEL}.eval.zip

SKIP_NEW_EVALUATION := 1

.PHONY: all
all:
	${MAKE} -s fetch-model-scores
	${MAKE} -s eval
	${MAKE} -s update-eval-files
	${MAKE} -s pack-model-scores



## all kinds of common evaluation recipes and variables
## no changes needed (hopefully)


include ../lib/config.mk
include ../lib/eval.mk

.PHONY: fetch-model
fetch-model:
	@echo "no model to fetch"
