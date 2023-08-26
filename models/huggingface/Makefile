# -*-makefile-*-
#
# recipes for running benchmarks with models from the HF model hub
#


## the file with all the models we can run
## NEW: skip mbart-based systems because of the lang-ID mess

SKIP_MODELS = | egrep -v '(mbart|bert2bert|nllb-200-3.3B)'

MODELS_FILE      := output/pipeline_models_rev.csv
# MODELS         := $(shell tail -n +2 < ${MODELS_FILE} | cut -f1 -d, ${SKIP_MODELS} | sort -u)
MODELS           := $(patsubst %,huggingface/%,\
			$(sort $(shell tail -n +2 < ${MODELS_FILE} | cut -f1 -d, ${SKIP_MODELS})))
MODELS_INFO      := $(shell tail -n +2 < ${MODELS_FILE} ${SKIP_MODELS})
MODEL_INFO       ?= $(firstword ${MODELS_INFO})


## get information about a specific model
##  - MODEL         = ORGANISATION/MODELNAME
##  - MODEL_SRCLANG = source language used on HF
##  - MODEL_SRCLANG = target language used on HF

COMMA            := ,
PWD              := ${shell pwd}
MODEL            := $(patsubst %,huggingface/%,$(word 1,$(subst ${COMMA}, ,${MODEL_INFO})))
MODEL_SRCLANG    := $(word 2,$(subst ${COMMA}, ,${MODEL_INFO}))
MODEL_TRGLANG    := $(word 3,$(subst ${COMMA}, ,${MODEL_INFO}))


## translate the HF SRCID and TRGID to 3-letter codes we use for our testsets

TESTSET_SRCLANG  := $(shell iso639 -3 -k ${MODEL_SRCLANG})
TESTSET_TRGLANG  := $(shell iso639 -3 -k ${MODEL_TRGLANG})
MODEL_LANGPAIRS  := ${TESTSET_SRCLANG}-${TESTSET_TRGLANG}


## MODEL_URL: location of the model within this repo relative to models/
## MODEL_STORAGE: bucket for evaluation output zip-files
## MODEL_EVAL_URL: location of the storage space for the evaluation output files

MODEL_URL       := $(patsubst huggingface/%,https://huggingface.co/%,${MODEL})


## batch size and maximum length when decoding with transformer pipelines

BATCH_SIZE = 16
MAX_LENGTH = 500

include ../../build/config.mk
include ../../build/eval.mk


.PHONY: all
all: ${MODELS_INFO}
	${MAKE} pack-all-model-scores

.PHONY: ${MODELS_INFO}
${MODELS_INFO}:
	-${MAKE} MODEL_INFO=$@ eval-hf-model

.PHONY: pack-all-model-scores
pack-all-model-scores: ${MODELS}

.PHONY: ${MODELS}
${MODELS}: pack-model-scores

eval-hf-model:
	@echo "evaluate ${MODEL} ${LANGPAIR} (${MODEL_SRCLANG},${MODEL_TRGLANG}) ${SRC} ${TRG}"
	${MAKE} fetch
	${MAKE} eval-langpairs
	${MAKE} cleanup


## reduce batch-size and max length to be able to run big models
.PHONY: all-big
all-big:
	${MAKE} BATCH_SIZE=2 MAX_LENGTH=256 all

.PHONY: fetch-model
fetch-model:
	@echo "nothing to be done"

.PHONY: translate
translate: ${SYSTEM_OUTPUT}

${SYSTEM_OUTPUT}: ${TESTSET_SRC}
	echo "create $@"
	mkdir -p $(dir $@)
	mkdir -p ${MODEL_DIR}
	find ${MODEL_DIR} -name '*.${LANGPAIR}.compare' -exec cat {} \; |\
	../../tools/find-missing-translations.pl -i $< -o $@.found > $@.missing
	module load pytorch && python3 translate.py \
		-m $(patsubst huggingface/%,%,${MODEL}) \
		-b ${BATCH_SIZE} -l ${MAX_LENGTH} \
		-i ${MODEL_SRCLANG} -o ${MODEL_TRGLANG} < $@.missing > $@.translated
	../../tools/merge-with-missing-translations.pl \
		-i $@.missing -t $@.translated < $@.found > $@
	rm -f $@.found $@.missing $@.translated

