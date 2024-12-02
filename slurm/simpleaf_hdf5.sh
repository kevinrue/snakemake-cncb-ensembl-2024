#!/bin/bash

# Resources:
#SBATCH --time=0-06:00:00  # DAYS-HOURS:MINUTES:SECONDS
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --partition=short
#SBATCH --error=/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/slurm/simpleaf_hdf5.slurm.err
#SBATCH --output=/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/slurm/simpleaf_hdf5.slurm.out

# Environment:
#SBATCH --export=NONE

# What to run:
# module load bwa/0.7.18

cd /ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024

apptainer exec \
  --writable-tmpfs \
  -B $TMPDIR:/tmp \
  -B /ceph/project/cncb/albrecht/R-4.4.1 \
  -B /ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024 \
  /ceph/project/cncb/albrecht/containers/rserver-2024.sif \
  Rscript /ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/scripts/simpleaf_hdf5.R \
  > /ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/slurm/simpleaf_hdf5.R.out \
  2> /ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/slurm/simpleaf_hdf5.R.err \