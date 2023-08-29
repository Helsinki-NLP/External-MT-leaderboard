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

push-and-commit-git:
	git commit -am 'updated leaderboards'
	git push origin master

update-git:
	cd scores && git ls-files --others --exclude-standard | grep '\.txt$$' | xargs git add
	cd models && git ls-files --others --exclude-standard | grep '\.txt$$' | xargs git add
	cd models && git ls-files --others --exclude-standard | grep '\.registered$$' | xargs git add
	cd models && git ls-files --others --exclude-standard | grep '\.output$$' | xargs git add
	cd models && git ls-files --others --exclude-standard | grep '\.evalfiles.zip$$' | xargs git add
	cd models && git ls-files --others --exclude-standard | grep '\.logfiles$$' | xargs git add
#	cd models && git ls-files --others --exclude-standard | grep '\.eval$$' | xargs git add
#	cd models && git ls-files --others --exclude-standard | grep '\.zip$$' | \
#	grep -v '\.eval\.zip$$' | grep -v '\.log\.zip$$' | xargs git add


#	git add $(OVERVIEW_FILES)
#	find scores -type f -name '*.txt' | xargs git add
#	find models -type f -name '*.txt' | xargs git add
#	find models -type f -name '*.registered' | xargs git add
#	find models -type f -name '*.output' | xargs git add
#	find models -type f -name '*.eval' | xargs git add
#	find models -type f -name '*.logfiles' | xargs git add
#	find models -type f -name '*.zip' | grep -v '.eval.zip' | xargs git add


include build/leaderboards.mk
include build/config.mk


fix-errors:
	find models -name '*.registered' -delete
	make -C models register-all
	make all-langpairs

#	find scores -name '*.txt' -exec sed -i 's#../models/##' {} \;
