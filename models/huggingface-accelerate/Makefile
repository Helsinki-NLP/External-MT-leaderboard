# -*-makefile-*-
#
# recipes for running benchmarks with models from the HF model hub
#

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

MODEL_HOME       := ${PWD}
MODELS_FILE      := output/pipeline_models_rev.csv
MODELS           := $(shell tail -n +2 < ${MODELS_FILE} | cut -f1 -d, | sort -u)
MODEL            ?= $(firstword ${MODELS})
MODEL_LANGPAIRS  := $(shell grep '${MODEL}' ${MODELS_FILE} | \
			cut -f2,3 -d, | sort -u | tr "," '-' | xargs iso639 -3 -k -p)



## MODEL_URL: location of the public model (to be stored in the score files)
## MODEL_EVAL_URL: location of the storage space for the evaluation output files
## 	TODO: make sure that this is correct and also saved somewhere!

MODEL_URL       := huggingface/${MODEL}
MODEL_STORAGE   := https://object.pouta.csc.fi/External-MT-models
MODEL_EVAL_URL  := ${MODEL_STORAGE}/${MODEL}.eval.zip



.PHONY: all
all: eval-models

include ../lib/config.mk
include ../lib/eval.mk

.PHONY: fetch-model
fetch-model:
	( module load git git-lfs; \
	  mkdir -p $(dir ${MODEL}); \
	  cd $(dir ${MODEL}); \
	  git clone ${MODEL_URL}; \
	  cd ${MODEL}; \
	  git-lfs install; \
	  git pull )

.PHONY: translate
translate: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output

${WORK_DIR}/%.${LANGPAIR}.output: ${TESTSET_DIR}/%.${SRC} ${TESTSET_DIR}/%.${TRG}
	echo "create $@"
	mkdir -p $(dir $@)
	mkdir -p ${MODEL_DIR}
	find ${MODEL_DIR} -name '*.${LANGPAIR}.compare' -exec cat {} \; |\
	../../tools/find-missing-translations.pl -i $< -o $@.found > $@.missing
	module load pytorch && python3 translate.py -m ${MODEL} \
		-i ${SRC} -o ${TRG} < $@.missing > $@.translated
	../../tools/merge-with-missing-translations.pl \
		-i $@.missing -t $@.translated < $@.found > $@
	rm -f $@.found $@.missing $@.translated

