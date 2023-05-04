# -*-makefile-*-


PWD ?= $(shell pwd)

## devsets that should be removed

DEVSETS := $(sort $(shell cut -f1 ../scores/benchmarks.txt | grep dev | grep -v devtest))


## REMOVE = list of benchmarks to be removed
## REMOVE_PATTERN = grep pattern to find benchmarks

REMOVE ?= ${DEVSETS}
SPACE  := $(empty) $(empty)
REMOVE_PATTERN := $(sort $(subst ${SPACE},|,${REMOVE}))


## all top-score files and model score files
## that may need an update

TOPSCORE_FILES   := $(wildcard ../scores/*/top-*.txt)
MODELSCORE_FILES := $(shell find ../models -name '*.txt')


## zip files with evaluation results
## extra zip files with evaluation results on dev sets

EVALZIP_FILES := $(shell find ../models -name '*.eval.zip')
EVALZIP_DEV   := $(patsubst %.eval.zip,%.deveval.zip,${EVALZIP_FILES})


## backup files before removing benchmarks
## also used as targets to actually remove them from the original files

TOPSCORE_FILES_REMOVE   := $(patsubst %.txt,%.remove,${TOPSCORE_FILES})
MODELSCORE_FILES_REMOVE := $(patsubst %.txt,%.remove,${MODELSCORE_FILES})

.PHONY: remove-devsets
remove-devsets: remove-benchmark remove-devevalfiles
	${MAKE} cleanup

## remove one or more benchmarks from the leaderboards and score files
## TODO: need to also do something with the evaluation files in the zip archives

.PHONY: remove-benchmark
remove-benchmark: ${TOPSCORE_FILES_REMOVE} ${MODELSCORE_FILES_REMOVE}
	@for d in ${REMOVE}; do \
	  echo "delete $$d"; \
	  find ../scores/ -maxdepth 2 -mindepth 1 -name $$d -exec rm -fr {} \; ; \
	done

%.remove: %.txt
ifneq (${REMOVE_PATTERN},)
	@mv -f $< $@
	@egrep -v '(${REMOVE_PATTERN})	' < $@ > $<
	@touch $@
endif


## remove all evaluation files that belong to development sets
## and put them into a separate zip file

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


## remove backup files

.PHONY: cleanup
cleanup:
	find ../scores -name '*.remove' -delete
	find ../models -name '*.remove' -delete
	find ../models -name '*.backup' -delete
