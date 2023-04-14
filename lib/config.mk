# -*-makefile-*-



## set a flag to use target language labels
## in multi-target models
ifneq (${words ${TRGLANGS}},1)
  USE_TARGET_LABELS = 1
  TARGET_LABELS ?= $(patsubst %,>>%<<,${TRGLANGS})
endif


## parameters for running Marian NMT

MARIAN_GPUS       ?= 0
MARIAN_BEAM_SIZE  ?= 4
MARIAN_MAX_LENGTH ?= 500
MARIAN_MINI_BATCH ?= 256
MARIAN_MAXI_BATCH ?= 512
# MARIAN_MINI_BATCH = 512
# MARIAN_MAXI_BATCH = 1024
# MARIAN_MINI_BATCH = 768
# MARIAN_MAXI_BATCH = 2048

MARIAN_DECODER_WORKSPACE = 10000


ifeq ($(GPU_AVAILABLE),1)
  MARIAN_DECODER_FLAGS = -b ${MARIAN_BEAM_SIZE} -n1 -d ${MARIAN_GPUS} \
			--quiet-translation \
			-w ${MARIAN_DECODER_WORKSPACE} \
			--mini-batch ${MARIAN_MINI_BATCH} \
			--maxi-batch ${MARIAN_MAXI_BATCH} --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
# --fp16
else
  MARIAN_DECODER_FLAGS = -b ${MARIAN_BEAM_SIZE} -n1 --cpu-threads ${HPC_CORES} \
			--quiet-translation \
			--mini-batch ${HPC_CORES} \
			--maxi-batch 100 --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
endif



