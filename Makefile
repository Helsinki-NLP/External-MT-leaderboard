# -*-makefile-*-


PWD      := ${shell pwd}
REPOHOME := ${PWD}/


## directory with leaderboard files depending on the source of the models
##   - default = OPUS-MT models (stored in scores/)
##   - external models (stored in external-scores/)
##   - contributed tanslations (stored in user-scores/)
##   - all scores merged (stored in merged-scores/)

ifdef LANGPAIRDIR
  LEADERBOARD_DIR = $(firstword $(subst /, ,${LANGPAIRDIR}))
  LANGPAIR = $(lastword $(subst /, ,${LANGPAIRDIR}))
endif

ifeq (${MODELSOURCE},external)
  LEADERBOARD_DIR = external-scores
else ifeq (${MODELSOURCE},contributed)
  LEADERBOARD_DIR = user-scores
else ifeq (${MODELSOURCE},all)
  LEADERBOARD_DIR = merged-scores
else
  LEADERBOARD_DIR = scores
endif


## all language pairs and all evaluation metrics
LANGPAIRS  := $(sort $(notdir $(wildcard ${LEADERBOARD_DIR}/*-*)))
METRICS    := bleu spbleu chrf chrf++ comet


## default language pair and metric

LANGPAIR   ?= deu-eng
METRIC     ?= $(firstword ${METRICS})


## all score files for the selected metric

METRICFILES = ${sort ${wildcard ${LEADERBOARD_DIR}/${LANGPAIR}/*/${METRIC}-scores.txt}}


## UPDATE_SCORE_DIRS   = directory that contains new scores
## UPDATE_LEADERBOARDS = list of leader boards that need to be updated
##    (for all language pairs if UPDATE_ALL_LEADERBOARDS is set)
##    (for the selected LANGPAIR otherwise)

ifeq (${UPDATE_ALL_LEADERBOARDS},1)
  UPDATE_SCORE_DIRS := $(sort $(dir ${wildcard ${LEADERBOARD_DIR}/*/*/*.unsorted.txt}))
  UPDATE_LANGPAIRS  := $(sort $(dir $(patsubst ${LEADERBOARD_DIR}/%/,%,${UPDATE_SCORE_DIRS})))
else
  UPDATE_SCORE_DIRS := $(sort $(dir ${wildcard ${LEADERBOARD_DIR}/${LANGPAIR}/*/*.unsorted.txt}))
  UPDATE_LANGPAIRS  := ${LANGPAIR}
endif
UPDATE_LEADERBOARDS := $(foreach m,${METRICS},$(patsubst %,%$(m)-scores.txt,${UPDATE_SCORE_DIRS}))



LANGPAIR_LISTS  := scores/langpairs.txt external-scores/langpairs.txt user-scores/langpairs.txt
BENCHMARK_LISTS := scores/benchmarks.txt external-scores/benchmarks.txt user-scores/benchmarks.txt

.PHONY: all
all: ${LEADERBOARD_DIR}
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	${MAKE} -s refresh-leaderboards
	${MAKE} -s released-models.txt release-history.txt
	${MAKE} -s ${LANGPAIR_LISTS} ${BENCHMARK_LISTS}
	find ${LEADERBOARD_DIR}/ -name '*.txt' | grep -v unsorted | xargs git add

USER_CONTRIBUTED_FILES  := $(shell find models/unverified -type f -name '*.output')
USER_CONTRIBUTED_FILE   ?= $(firstword ${USER_CONTRIBUTED_FILES})
CONTRIBUTED_USERNAME    := $(word 5,$(subst /, ,${USER_CONTRIBUTED_FILE}))
CONTRIBUTED_MODEL       := $(patsubst models/unverified/work/unverified/${CONTRIBUTED_USERNAME}/%/,%,\
				$(dir ${USER_CONTRIBUTED_FILE}))
CONTRIBUTED_MODEL_YAML  := models/unverified/${CONTRIBUTED_USERNAME}/${CONTRIBUTED_MODEL}.yml
CONTRIBUTED_TRANSLATION := $(notdir ${USER_CONTRIBUTED_FILE})
CONTRIBUTED_TRANSLATION_TESTSET  := $(basename $(basename ${CONTRIBUTED_TRANSLATION}))
CONTRIBUTED_TRANSLATION_LANGPAIR := $(patsubst .%,%,$(suffix $(basename ${CONTRIBUTED_TRANSLATION})))

ifneq ($(wildcard ${CONTRIBUTED_MODEL_YAML}),)
  CONTRIBUTED_MODEL_WEBSITE := $(shell grep 'website:' ${CONTRIBUTED_MODEL_YAML} | cut -f2- -d: | sed 's/^ *//')
endif


## evaluate a new user-contributed file
## register the scores
## update user-score leaderboards
##
## NOTE: don't allow concurrent jobs because of racing conditions!

eval-userfile:
ifneq ($(wildcard ${USER_CONTRIBUTED_FILE}),)
	@echo ${CONTRIBUTED_MODEL_YAML}
	@echo ${USER_CONTRIBUTED_FILE}
	@echo ${CONTRIBUTED_USERNAME}
	@echo ${CONTRIBUTED_MODEL}
	@echo ${CONTRIBUTED_TRANSLATION_TESTSET}
	@echo ${CONTRIBUTED_TRANSLATION_LANGPAIR}
	@echo ${CONTRIBUTED_MODEL_WEBSITE}
	${MAKE} -C models/unverified \
		USER_NAME='${CONTRIBUTED_USERNAME}' \
		USER_MODEL='${CONTRIBUTED_MODEL}' \
		TESTSETS='${CONTRIBUTED_TRANSLATION_TESTSET}' \
		LANGPAIR='${CONTRIBUTED_TRANSLATION_LANGPAIR}' \
		MODEL_URL='${CONTRIBUTED_MODEL_WEBSITE}' \
	all
	rm -f ${USER_CONTRIBUTED_FILE}
	${MAKE} -C models \
		SOURCE=unverified \
		MODEL='${CONTRIBUTED_USERNAME}/${CONTRIBUTED_MODEL}' \
	register
	${MAKE} -s all-contributed
else
	@echo "No file to be evaluated!"
endif



## fetch all evaluation zip file

.PHONY: fetch-zipfiles
fetch-zipfiles:
	${MAKE} -C models download-all




.PHONY: all-external
all-external:
	find external-scores -name '*unsorted*' -empty -delete
	${MAKE} -s MODELSOURCE=external update-all-leaderboards
	${MAKE} -s external-scores/langpairs.txt external-scores/benchmarks.txt
	find external-scores/ -name '*.txt' | grep -v unsorted | xargs git add

.PHONY: all-contributed
all-contributed:
	find user-scores -name '*unsorted*' -empty -delete
	${MAKE} -s MODELSOURCE=contributed refresh-leaderboards
	${MAKE} -s user-scores/langpairs.txt user-scores/benchmarks.txt
	find user-scores/ -name '*.txt' | grep -v unsorted | xargs git add


.PHONY: langpair-scores
langpair-scores:
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	@for l in ${UPDATE_LANGPAIRS}; do \
	  echo "extract top/avg scores for $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 top-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 avg-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 model-list; \
	done

.PHONY: all-langpair-scores
all-langpair-scores:
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	@for l in ${LANGPAIRS}; do \
	  echo "extract top/avg scores for $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 top-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 avg-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 model-list; \
	done

.PHONY: all-avg-scores
all-avg-scores:
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	@for l in ${LANGPAIRS}; do \
	  echo "extract avg scores for $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 avg-scores; \
	done

.PHONY: all-top-scores
all-top-scores:
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	@for l in ${LANGPAIRS}; do \
	  echo "extract top scores for $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 top-scores; \
	done

.PHONY: all-model-lists
all-model-lists:
	@find ${LEADERBOARD_DIR} -name '*unsorted*' -empty -delete
	@for l in ${LANGPAIRS}; do \
	  echo "extract model lists $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 model-list; \
	done



# .PHONY: update-leaderboards
# update-leaderboards: langpair-scores
#	${MAKE} langpair-scores

.PHONY: update-leaderboards
update-leaderboards: ${UPDATE_LEADERBOARDS}
	@for l in ${UPDATE_LANGPAIRS}; do \
	  echo "extract top/avg scores for $$l"; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 top-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 avg-scores; \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 model-list; \
	done


## update all leaderboards with phony targets for each language pair
## this scales to large lists of language pairs
## but is super-slow ....

UPDATE_LEADERBOARD_TARGETS = $(sort $(patsubst %,%-update-leaderboard,${LANGPAIRS}))

.PHONY: update-all-leaderboards
update-all-leaderboards: $(UPDATE_LEADERBOARD_TARGETS)

.PHONY: $(UPDATE_LEADERBOARD_TARGETS)
$(UPDATE_LEADERBOARD_TARGETS):
	${MAKE} -s LANGPAIR=$(@:-update-leaderboard=) update-leaderboards


## update using a for loop:
## this is much faster but  breaks if the LANGPAIRS becomes too big
## (arghument list too long)

.PHONY: update-all-leaderboards-loop
update-all-leaderboards-loop:
	@for l in ${LANGPAIRS}; do \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 update-leaderboards; \
	done
#	${MAKE} all-langpair-scores

## another solution: use find
.PHONY: update-all-leaderboards-find
update-all-leaderboards-find:
	find ${LEADERBOARD_DIR} -maxdepth 1 -mindepth 1 -type d \
		-exec ${MAKE} -s LANGPAIRDIR={} update-leaderboards \;


.PHONY: sort-updated-leaderboards refresh-leaderboards
sort-updated-leaderboards refresh-leaderboards:
	${MAKE} UPDATE_ALL_LEADERBOARDS=1 update-leaderboards



released-models.txt: scores
	find scores/ -name 'bleu-scores.txt' | xargs cat | cut -f2 | sort -u > $@

release-history.txt: released-models.txt
	cat $< | rev | cut -f3 -d'/' | rev > $@.pkg
	cat $< | rev | cut -f2 -d'/' | rev > $@.langpair
	cat $< | rev | cut -f1 -d'/' | rev > $@.model
	cat $< | sed 's/^.*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)\.zip$$/\1/' > $@.date
	paste $@.date $@.pkg $@.langpair $@.model | sort -r | sed 's/\.zip$$//' > $@
	rm -f $@.langpair $@.model $@.date $@.pkg

.PHONY: model-list
model-list: ${LEADERBOARD_DIR}/${LANGPAIR}/model-list.txt

${LEADERBOARD_DIR}/${LANGPAIR}/model-list.txt: ${METRICFILES}
	find ${dir $@} -name 'bleu-scores.txt' | xargs cut -f2 | sort -u > $@

.PHONY: top-score-file top-scores
top-score-file: ${LEADERBOARD_DIR}/${LANGPAIR}/top-${METRIC}-scores.txt
top-scores:
	@for m in ${METRICS}; do \
	  ${MAKE} -s METRIC=$$m top-score-file; \
	done

.PHONY: avg-score-file avg-scores
avg-score-file: ${LEADERBOARD_DIR}/${LANGPAIR}/avg-${METRIC}-scores.txt
avg-scores:
	@for m in ${METRICS}; do \
	  ${MAKE} -s METRIC=$$m avg-score-file; \
	done

${LEADERBOARD_DIR}/${LANGPAIR}/top-${METRIC}-scores.txt: ${METRICFILES}
	@rm -f $@
	@for f in $^; do \
	  if [ -s $$f ]; then \
	    t=`echo $$f | cut -f3 -d/`; \
	    echo -n "$$t	" >> $@; \
	    head -1 $$f     >> $@; \
	  fi \
	done

${LEADERBOARD_DIR}/${LANGPAIR}/avg-${METRIC}-scores.txt: ${METRICFILES}
	tools/average-scores.pl $^ > $@

${UPDATE_LEADERBOARDS}: ${UPDATE_SCORE_DIRS}
	@if [ -e $@ ]; then \
	  if [ $(words $(wildcard ${@:.txt=}*.unsorted.txt)) -gt 0 ]; then \
	    echo "merge and sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"; \
	    sort -k2,2 -k1,1nr $@                           > $@.old.txt; \
	    cat $(wildcard ${@:.txt=}*.unsorted.txt) | \
	    grep '^[0-9\-]' | sort -k2,2 -k1,1nr            > $@.new.txt; \
	    sort -m $@.new.txt $@.old.txt |\
	    uniq -f1 | sort -k1,1nr -u                      > $@.sorted; \
	    rm -f $@.old.txt $@.new.txt; \
	    rm -f $(wildcard ${@:.txt=}*.unsorted.txt); \
	    mv $@.sorted $@; \
	  fi; \
	else \
	  if [ $(words $(wildcard ${@:.txt=}*.txt)) -gt 0 ]; then \
	    echo "merge and sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"; \
	    cat $(wildcard ${@:.txt=}*.txt) | grep '^[0-9\-]' |\
	    sort -k2,2 -k1,1nr | uniq -f1 | sort -k1,1nr -u > $@.sorted; \
	    rm -f $(wildcard ${@:.txt=}*.txt); \
	    mv $@.sorted $@; \
	  fi; \
	fi



%/langpairs.txt: %
	find $(dir $@) -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort > $@


%/benchmarks.txt: %
	for b in $(sort $(shell find $(dir $@) -mindepth 2 -maxdepth 2 -type d -printf '%f\n')); do \
	  echo -n "$$b	" >> $@; \
	  find $(dir $@) -name "$$b" -type d | cut -f2 -d/ | sort -u | tr "\n" ' ' >> $@; \
	  echo "" >> $@; \
	done




## merge external and internal scores
## TODO: do we really want to create a copy of all files?

MERGED_METRICFILES = $(patsubst ${LEADERBOARD_DIR}/%,merged-scores/%,${METRICFILES})

.PHONY: merge-with-external
merge-with-external: ${MERGED_METRICFILES}
${MERGED_METRICFILES}: merged-scores/%: ${LEADERBOARD_DIR}/%
	mkdir (dir $@)
	-cat $< $(patsubst merged-scores/%,external-scores/%,$@) |\
	sort -k1,1nr -u | uniq -f2 > $@

.PHONY: merge-all-scores
 merge-all-scores:
	@for l in ${LANGPAIRS}; do \
	  ${MAKE} -s LANGPAIR=$$l UPDATE_ALL_LEADERBOARDS=0 merge-with-external; \
	done



include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk




