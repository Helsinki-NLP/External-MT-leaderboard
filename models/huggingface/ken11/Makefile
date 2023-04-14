# -*-makefile-*-
#
# recipes for running benchmarks with models from the HF model hub
#

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

MODEL_HOME       := ${PWD}/..
MODELS           := ken11/mbart-ja-en
MODEL_LANGPAIRS  := jpn-eng



## MODEL_URL: location of the public model (to be stored in the score files)
## MODEL_EVAL_URL: location of the storage space for the evaluation output files
## 	TODO: make sure that this is correct and also saved somewhere!

MODEL_URL       := https://huggingface.co/${MODEL}
MODEL_STORAGE   := https://object.pouta.csc.fi/External-MT-models
MODEL_EVAL_URL  := ${MODEL_STORAGE}/${MODEL}.eval.zip

BATCH_SIZE = 32
MAX_LENGTH = 256


.PHONY: all
all: eval-model

include ../lib/config.mk
include ../lib/eval.mk

.PHONY: fetch-model
fetch-model:
	@echo "nothing to be done"

.PHONY: translate
translate: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output


SRCID ?= en_XX
TRGID ?= ja_XX


${WORK_DIR}/%.${LANGPAIR}.output: ${TESTSET_DIR}/%.${SRC} ${TESTSET_DIR}/%.${TRG}
	echo "create $@"
	mkdir -p $(dir $@)
	mkdir -p ${MODEL_DIR}
	find ${MODEL_DIR} -name '*.${LANGPAIR}.compare' -exec cat {} \; |\
	../../tools/find-missing-translations.pl -i $< -o $@.found > $@.missing
	module load pytorch && python3 ../huggingface/translate.py \
		-m ${MODEL} -b ${BATCH_SIZE} -l ${MAX_LENGTH} \
		-i ${SRCID} -o ${TRGID} < $@.missing > $@.translated
	../../tools/merge-with-missing-translations.pl \
		-i $@.missing -t $@.translated < $@.found > $@
	rm -f $@.found $@.missing $@.translated


