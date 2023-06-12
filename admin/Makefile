# -*-makefile-*-
#
#--------------------------------------------------------------------
#  make remove MODEL=modelname
#  make remove BENCHMARK=testset
#  make remove MODEL=modelname BENCHMARK=testset
#
#  make remove BENCHMARK=testset LANGPAIR=langpair
#  make remove MODEL=modelname BENCHMARK=testset LANGPAIR=langpair
#
#  make remove-devsets
#  make cleanup
#--------------------------------------------------------------------

PWD      ?= ${shell pwd}
REPOHOME ?= ${PWD}/../
MAKEDIR  ?= ${REPOHOME}build/


include ${MAKEDIR}remove.mk
include ${MAKEDIR}misc.mk
include ${MAKEDIR}slurm.mk
