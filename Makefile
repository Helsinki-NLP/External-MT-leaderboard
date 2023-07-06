# -*-makefile-*-


OVERVIEW_FILES := scores/langpairs.txt scores/benchmarks.txt


.PHONY: all
all: scores
	find scores -name '*unsorted*' -empty -delete
	${MAKE} -s updated-leaderboards
	${MAKE} -s overview-files
#	find scores -name '*.txt' | grep -v unsorted | xargs git add


.PHONY: all-langpairs
all-langpairs:
	@find scores -name '*unsorted*' -empty -delete
	${MAKE} -s refresh-leaderboards
	${MAKE} -s overview-files
#	find scores/ -name '*.txt' | grep -v unsorted | xargs git add

.PHONY: overview-files
overview-files: $(OVERVIEW_FILES)

update-git:
	git add $(OVERVIEW_FILES)
	find scores -type f -name '*.txt' | xargs git add
	find models -type f -name '*.txt' | xargs git add
	find models -type f -name '*.registered' | xargs git add
	find models -type f -name '*.output' | xargs git add
	find models -type f -name '*.eval' | xargs git add
	find models -type f -name '*.logfiles' | xargs git add
	find models -type f -name '*.zip' | grep -v '.eval.zip' | xargs git add


include build/leaderboards.mk
include build/config.mk


fix-errors:
	find models -name '*.registered' -delete
	make -C models register-all
	make all-langpairs

#	find scores -name '*.txt' -exec sed -i 's#../models/##' {} \;
