# -*-makefile-*-
#
#--------------------------------------------------------------------
#  make remove MODEL=modelname
#  make remove BENCHMARK=testset
#  make remove MODEL=modelname BENCHMARK=testset
#
#  make remove BENCHMARK=testset LANGPAIR=langpair
#  make remove MODEL=modelname BENCHMARK=testset LANGPAIR=langpair
#
#  make remove-devsets
#  make cleanup
#--------------------------------------------------------------------


SPACE := $(empty) $(empty)


#--------------------------------------------------------------------
# find the files that need to be modified / removed
#
#   if BENCHMARK is set (e.g. to flores200-devtest)
#      - all top-score files for language pairs that exist for this benchmark
#        (unless LANGPAIR is set to specific selected language pairs)
#      - all benchmark-specific sub-directories in the leaderboard
#      - all model score files (need to test whether they have been tested with this benchmark)
#        TODO: should restrict to models that can handle that language pair!
#   if BENCHMARK and MODEL are set
#      - all top-score files for language pairs that exist for this benchmark
#        (unless LANGPAIR is set to specific selected language pairs)
#      - all score files of the selected benchmark (need to remove the entry for the selected model)
#      - only model score files of that model
#   if MODEL is set
#      - all score files of language pairs that the model can handle
#      - all model score files
#   otherwise:
#      - all top score files
#      - all model score files
#--------------------------------------------------------------------

ifneq (${BENCHMARK},)
  LANGPAIR         ?= $(shell grep '^${BENCHMARK}	' ../scores/benchmarks.txt | cut -f2)
  TOPSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/top-*.txt))
  AVGSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/avg-*.txt))
  SCORE_FILE_DIRS  := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/${BENCHMARK}))
ifneq (${MODEL},)
  MODELSCORE_FILES := $(wildcard ../models/${MODEL}.*.txt)
  SCORE_FILES      := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/${BENCHMARK}/*.txt))
  EVALZIP_FILES    := ../models/${MODEL}.eval.zip
  EVAL_FILES       := $(foreach langpair,$(LANGPAIR),../models/$(langpair)/${MODEL}.eval.zip/${BENCHMARK}.${langpair}.*)
else
  MODELS           := $(sort $(foreach langpair,$(LANGPAIR),$(shell cat ../scores/$(langpair)/model-list.txt)))
  MODELSCORE_FILES := $(foreach model,$(MODELS),$(wildcard ../models/$(model).*.txt))
  EVALZIP_FILES    := $(foreach model,$(MODELS),../models/$(model).eval.zip)
  EVAL_FILES       := $(foreach model,${MODELS},$(foreach langpair,$(LANGPAIR),../models/${model}.eval.zip/${BENCHMARK}.${langpair}.*))
endif
else ifneq (${MODEL},)
ifneq (${LANGPAIR},)
  EVAL_FILES       := $(foreach langpair,$(LANGPAIR),$(wildcard ../models/${MODEL}.eval.zip/*.${langpair}.*))
endif
  LANGPAIR         ?= $(shell cut -f1 ../models/${MODEL}.scores.txt | sort -u)
  TOPSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/top-*.txt))
  AVGSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/avg-*.txt))
  MODELSCORE_FILES := $(wildcard ../models/${MODEL}.*.txt)
  SCORE_FILES      := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/*/*.txt))
  EVALZIP_FILES    := ../models/${MODEL}.eval.zip
else ifneq (${LANGPAIR},)
  TOPSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/top-*.txt))
  AVGSCORE_FILES   := $(foreach langpair,$(LANGPAIR),$(wildcard ../scores/$(langpair)/avg-*.txt))
  SCORE_FILE_DIRS  := $(patsubst %,../scores/%,$(LANGPAIR))
  MODELS           := $(sort $(foreach langpair,$(LANGPAIR),$(shell cat ../scores/$(langpair)/model-list.txt)))
  MODELSCORE_FILES := $(foreach model,$(MODELS),$(wildcard ../models/$(model).*.txt))
  EVALZIP_FILES    := $(foreach model,$(MODELS),../models/$(model).eval.zip)
  EVAL_FILES       := $(foreach model,${MODELS},$(foreach langpair,$(LANGPAIR),../models/${model}.eval.zip/*.${langpair}.*))
else
  TOPSCORE_FILES   := $(wildcard ../scores/*/top-*.txt)
  AVGSCORE_FILES   := $(wildcard ../scores/*/avg-*.txt)
  MODELSCORE_FILES := $(shell find ../models -name '*.txt')
  EVALZIP_FILES    := $(shell find ../models -name '*.eval.zip')
endif



## backup files before removing benchmarks
## also used as targets to actually remove them from the original files

SCORE_FILE_DIRS_REMOVE  := $(patsubst %,%.remove-dir,${SCORE_FILE_DIRS})
SCORE_FILES_REMOVE      := $(patsubst %.txt,%.remove,${SCORE_FILES})
TOPSCORE_FILES_REMOVE   := $(patsubst %.txt,%.remove,${TOPSCORE_FILES})
MODELSCORE_FILES_REMOVE := $(patsubst %.txt,%.remove,${MODELSCORE_FILES})




## print the files that will be affected by a remove command

print-affected-files:
	@echo "------------score-file-dirs:-------------"
	@echo "${SCORE_FILE_DIRS}" | tr ' ' "\n"
	@echo "------------score-files------------------"
	@echo "${SCORE_FILES}" | tr ' ' "\n"
	@echo "------------top-score-files--------------"
	@echo "${TOPSCORE_FILES}" | tr ' ' "\n"
	@echo "------------avg-score-files--------------"
	@echo "${AVGSCORE_FILES}" | tr ' ' "\n"
	@echo "------------model-files------------------"
	@echo "${MODELSCORE_FILES}" | tr ' ' "\n"
	@echo "------------eval-file-zips---------------"
	@echo "${EVALZIP_FILES}" | tr ' ' "\n"
	@echo "------------eval-files-------------------"
	@echo "${EVAL_FILES}" | tr ' ' "\n"



.PHONY: remove

ifneq (${BENCHMARK},)
remove: remove-benchmark
	${MAKE} cleanup
	${MAKE} average-score-files
	${MAKE} -C .. scores/langpairs.txt user-scores/benchmarks.txt
else ifneq (${MODEL},)
remove: remove-model
	${MAKE} cleanup
	${MAKE} average-score-files
	${MAKE} -C .. scores/langpairs.txt user-scores/benchmarks.txt
endif


remove:

##-----------------------------------------------------------------------------
## remove all info about a specific model
##-----------------------------------------------------------------------------

.PHONY: remove-model
remove-model:
ifneq (${MODEL},)
	${MAKE} REMOVE_PATTERN='<TAB>${MODEL}<EOS>' remove-from-topscores
	${MAKE} REMOVE_PATTERN='<TAB>${MODEL}<EOS>' remove-from-scores
	rm -f ../models/${MODEL}.*
endif

##-----------------------------------------------------------------------------
## remove one or more benchmarks from the leaderboards and score files
## TODO: need to also do something with the evaluation files in the zip archives
##-----------------------------------------------------------------------------

.PHONY: remove-benchmark
remove-benchmark:
ifneq (${BENCHMARK},)
ifneq (${MODEL},)
	${MAKE} REMOVE_PATTERN='^${BENCHMARK}<TAB>.*<TAB>${MODEL}<EOS>' remove-from-topscores
	${MAKE} REMOVE_PATTERN='<TAB>${BENCHMARK}<TAB>' remove-from-modelscores
	${MAKE} REMOVE_PATTERN='<TAB>${MODEL}<EOS>' remove-from-scores
	${MAKE} update-zip-files
else
	${MAKE} REMOVE_PATTERN='^${BENCHMARK}<TAB>' remove-from-topscores
	${MAKE} REMOVE_PATTERN='<TAB>${BENCHMARK}<TAB>' remove-from-modelscores
	${MAKE} remove-benchmark_scores
	${MAKE} update-zip-files
endif
endif

##-----------------------------------------------------------------------------
## remove dev sets from the leaderboard
##-----------------------------------------------------------------------------

DEVSETS := $(sort $(shell cut -f1 ../scores/benchmarks.txt | grep dev | grep -v devtest))

.PHONY: remove-devsets
remove-devsets:
	${MAKE} REMOVE_PATTERN='^($(sort $(subst ${SPACE},|,${DEVSETS})))<TAB>' remove-from-topscores
	${MAKE} REMOVE_PATTERN='<TAB>($(sort $(subst ${SPACE},|,${DEVSETS})))<TAB>' remove-from-modelscores
	@for d in ${DEVSETS}; do \
	  echo "delete $$d"; \
	  find ../scores/ -maxdepth 2 -mindepth 1 -name $$d -exec rm -fr {} \; ; \
	done
	${MAKE} remove-devevalfiles


## remove all evaluation files that belong to development sets
## and put them into a separate zip file

EVALZIP_DEV := $(patsubst %.eval.zip,%.deveval.zip,${EVALZIP_FILES})

.PHONY: remove-devevalfiles
remove-devevalfiles: ${EVALZIP_DEV}

${EVALZIP_DEV}: %.deveval.zip: %.eval.zip
	mkdir -p $@.d $<.d
	cd $<.d && unzip ../${notdir $<}
	for d in ${DEVSETS}; do \
	  find $<.d -name "$$d.*" -exec mv {} $@.d/ \; ;\
	done
	if [ `ls $<.d | wc -l` -gt 0 ]; then \
	  mv $< $<.backup; \
	  cd ${PWD}/$<.d && find . -name '*.*' | xargs zip ../${notdir $<}; \
	  cd ${PWD}/$@.d && find . -name '*.*' | xargs zip ../${notdir $@}; \
	fi
	rm -fr $<.d $@.d




##-------------------------------------------------
## generic targets to remove something
##-------------------------------------------------

.PHONY: remove-from-scores remove-from-topscores remove-from-modelscores
remove-from-scores: ${SCORE_FILES_REMOVE}
remove-from-topscores: ${TOPSCORE_FILES_REMOVE}
remove-from-modelscores: ${MODELSCORE_FILES_REMOVE}

REMOVE_PATTERN_UNESCAPED := $(subst <EOS>,$$,$(subst <TAB>,	,${REMOVE_PATTERN}))

${SCORE_FILES_REMOVE} ${TOPSCORE_FILES_REMOVE} ${MODELSCORE_FILES_REMOVE}: %.remove: %.txt
ifneq (${REMOVE_PATTERN_UNESCAPED},)
	@mv -f $< $@
	egrep -v '${REMOVE_PATTERN_UNESCAPED}' < $@ > $< || exit 1
	@touch $@
endif

average-score-files: ${AVGSCORE_FILES}

${AVGSCORE_FILES}: ${TOPSCORE_FILES}
	${MAKE} -C .. LANGPAIR=$(word 3,$(subst /, ,$@)) avg-scores 
	${MAKE} -C .. LANGPAIR=$(word 3,$(subst /, ,$@)) model-list

${TOPSCORE_FILES}:
	${MAKE} -C .. LANGPAIR=$(word 3,$(subst /, ,$@)) top-scores


.PHONY: remove-benchmark_scores
remove-benchmark_scores: ${SCORE_FILE_DIRS_REMOVE}

${SCORE_FILE_DIRS_REMOVE}: %.remove-dir: %
	mv $< $@


##-------------------------------------------------
## update eval zip files if necessary
##-------------------------------------------------

update-zip-files: ${EVALZIP_FILES}

${EVALZIP_FILES}: %.eval.zip: %.scores.txt
	if [ ! -e $@ ]; then \
	  ${MAKE} -C ../models $(patsubst ../models/%,%,$@); \
	fi
	${MAKE} remove-eval-files

remove-eval-files: ${EVAL_FILES}

${EVAL_FILES}:
	-zip -d $(patsubst %/,%,$(dir $@)) $(notdir $@)

##-------------------------------------------------
## cleanup
##-------------------------------------------------

.PHONY: cleanup
cleanup:
	find ../scores -name '*.remove' -delete
	find ../models -name '*.remove' -delete
	find ../models -name '*.backup' -delete
	find ../scores -name '*.txt' -empty -delete
	find ../models -name '*.txt' -empty -delete
	find ../scores/ -name '*.remove-dir' -exec rm -fr {} \;
