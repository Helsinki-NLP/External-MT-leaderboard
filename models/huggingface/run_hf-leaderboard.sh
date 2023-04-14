#!/bin/bash
#SBATCH --job-name="hf_leaderboard_%j.sh"
#SBATCH --account=project_2005815
#SBATCH --output=logs/%j.out
#SBATCH --error=logs/%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=120G
#SBATCH --partition=small
#SBATCH --mail-type=FAIL,END

module purge

module use -a /projappl/nlpl/software/modules/etc
module load nlpl-opusfilter

pip install sentencepiece

export TRANSFORMERS_CACHE="/scratch/project_2005815/HF-leaderboard/.cache/hugging_face/"
python3 main.py
