# -*-makefile-*-
#
# register scores in leaderboards
#  - create files to be added for each language pair and benchmark that we need to update
#  - files have extension 'unsorted.txt' and need to be merged with the leaderbaord file
#  - check top-level makefile about recipes to merge/update
#  - a flag will be created to mark that scores are registered
#

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../

ALL_SOURCES      := $(filter-out lib,$(notdir ${shell find . -maxdepth 1 -mindepth 2 -type d}))

SOURCE     ?= huggingface/facebook
MODEL_HOME ?= ${SOURCE}
MODEL      ?= nllb-200-distilled-600M

include lib/config.mk


## scores that need to be registered (stored in temporary score files)
## if ALL_MODELS is set: check all model directories
## if ALL_MODELS is not set: take only the current model dir

ifdef ALL_MODELS
  SCOREFILES := ${shell find ${MODEL_HOME}/ -name '*-scores.txt'}
else
  SCOREFILES := ${wildcard ${MODEL_DIR}.*-scores.txt}
endif


## if ALL_MODELSOURCE is set: find all *.scores.txt files
## to get a list of all *.eval.zip files (a very long list)

ifdef ALL_MODELSOURCES
  MODEL_EVALZIPS := $(patsubst %.scores.txt,%.eval.zip,${shell find . -name '*.scores.txt' -printf "%P\n"})
endif

MODEL_EVALZIPS  ?= $(patsubst %,%.eval.zip,$(sort $(basename ${SCOREFILES:.txt=})))
SCOREFILES_DONE := ${SCOREFILES:.txt=.registered}


.PHONY: all
all: register-all
	${MAKE} upload-all

.PHONY: register-all
register-all:
	for s in ${ALL_SOURCES}; do \
	  ${MAKE} SOURCE=$$s ALL_MODELS=1 register; \
	done

.PHONY: register-contributed
register-contributed:
	${MAKE} SOURCE=unverified ALL_MODELS=1 register


## register scores from all models in current source in leaderboards
.PHONY: register-scores
register-scores:
	${MAKE} ALL_MODELS=1 register

## register scores from current model in leaderboards
.PHONY: register
register: ${SCOREFILES_DONE}
ifdef ALL_MODELS
	find ${MODEL_HOME}/ -name '*.txt' | xargs git add
	find ${MODEL_HOME}/ -name '*.registered' | xargs git add
	-find ${MODEL_HOME}/ -name '*.logfiles' | xargs git add
else
	git add ${MODEL_DIR}.*.txt
	git add ${MODEL_DIR}.*.registered
	-git add ${MODEL_DIR}.logfiles
endif

## register the scores for the current model
## (scores will be added to some temporary files sorted by language pair and benchmark)
## NOTE: this removes langIDs from newstest sets to avoid confusion and duplicates

${MODEL_HOME}/%-scores.registered: ${MODEL_HOME}/%-scores.txt
	@echo "register scores from ${patsubst ${MODEL_HOME}/%,%,$<}"
	@cat $< | perl -e 'while (<>){ chomp; @a=split(/\t/); $$a[1]=~s/^(news.*)\-[a-z]{4}/$$1/; system "mkdir -p ${LEADERBOARD_DIR}/$$a[0]/$$a[1]"; open C,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/$(patsubst .%,%,$(suffix $(basename $<))).$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; $$m="$(shell cut -f5 $(basename $(basename $<)).scores.txt | head -1)";if ($$a[2] && $$m){print C "$$a[2]\t$$m\n";} close C; }'
	@touch $@




STORAGE_BUCKET = External-MT-leaderboard
STORAGE_URL   := https://object.pouta.csc.fi/${STORAGE_BUCKET}

.PHONY: upload upload-eval-files
upload upload-eval-files:
	which a-get
	if [ `find .${MODEL_HOME} -size -5G -name '*.eval.zip' | wc -l` -gt 0 ]; then \
	  cd .. && find models/${MODEL_HOME} -size -5G -name '*.eval.zip' | \
		xargs swift upload ${STORAGE_BUCKET} --changed --skip-identical; \
	fi
	if [ `find .${MODEL_HOME} -size +5G -name '*.eval.zip' | wc -l` -gt 0 ]; then \
	  cd .. && find models/${MODEL_HOME} -size +5G -name '*.eval.zip' | \
		xargs swift upload ${STORAGE_BUCKET} --changed --skip-identical --use-slo --segment-size 5G; \
	fi
	swift post ${STORAGE_BUCKET} --read-acl ".r:*"

# -size +5G

.PHONY: upload-all
upload-all:
	which a-get
	if [ `find . -size -5G -name '*.eval.zip' | wc -l` -gt 0 ]; then \
	  cd .. && find models/ -size -5G -name '*.eval.zip' | \
		xargs swift upload ${STORAGE_BUCKET} --changed --skip-identical; \
	fi
	if [ `find . -size +5G -name '*.eval.zip' | wc -l` -gt 0 ]; then \
	  cd .. && find models/ -size +5G -name '*.eval.zip' | \
		xargs swift upload ${STORAGE_BUCKET} --changed --skip-identical --use-slo --segment-size 5G; \
	fi
	swift post ${STORAGE_BUCKET} --read-acl ".r:*"

.PHONY: upload-dryrun upload-eval-files-dryrun
upload-dryrun upload-eval-files-dryrun:
	@echo 'which a-get'
	@echo "cd .. && find models/${MODEL_HOME} -name '*.eval.zip' | xargs swift upload ${STORAGE_BUCKET}"




.PHONY: download download-eval-files
download download-eval-files: ${MODEL_EVALZIPS}

.PHONY: download-all
download-all:
	${MAKE} ALL_MODELSOURCES=1 download

%.eval.zip: %.scores.txt
	-wget -qq -O $@ ${STORAGE_URL}/models/$@
