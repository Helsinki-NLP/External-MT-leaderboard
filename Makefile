# -*-makefile-*-

REPOHOME := $(dir $(lastword ${MAKEFILE_LIST}))
MAKEDIR  := ${REPOHOME}build/

OVERVIEW_FILES := scores/langpairs.txt scores/benchmarks.txt


.PHONY: all
all: scores
	find scores -name '*unsorted*' -empty -delete
	${MAKE} -s updated-leaderboards
	${MAKE} -s scores/langpairs.txt user-scores/benchmarks.txt
	find scores -name '*.txt' | grep -v unsorted | xargs git add


.PHONY: all-langpairs
all-langpairs:
	@find scores -name '*unsorted*' -empty -delete
	${MAKE} -s refresh-leaderboards
	${MAKE} -s scores/langpairs.txt scores/benchmarks.txt
	find scores/ -name '*.txt' | grep -v unsorted | xargs git add

update-git:
	git add $(OVERVIEW_FILES)
	find scores -type f -name '*.txt' | xargs git add
	find models -type f -name '*.txt' | xargs git add
	find models -type f -name '*.registered' | xargs git add
	find models -type f -name '*.output' | xargs git add
	find models -type f -name '*.eval' | xargs git add
	find models -type f -name '*.logfiles' | xargs git add
	find models -type f -name '*.zip' | grep -v '.eval.zip' | xargs git add


include ${MAKEDIR}leaderboards.mk
include ${MAKEDIR}config.mk

