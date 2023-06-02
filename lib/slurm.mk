# -*-makefile-*-



# enable e-mail notification by setting EMAIL

WHOAMI = $(shell whoami)
ifeq ("$(WHOAMI)","tiedeman")
  EMAIL = jorg.tiedemann@helsinki.fi
endif


##---------------------------------------------
## submit jobs
##---------------------------------------------


## submit job to gpu queue
##
## default resources for GPU jobs
## (most of them relate to CPU resources like MEM, CORES, ...)
## typically we model single node jobs, which can still have multiple GPUs!
GPUJOB_HPC_QUEUE   ?= ${HPC_GPUQUEUE}
GPUJOB_HPC_MEM     ?= 32g
GPUJOB_HPC_NODES   ?= 1
GPUJOB_HPC_CORES   ?= 1
GPUJOB_HPC_THREADS ?= ${GPUJOB_HPC_CORES}
GPUJOB_HPC_JOBS    ?= ${GPUJOB_HPC_THREADS}
GPUJOB_HPC_TIME    ?= ${HPC_TIME}


## exclude broken nodes:
## list comma separated nodes to be excluded
# BROKEN_NODES = g6301

ifdef WORK_DIR
  WORKDIR ?= ${WORK_DIR}
else
  WORKDIR ?= work
endif


%.submit:
	mkdir -p ${WORKDIR}
	mkdir -p ${dir ${TMPWORKDIR}/$@}
	echo '#!/bin/bash -l'                    > ${TMPWORKDIR}/$@
	echo '#SBATCH -J "${@:.submit=}"'       >> ${TMPWORKDIR}/$@
	echo '#SBATCH -o ${@:.submit=}.out.%j'  >> ${TMPWORKDIR}/$@
	echo '#SBATCH -e ${@:.submit=}.err.%j'  >> ${TMPWORKDIR}/$@
ifdef EMAIL
	echo '#SBATCH --mail-type=END'          >> ${TMPWORKDIR}/$@
	echo '#SBATCH --mail-user=${EMAIL}'     >> ${TMPWORKDIR}/$@
endif
	echo '#SBATCH --mem=${GPUJOB_HPC_MEM}'  >> ${TMPWORKDIR}/$@
	echo '#SBATCH -n ${GPUJOB_HPC_CORES}'   >> ${TMPWORKDIR}/$@
	echo '#SBATCH -N ${GPUJOB_HPC_NODES}'   >> ${TMPWORKDIR}/$@
	echo '#SBATCH -t ${GPUJOB_HPC_TIME}:00' >> ${TMPWORKDIR}/$@
	echo '#SBATCH -p ${GPUJOB_HPC_QUEUE}'   >> ${TMPWORKDIR}/$@
	echo '#SBATCH ${HPC_GPU_ALLOCATION}'    >> ${TMPWORKDIR}/$@
ifdef BROKEN_NODES
	echo '#SBATCH --exclude=${BROKEN_NODES}' >> ${TMPWORKDIR}/$@
endif
	echo '${HPC_EXTRA}'                     >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA1}'                    >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA2}'                    >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA3}'                    >> ${TMPWORKDIR}/$@
	echo '${HPC_GPU_EXTRA1}'                >> ${TMPWORKDIR}/$@
	echo '${HPC_GPU_EXTRA2}'                >> ${TMPWORKDIR}/$@
	echo '${HPC_GPU_EXTRA3}'                >> ${TMPWORKDIR}/$@
	echo '${LOAD_GPU_ENV}'                  >> ${TMPWORKDIR}/$@
	echo 'cd $${SLURM_SUBMIT_DIR:-.}'       >> ${TMPWORKDIR}/$@
	echo 'pwd'                              >> ${TMPWORKDIR}/$@
	echo 'echo "Starting at `date`"'        >> ${TMPWORKDIR}/$@
	echo 'srun ${MAKE} -j ${GPUJOB_HPC_JOBS} ${MAKEARGS} ${@:.submit=}' >> ${TMPWORKDIR}/$@
	echo 'echo "Finishing at `date`"'       >> ${TMPWORKDIR}/$@
	echo 'seff $$SLURM_JOBID'               >> ${TMPWORKDIR}/$@
	sbatch ${SBATCH_ARGS} ${TMPWORKDIR}/$@
	mkdir -p ${WORKDIR}
	-mv ${TMPWORKDIR}/$@ ${WORKDIR}/$@

#	echo "echo ''"                          >> ${TMPWORKDIR}/$@
#	echo "Makefile variables:"              >> ${TMPWORKDIR}/$@
#	echo "${MAKE} print-makefile-variables" >> ${TMPWORKDIR}/$@
#	echo "echo ''"                          >> ${TMPWORKDIR}/$@



## submit job to cpu queue
## copy resources to CPUjob-specific variables

CPUJOB_HPC_QUEUE   ?= ${HPC_QUEUE}
CPUJOB_HPC_MEM     ?= ${HPC_MEM}
CPUJOB_HPC_NODES   ?= ${HPC_NODES}
CPUJOB_HPC_TIME    ?= ${HPC_TIME}
CPUJOB_HPC_CORES   ?= ${HPC_CORES}
CPUJOB_HPC_THREADS ?= ${CPUJOB_HPC_CORES}
CPUJOB_HPC_JOBS    ?= ${CPUJOB_HPC_THREADS}

%.submitcpu:
	mkdir -p ${WORKDIR}
	mkdir -p ${dir ${TMPWORKDIR}/$@}
	echo '#!/bin/bash -l' > ${TMPWORKDIR}/$@
	echo '#SBATCH -J "${@:.submitcpu=}"'      >>${TMPWORKDIR}/$@
	echo '#SBATCH -o ${@:.submitcpu=}.out.%j' >> ${TMPWORKDIR}/$@
	echo '#SBATCH -e ${@:.submitcpu=}.err.%j' >> ${TMPWORKDIR}/$@
ifdef EMAIL
	echo '#SBATCH --mail-type=END'                            >> ${TMPWORKDIR}/$@
	echo '#SBATCH --mail-user=${EMAIL}'                       >> ${TMPWORKDIR}/$@
endif
	echo '#SBATCH --mem=${CPUJOB_HPC_MEM}'                    >> ${TMPWORKDIR}/$@
	echo '#SBATCH -n ${CPUJOB_HPC_CORES}' >> ${TMPWORKDIR}/$@
	echo '#SBATCH -N ${CPUJOB_HPC_NODES}' >> ${TMPWORKDIR}/$@
	echo '#SBATCH -p ${CPUJOB_HPC_QUEUE}' >> ${TMPWORKDIR}/$@
	echo '#SBATCH -t ${CPUJOB_HPC_TIME}:00' >> ${TMPWORKDIR}/$@
ifdef BROKEN_NODES
	echo '#SBATCH --exclude=${BROKEN_NODES}' >> ${TMPWORKDIR}/$@
endif
	echo '${HPC_EXTRA}' >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA1}' >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA2}' >> ${TMPWORKDIR}/$@
	echo '${HPC_EXTRA3}' >> ${TMPWORKDIR}/$@
	echo '${HPC_CPU_EXTRA1}' >> ${TMPWORKDIR}/$@
	echo '${HPC_CPU_EXTRA2}' >> ${TMPWORKDIR}/$@
	echo '${HPC_CPU_EXTRA3}' >> ${TMPWORKDIR}/$@
	echo '${LOAD_CPU_ENV}'            >> ${TMPWORKDIR}/$@
	echo 'cd $${SLURM_SUBMIT_DIR:-.}' >> ${TMPWORKDIR}/$@
	echo 'pwd' >> ${TMPWORKDIR}/$@
	echo 'echo "Starting at `date`"'  >> ${TMPWORKDIR}/$@
	echo '${MAKE} -j ${CPUJOB_HPC_JOBS} ${MAKEARGS} ${@:.submitcpu=}' >> ${TMPWORKDIR}/$@
	echo 'echo "Finishing at `date`"' >> ${TMPWORKDIR}/$@
	echo 'seff $$SLURM_JOBID'         >> ${TMPWORKDIR}/$@
	sbatch ${SBATCH_ARGS} ${TMPWORKDIR}/$@
	mkdir -p ${WORKDIR}
	-mv ${TMPWORKDIR}/$@ ${WORKDIR}/$@


