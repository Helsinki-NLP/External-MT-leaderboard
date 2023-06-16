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


SOURCE      ?= huggingface
MODEL       ?= huggingface/facebook/nllb-200-distilled-600M


.PHONY: all
all: register-all
	${MAKE} upload-all


include ${REPOHOME}build/config.mk
include ${REPOHOME}build/register.mk
include ${REPOHOME}build/storage.mk


