# -*-makefile-*-


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


## backup files before removing benchmarks
## also used as targets to actually remove them from the original files

TOPSCORE_FILES_REMOVE   := $(patsubst %.txt,%.remove,${TOPSCORE_FILES})
MODELSCORE_FILES_REMOVE := $(patsubst %.txt,%.remove,${MODELSCORE_FILES})


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
	mv -f $< $@
	egrep -v '(${REMOVE_PATTERN})	' < $@ > $<
	touch $@
endif



## remove backup files

.PHONY: cleanup
cleanup:
	find ../scores -name '*.remove' -delete
