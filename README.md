# Snakemake workflow: `<name>`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/<owner>/<repo>/workflows/Tests/badge.svg?branch=main)](https://github.com/<owner>/<repo>/actions?query=branch%3Amain+workflow%3ATests)


A Snakemake workflow for `<description>`


## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=<owner>%2F<repo>).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) <repo>sitory and its DOI (see above).

Typical usage:

```
# Working directory
cd $(realpath .) # containers prefer real paths

# Host directories that need mounting to container
TMP_APPTAINER_ARGS="--bind /var/scratch"
TMP_APPTAINER_ARGS+=" --bind /ceph/project/cncb/shared/proj140/analyses/novogene_sequencing"

# Execution
nohup snakemake \
  --sdm apptainer \
  --apptainer-args "$TMP_APPTAINER_ARGS" &
```

Notes:

- `--bind /var/scratch` binds the directory where Slurm jobs are given a private folder

# TODO

* Replace `<owner>` and `<repo>` everywhere in the template (also under .github/workflows) with the correct `<repo>` name and owning user or organization.
* Replace `<name>` with the workflow name (can be the same as `<repo>`).
* Replace `<description>` with a description of what the workflow does.
* The workflow will occur in the snakemake-workflow-catalog once it has been made public. Then the link under "Usage" will point to the usage instructions if `<owner>` and `<repo>` were correctly set.
