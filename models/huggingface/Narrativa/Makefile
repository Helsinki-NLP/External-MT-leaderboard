# -*-makefile-*-
#
# recipes for running benchmarks with models from the HF model hub
#

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../../

MODEL_HOME       := ${PWD}/..
MODELS           := Narrativa/mbart-large-50-finetuned-opus-en-pt-translation
MODEL            := Narrativa/mbart-large-50-finetuned-opus-en-pt-translation
MODEL_LANGPAIRS  := eng-por



## MODEL_URL: location of the public model (to be stored in the score files)
## MODEL_EVAL_URL: location of the storage space for the evaluation output files
## 	TODO: make sure that this is correct and also saved somewhere!

MODEL_URL       := https://huggingface.co/${MODEL}
MODEL_STORAGE   := https://object.pouta.csc.fi/External-MT-models
MODEL_EVAL_URL  := ${MODEL_STORAGE}/${MODEL}.eval.zip

BATCH_SIZE = 32
MAX_LENGTH = 256


.PHONY: all
all:
	${MAKE} MODEL=Narrativa/mbart-large-50-finetuned-opus-en-pt-translation \
		MODEL_LANGPAIRS=eng-por SRCID=en_XX TRGID=pt_XX eval-model
	${MAKE} MODEL=Narrativa/mbart-large-50-finetuned-opus-pt-en-translation \
		MODEL_LANGPAIRS=por-eng TRGID=en_XX SRCID=pt_XX eval-model

include ${REPOHOME}build/config.mk
include ${REPOHOME}build/eval.mk

.PHONY: fetch-model
fetch-model:
	@echo "nothing to be done"


SRCID ?= en_XX
TRGID ?= pt_XX

.PHONY: translate
translate: ${SYSTEM_OUTPUT}

${SYSTEM_OUTPUT}: ${TESTSET_SRC}
	echo "create $@"
	mkdir -p $(dir $@)
	mkdir -p ${MODEL_DIR}
	find ${MODEL_DIR} -name '*.${LANGPAIR}.compare' -exec cat {} \; |\
	../../tools/find-missing-translations.pl -i $< -o $@.found > $@.missing
	module load pytorch && python3 ../translate.py \
		-m ${MODEL} -b ${BATCH_SIZE} -l ${MAX_LENGTH} \
		-i ${SRCID} -o ${TRGID} < $@.missing > $@.translated
	../../tools/merge-with-missing-translations.pl \
		-i $@.missing -t $@.translated < $@.found > $@
	rm -f $@.found $@.missing $@.translated

