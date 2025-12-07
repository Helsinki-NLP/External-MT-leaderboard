
PWD := ${shell pwd}
SHELL := bash

METRICS := bleu spbleu chrf chrf++


MODEL_STORAGE  := https://github.com/mozilla/firefox-translations-models/blob/main/models
MODEL_RAWGIT   := https://raw.githubusercontent.com/mozilla/firefox-translations-models/refs/heads/main/models
MODEL_TYPES    := base-memory base tiny
MODEL_LIST     := ${MODEL_RAWGIT}/by-hash.json


MODELS := $(shell wget -q -O - ${MODEL_LIST} | grep json | cut -f4 -d\" | cut -f 2,3 -d/ | tr '/' '_')
MODEL  ?= ${firstword ${MODELS}}

# MODEL_VERSIONS := $(shell wget -q -O - ${MODEL_LIST} | grep json | cut -f2 -d\")
# MODEL_VERSION  ?= ${firstword ${MODEL_VERSIONS}}

MODEL_INFO_FILE  := $(patsubst %,%.info,${MODEL})
MODEL_INFO_FILES := $(patsubst %,%.info,${MODELS})

MODEL_HOME   := ${PWD}
MODEL_URL    := ${MODEL_STORAGE}/$(subst _,/,$(notdir ${MODEL}))
MODEL_RAWURL := ${MODEL_RAWGIT}/$(subst _,/,$(notdir ${MODEL}))


WORK_HOME  := ${PWD}/work
WORK_DIR   := ${WORK_HOME}/${MODEL}

#-------------------------------------------------
# get supported source and target languages
#-------------------------------------------------

# original model languages in 2-letter codes


MODEL_TYPE      := $(word 1,$(subst _, ,$(notdir $(MODEL))))
MODEL_LANGPAIR  := $(word 2,$(subst _, ,$(notdir $(MODEL))))
MODEL_SRCLANG   := $(shell echo ${MODEL_LANGPAIR} | sed 's/\(..\)$$//')
MODEL_TRGLANG   := $(shell echo ${MODEL_LANGPAIR} | sed 's/^\(..\)//')
MODEL_ORIGDIR   := ${PWD}/firefox-translations-models/models/${MODEL_TYPE}/${MODEL_LANGPAIR}


# languages in 3-letter codes
# (note that all variables can include more than one value)

SRC_LANGS       := $(shell iso639 -3 $(MODEL_SRCLANG))
TRG_LANGS       := $(shell iso639 -3 $(MODEL_TRGLANG))
MODEL_LANGPAIRS := $(SRC_LANGS)-$(TRG_LANGS)


include ../../build/config.mk
include ../../build/eval.mk


#-------------------------------------------------
## make all evaluation zip-files
#-------------------------------------------------

.PHONY: all
all: eval-models

#-------------------------------------------------
# create model-info-file
#-------------------------------------------------

.PHONY: model-info
model-info: ${MODEL_INFO_FILE}

.PHONY: all-model-infos
all-model-infos: ${MODEL_INFO_FILES}

${MODEL_INFO_FILES}: %.info:
	mkdir -p $@.d
	-wget -qq -O $@.d/model.npz model.been.intgemm.alphas.bin.gz
	-../../tools/model_info.py --summary --model $@.d/*.npz > $@
	echo "source languages: ${SRC_LANGS}" >> $@
	echo "target languages: ${TRG_LANGS}" >> $@
	echo "nr_source languages: 1" >> $@
	echo "nr_target languages: 1" >> $@
	rm -fr $@.d

#-------------------------------------------------
# fetch model and get supported languages
#-------------------------------------------------




## fetch only the model
.PHONY: fetch-model
fetch-model: ${WORK_DIR}/model

${WORK_DIR}/model: firefox-translations-models
	mkdir -p $@
	rsync ${MODEL_ORIGDIR}/* $@/
	gunzip -f $@/*.gz



.PHONY: remove-model
remove-model:
	rm -fr ${WORK_DIR}/model

firefox-translations-models:
	module load git-lfs && \
	git clone https://github.com/mozilla/firefox-translations-models.git

#-------------------------------------------------
# create output file (translation)
#-------------------------------------------------

.PHONY: output
output: ${SYSTEM_OUTPUT}

${SYSTEM_OUTPUT}: ${TESTSET_SRC}
	@${MAKE} -s firefox-translations-models
	@echo "... create $(MODEL)/$(notdir $@)"
	@mkdir -p $(dir $@) ${MODEL_DIR}
	@echo "Translating sentences from $(notdir $<) to ${TRG}"          > $@.log
	@echo ""                                                          >> $@.log
	if [ -s ${TESTSET_SRC} ]; then \
	    echo " - nr of sentences to translate:"                       >> $@.log; \
	    cat $< | wc -l                                                >> $@.log; \
	    echo " - size of testset to translate:"                       >> $@.log; \
	    cat ${TESTSET_SRC} | wc                                       >> $@.log; \
	    export APP_PATH="${BROWSERMT_DECODE} ${MARIAN_DECODER_FLAGS}"; \
	    export MODEL_DIR=${WORK_DIR}/model; \
	    export SRC=${MODEL_SRCLANG}; \
	    export TRG=${MODEL_TRGLANG}; \
	    ${LOAD_ENV} && ${MONITOR} ./bergamot.sh < $< > $@ 2>> $@.log; \
	fi
	@mv $@.log $(patsubst %.output,%.log,$@)

