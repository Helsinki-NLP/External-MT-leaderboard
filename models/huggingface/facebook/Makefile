# -*-makefile-*-
#
# recipes for evaluating facebook models (from huggingface model hub)
#

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../../





.PHONY: all
all:
	${MAKE} nllb-jobs
	${MAKE} m2m100-jobs

include ../../lib/config.mk



# evaluate NLLB (see Makefile.nllb)

NLLB_MODELS := nllb-200-distilled-600M nllb-200-distilled-1.3B nllb-200-1.3B nllb-200-3.3B

nllb-jobs:
	for m in ${NLLB_MODELS}; do \
	  ${MAKE} -f Makefile.nllb MODELS=$$m METRICS="bleu spbleu chrf chrf++" \
				EVAL_LANGPAIR_THREADS=1 eval-models.submit; \
	done

nllb-flores101-jobs:
	for m in ${NLLB_MODELS}; do \
	  ${MAKE} -f Makefile.nllb MODELS=$$m METRICS="bleu spbleu chrf chrf++" \
				EVAL_LANGPAIR_THREADS=1 eval-flores101.submit; \
	done

nllb-pivot-jobs:
	for m in ${NLLB_MODELS}; do \
	  ${MAKE} -f Makefile.nllb MODELS=$$m \
		EVAL_LANGPAIR_THREADS=1 eval-pivot.submit; \
	done

# create the score files for all nllb models
nllb-scores:
	for m in ${NLLB_MODELS}; do \
	  ${MAKE} -f Makefile.nllb MODELS=$$m FLORES200_LANGS=eng update-eval-files; \
	done


## evaluate M2M100 model (see Makefile.m2m100)

M2M100_MODELS := m2m100_418M m2m100_1.2B m2m100-12B-last-ckpt
M2M100_MODEL  ?= ${firstword ${M2M100_MODELS}}
BATCH_SIZE    ?= 16

m2m100:
	${MAKE} -f Makefile.m2m100 METRICS="bleu spbleu chrf chrf++" MODELS=${M2M100_MODEL} BATCH_SIZE=${BATCH_SIZE} eval-models

m2m100-jobs:
	${MAKE} M2M100_MODEL=m2m100_418M BATCH_SIZE=16 m2m100.submit
	${MAKE} M2M100_MODEL=m2m100_1.2B BATCH_SIZE=8 m2m100.submit


m2m100-pivot:
	${MAKE} -f Makefile.m2m100 MODELS=${M2M100_MODEL} BATCH_SIZE=${BATCH_SIZE} eval-pivot

m2m100-pivot-jobs:
	${MAKE} M2M100_MODEL=m2m100_418M BATCH_SIZE=16 m2m100-pivot.submit
	${MAKE} M2M100_MODEL=m2m100_1.2B BATCH_SIZE=8 m2m100-pivot.submit
	${MAKE} M2M100_MODEL=m2m100-12B-last-ckpt BATCH_SIZE=4 m2m100-pivot.submit



