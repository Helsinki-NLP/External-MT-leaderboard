# -*-makefile-*-



.PHONY: eval-pivot
eval-pivot:
	${MAKE} fetch
	${MAKE} SRC_LANGS=${PIVOTLANG} eval-langpairs
	${MAKE} TRG_LANGS=${PIVOTLANG} eval-langpairs
	${MAKE} SRC_LANGS=${PIVOTLANG} cleanup
	${MAKE} SRC_LANGS=${PIVOTLANG} eval-model-files
	${MAKE} SRC_LANGS=${PIVOTLANG} pack-model-scores


EVAL_MODEL_TARGETS = $(patsubst %,%-evalmodel,${MODELS})

# eval-models: evaluate all models
# NEW: continue if the SLURM job breaks (see below)
#
# .PHONY: eval-models
# eval-models: ${EVAL_MODEL_TARGETS}


## define how may repetitions of slurm jobs we
## can submit in case a jobs times out or breaks
## SLURM_REPEAT     = current iteration
## SLURM_MAX_REPEAT = maximum number of iterations we allow

SLURM_REPEAT     ?= 0
SLURM_MAX_REPEAT ?= 10

# eval models - if this is a slurm job (i.e. SLURM_JOBID is set):
# - submit another one that continues training in case the current one breaks
# - only continue a certain number of times to avoid infinte loops
.PHONY: eval-models
eval-models:
ifdef SLURM_JOBID
	if [ ${SLURM_REPEAT} -lt ${SLURM_MAX_REPEAT} ]; then \
	  echo "submit job that continues to train in case the current one breaks or times out"; \
	  echo "current iteration: ${SLURM_REPEAT}"; \
	  ${MAKE} SLURM_REPEAT=$$(( ${SLURM_REPEAT} + 1 )) \
		SBATCH_ARGS="-d afternotok:${SLURM_JOBID}" $@.submit; \
	else \
	  echo "reached maximum number of repeated slurm jobs: ${SLURM_REPEAT}"; \
	fi
endif
	${MAKE} ${EVAL_MODEL_TARGETS}



.PHONY: ${EVAL_MODEL_TARGETS}
${EVAL_MODEL_TARGETS}:
	-${MAKE} MODEL=$(@:-evalmodel=) eval-model


EVAL_MODEL_REVERSE_TARGETS = $(call reverse,${EVAL_MODEL_TARGETS})

eval-models-reverse-order: ${EVAL_MODEL_REVERSE_TARGETS}

##-------------------------------------------------
## evaluate the model with all benchmarks available
## - if a model score file is missing:
##      * fetch model and evaluation files
##      * try to run evaluation again
##      * make model score files again
## pack evaluation files in a zip file
## register the scores and update the leaderboard
##-------------------------------------------------

.PHONY: eval-model
eval-model: ${MODEL_EVAL_SCORES}
	@if [ $(words $(wildcard $^)) -ne $(words $^) ]; then \
	  echo "score files missing ... fetch model and scores!"; \
	  ${MAKE} fetch; \
	  ${MAKE} eval-langpairs; \
	  ${MAKE} cleanup; \
	  ${MAKE} ${MODEL_EVAL_SCORES}; \
	fi
	${MAKE} pack-model-scores

.PHONY: eval-model-files
eval-model-files: ${MODEL_EVAL_SCORES}

.PHONY: update-eval-files
update-eval-files:
	mv -f ${MODEL_SCORES} ${MODEL_SCORES}.${TODAY}
	${MAKE} eval-model-files

.PHONY: eval
eval: 	${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare \
	${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval


EVAL_LANGPAIR_TARGET = $(patsubst %,%-eval,${LANGPAIRS})

.PHONY: eval-langpairs
eval-langpairs: ${EVAL_LANGPAIR_TARGET}

.PHONY: ${EVAL_LANGPAIR_TARGET}
${EVAL_LANGPAIR_TARGET}:
	${MAKE} LANGPAIR=$(@:-eval=) eval-testsets


TRANSLATED_BENCHMARKS = $(patsubst %,${MODEL_DIR}/%.${LANGPAIR}.compare,${TESTSETS})
EVALUATED_BENCHMARKS  = $(patsubst %,${MODEL_DIR}/%.${LANGPAIR}.eval,${TESTSETS})
BENCHMARK_SCORE_FILES = $(foreach m,${METRICS},$(patsubst %.eval,%.${m},${EVALUATED_BENCHMARKS}))

## don't delete those files when used in implicit rules
.NOTINTERMEDIATE: ${TRANSLATED_BENCHMARKS} ${EVALUATED_BENCHMARKS} ${BENCHMARK_SCORE_FILES}


.PHONY: eval-testsets
eval-testsets: ${TRANSLATED_BENCHMARKS} ${EVALUATED_BENCHMARKS}



.INTERMEDIATE: ${WORK_DIR}/%.${LANGPAIR}.output


## don't make the temporary output a pre-requisite
## (somehow it does not always work to skip creating it if the target already exists)
#
# ${MODEL_DIR}/%.${LANGPAIR}.compare:	${TESTSET_DIR}/%.${SRC} \
#					${TESTSET_DIR}/%.${TRG} \
#					${WORK_DIR}/%.${LANGPAIR}.output
#	@mkdir -p ${dir $@}
#	if [ -s $(word 3,$^) ]; then \
#	  paste -d "\n" $^ | sed 'n;n;G;' > $@; \
#	fi


${MODEL_DIR}/%.${LANGPAIR}.compare: ${TESTSET_DIR}/%.${SRC} ${TESTSET_DIR}/%.${TRG}
	@mkdir -p ${dir $@}
	@${MAKE} $(patsubst ${MODEL_DIR}/%.${LANGPAIR}.compare,${WORK_DIR}/%.${LANGPAIR}.output,$@)
	@if [ -s $(patsubst ${MODEL_DIR}/%.${LANGPAIR}.compare,${WORK_DIR}/%.${LANGPAIR}.output,$@) ]; then \
	  paste -d "\n" $^ $(patsubst ${MODEL_DIR}/%.${LANGPAIR}.compare,${WORK_DIR}/%.${LANGPAIR}.output,$@) |\
	  sed 'n;n;G;' > $@; \
	fi


## concatenate all scores into one file
## exception: comet scores: take only the last line and add the name of the metric
## all others: just add the while file content (assume sacrebleu output)

# ${MODEL_DIR}/%.${LANGPAIR}.eval: ${MODEL_DIR}/%.${LANGPAIR}.compare

${EVALUATED_BENCHMARKS}: ${BENCHMARK_SCORE_FILES}
	${MAKE} $(patsubst %,$(basename $@).%,${METRICS})
	@for m in ${METRICS}; do \
	  if [ $$m == comet ]; then \
	    tail -1 $(basename $@).$$m | sed 's/^.*score:/COMET+default =/' >> $@; \
	  else \
	    cat $(basename $@).$$m >> $@; \
	  fi \
	done
	@rev $@ | sort | uniq -f2 | rev > $@.uniq
	@mv -f $@.uniq $@


## adjust tokenisation to non-space-separated languages
ifneq ($(filter cmn yue zho,$(firstword $(subst _, ,${TRG}))),)
  SACREBLEU_PARAMS = --tokenize zh
endif

ifneq ($(filter jpn,${TRG}),)
  SACREBLEU_PARAMS = --tokenize ja-mecab
endif

ifneq ($(filter kor,${TRG}),)
  SACREBLEU_PARAMS = --tokenize ko-mecab
endif

${MODEL_DIR}/%.${LANGPAIR}.spbleu: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@cat $@.hyp | \
	sacrebleu -f text --metrics=bleu --tokenize flores200 $@.ref > $@
	@rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/%.${LANGPAIR}.bleu: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} $@.ref > $@
	@rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/%.${LANGPAIR}.chrf: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 $@.ref |\
	perl -pe 'unless (/version\:1\./){@a=split(/\s+/);$$a[-1]/=100;$$_=join(" ",@a)."\n";}' > $@
	@rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/%.${LANGPAIR}.chrf++: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 --chrf-word-order 2 $@.ref |\
	perl -pe 'unless (/version\:1\./){@a=split(/\s+/);$$a[-1]/=100;$$_=join(" ",@a)."\n";}' > $@
	@rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/%.${LANGPAIR}.ter: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=ter $@.ref > $@
	@rm -f $@.src $@.ref $@.hyp

ifneq (${GPU_AVAILABLE},1)
  COMET_PARAM += --gpus 0
endif

${MODEL_DIR}/%.${LANGPAIR}.comet: ${MODEL_DIR}/%.${LANGPAIR}.compare
	@echo "... create ${MODEL}/$(notdir $@)"
	@mkdir -p ${dir $@}
	@sed -n '1~4p' $< > $@.src
	@sed -n '2~4p' $< > $@.ref
	@sed -n '3~4p' $< > $@.hyp
	@${LOAD_COMET_ENV} ${COMET_SCORE} ${COMET_PARAM} \
		-s $@.src -r $@.ref -t $@.hyp | cut -f2,3 > $@
	@rm -f $@.src $@.ref $@.hyp



#-------------------------------------------------
# collect BLEU and chrF scores in one file
#-------------------------------------------------
#
# updating scores for models that already have some scores registered
# - need to fetch eval file package
# - avoid re-running things that are already done
# - ingest the new evaluation scores
#
#
# problem with very large multilingual models:
#
#	  grep -H BLEU ${MODEL_DIR}/*.bleu | sed 's/.bleu//' | sort          > $@.bleu; \
#	  grep -H chrF ${MODEL_DIR}/*.chrf | sed 's/.chrf//' | sort          > $@.chrf;


${MODEL_SCORES}: ${TESTSET_INDEX}
ifndef SKIP_OLD_EVALUATION
	-if [ ! -e $@ ]; then \
	  mkdir -p $(dir $@); \
	  wget -qq -O $@ ${MODELSCORE_STORAGE}/${MODEL}.scores.txt; \
	fi
endif
ifndef SKIP_NEW_EVALUATION
	${MAKE} fetch
	${MAKE} eval-langpairs
	${MAKE} cleanup
endif
	@echo "... create ${MODEL}/$(notdir $@)"
	@if [ -d ${MODEL_DIR} ]; then \
	  echo "... create ${MODEL_SCORES}"; \
	  find ${MODEL_DIR} -name '*.bleu' | xargs grep -H BLEU | sed 's/.bleu//' | sort > $@.bleu; \
	  find ${MODEL_DIR} -name '*.chrf' | xargs grep -H chrF | sed 's/.chrf//' | sort > $@.chrf; \
	  join -t: -j1 $@.bleu $@.chrf                                       > $@.bleu-chrf; \
	  cut -f1 -d: $@.bleu-chrf | rev | cut -f1 -d. | rev                 > $@.langs; \
	  cut -f1 -d: $@.bleu-chrf | rev | cut -f1 -d/ | cut -f2- -d. | rev  > $@.testsets; \
	  cat $@.bleu-chrf | rev | cut -f1 -d' ' | rev                       > $@.chrf-scores; \
	  cut -f2 -d= $@.bleu-chrf | cut -f2 -d' '                           > $@.bleu-scores; \
	  cut -f1 -d: $@.bleu-chrf | sed 's#^.*$$#${MODEL_URL}#'             > $@.urls; \
	  cut -f1 -d: $@.bleu-chrf | sed 's/$$/.compare/' | \
	  xargs wc -l |  grep -v '[0-9] total' | \
	  perl -pe '$$_/=4;print "\n"' | tail -n +2                          > $@.nrlines; \
	  cut -f1 -d')' $@.bleu-chrf | rev | cut -f1 -d' ' | rev             > $@.nrwords; \
	  if [ -e $@ ]; then mv $@ $@.old; fi; \
	  paste $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  sort -k1,1 -k2,2 -k4,4nr -k6,6nr -k7,7nr | \
	  rev | uniq -f5 | rev | sort -u                           > $@; \
	  if [ -e $@.old ]; then \
	    mv $@ $@.new; \
	    sort -k1,1 -k2,2 -m $@.new $@.old | \
	    rev | uniq -f5 | rev | sort -u                         > $@; \
	  fi; \
	  rm -f $@.bleu $@.chrf $@.bleu-chrf $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords $@.old $@.new; \
	fi




##-------------------------------------------------
## generic recipe for extracting scores for a metric
## (works for all sacrebleu results but not for other metrics)
##-------------------------------------------------
##
#
#	  grep -H . ${MODEL_DIR}/*.$(patsubst ${MODEL_DIR}.%-scores.txt,%,$@) > $@.all;

${MODEL_DIR}.%-scores.txt: ${MODEL_SCORES}
	@echo "... create ${MODEL}/$(notdir $@)"
	@if [ -d ${MODEL_DIR} ]; then \
	  mkdir -p $(dir $@); \
	  find ${MODEL_DIR} -name '*.$(patsubst ${MODEL_DIR}.%-scores.txt,%,$@)' | xargs grep -H . > $@.all; \
	  cut -f1 -d: $@.all | rev | cut -f2 -d. | rev                        > $@.langs; \
	  cut -f1 -d: $@.all | rev | cut -f1 -d/ | cut -f3- -d. | rev         > $@.testsets; \
	  cut -f3 -d ' '  $@.all                                              > $@.scores; \
	  paste $@.langs $@.testsets $@.scores                               >> $@; \
	  cat $@ |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  rev | sort | uniq -f1 | rev | sort                                  > $@.sorted; \
	  mv -f $@.sorted $@; \
	  rm -f $@.all $@.langs $@.testsets $@.scores; \
	fi


## specific recipe for COMET scores
#
#	  grep -H '^score:' ${MODEL_DIR}/*.comet | sort                  > $@.comet; \

${MODEL_DIR}.comet-scores.txt: ${MODEL_SCORES}
	@echo "... create ${MODEL}/$(notdir $@)"
	@if [ -d ${MODEL_DIR} ]; then \
	  mkdir -p $(dir $@); \
	  find ${MODEL_DIR} -name '*.comet' | xargs grep -H '^score:' | sort > $@.comet; \
	  cut -f1 -d: $@.comet | rev | cut -f2 -d. | rev                 > $@.langs; \
	  cut -f1 -d: $@.comet | rev | cut -f1 -d/ | cut -f3- -d. | rev  > $@.testsets; \
	  cat $@.comet | rev | cut -f1 -d' ' | rev                       > $@.comet-scores; \
	  paste $@.langs $@.testsets $@.comet-scores                     >> $@; \
	  cat $@ |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  rev | sort -u | uniq -f1 | rev | sort                           > $@.sorted; \
	  mv -f $@.sorted $@; \
	  rm -f $@.comet $@.langs $@.testsets $@.comet-scores; \
	fi





## prepare translation model and fetch existing evaluation files
.PHONY: fetch
fetch: fetch-model fetch-model-scores

## fetch existing evaluation files
.PHONY: fetch-model-scores
fetch-model-scores: ${MODEL_DIR}


## prepare the model evaluation file directory
## fetch already existing evaluations
${MODEL_DIR}:
	@mkdir -p $@
	-if [ -e ${MODEL_EVALZIP} ]; then \
	  cd ${MODEL_DIR}; \
	  unzip -n ${MODEL_EVALZIP}; \
	fi
	-${WGET} -q -O ${MODEL_DIR}/eval.zip ${MODEL_EVAL_URL}
	-if [ -e ${MODEL_DIR}/eval.zip ]; then \
	  cd ${MODEL_DIR}; \
	  unzip -n eval.zip; \
	  rm -f eval.zip; \
	fi

.PHONY: pack-model-scores
pack-model-scores:
	@if [ -d ${MODEL_DIR} ]; then \
	  echo "... pack model scores from ${MODEL}"; \
	  cd ${MODEL_DIR} && find . -name '*.*' | xargs zip ${MODEL_EVALZIP}; \
	  find ${MODEL_DIR} -name '*.log' -printf '%P\n' > ${MODEL_DIR}.logfiles; \
	  find ${MODEL_DIR} -name '*.*' -delete; \
	  if [ -d ${MODEL_DIR} ]; then \
	    rmdir ${MODEL_DIR}; \
	  fi \
	fi

MODEL_PACK_EVAL := ${patsubst %,%.pack,${MODELS}}

.PHONY: pack-all-model-scores
pack-all-model-scores: ${MODEL_PACK_EVAL}

.PHONY: ${MODEL_PACK_EVAL}
${MODEL_PACK_EVAL}:
	@if [ -d ${MODEL_HOME}/$(@:.pack=) ]; then \
	  ${MAKE} MODEL=$(@:.pack=) pack-model-scores; \
	fi


.PHONY: cleanup
cleanup:
ifneq (${WORK_DIR},)
ifneq (${WORK_DIR},/)
ifneq (${WORK_DIR},.)
ifneq (${WORK_DIR},..)
	rm -fr ${WORK_DIR}
	-rmdir ${WORK_HOME}/$(dir ${MODEL})
endif
endif
endif
endif
