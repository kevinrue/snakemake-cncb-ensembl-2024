rule simpleaf_build_reference_index:
    input:
        genome="resources/genome/genome.fa.gz",
        gtf="resources/genome/genome.gtf.gz",
    output:
        index=directory("resources/genome/index/alevin"),
    log:
        out="logs/alevin/build_reference_index.out",
        err="logs/alevin/build_reference_index.err",
    threads: 16
    resources:
        mem="8G",
        runtime="2h",
    params:
        rlen=config["simpleaf"]["index"]["rlen"]
    shell:
        "jobdir=$(pwd) &&"
        " cd $TMPDIR &&"
        " export ALEVIN_FRY_HOME=af_home &&"
        " simpleaf set-paths &&"
        " gunzip -c $jobdir/{input.genome} > tmp_alevin_index.fa  &&"
        " simpleaf index"
        " --output $jobdir/{output.index}"
        " --fasta tmp_alevin_index.fa"
        " --gtf $jobdir/{input.gtf}"
        " --rlen {params.rlen}"
        " --threads {threads}"
        " --use-piscem"
        " > $jobdir/{log.out} 2> $jobdir/{log.err}"

# Function used by rule: simpleaf_quant
def get_simpleaf_quant_input_fastqs(wildcards):
    sample_fastqs_info=SCRNASEQ[SCRNASEQ['sample_name'] == wildcards.sample].filter(items=['directory', 'R1', 'R2'])
    fq1=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R1'][i]) for i in sample_fastqs_info.index]
    fq2=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R2'][i]) for i in sample_fastqs_info.index]
    return {
        'fq1': fq1,
        'fq2': fq2,
    }

rule simpleaf_quant:
    input:
        unpack(get_simpleaf_quant_input_fastqs),
        index="resources/genome/index/alevin",
    output:
        directory("results/simpleaf/quant/{sample}"),
    params:
        reads1=lambda wildcards, input: ','.join(input.fq1),
        reads2=lambda wildcards, input: ','.join(input.fq2),
    log:
        out="logs/simpleaf/quant/{sample}.out",
        err="logs/simpleaf/quant/{sample}.err",
    threads: 16
    resources:
        mem="16G",
        runtime="4h",
    shell:
        "jobdir=$(pwd) &&"
        " cd $TMPDIR &&"
        " export ALEVIN_FRY_HOME=af_home &&"
        " simpleaf set-paths &&"
        " simpleaf quant"
        " --reads1 {params.reads1}"
        " --reads2 {params.reads2}"
        " --index $jobdir/{input.index}/index"
        " --chemistry 10xv4-3p --resolution cr-like --expected-ori fw --unfiltered-pl"
        " --t2g-map $jobdir/{input.index}/index/t2g_3col.tsv"
        " --threads {threads}"
        " --output alevin_quant_{wildcards.sample}"
        " > $jobdir/{log.out} 2> $jobdir/{log.err} &&"
        " mv alevin_quant_{wildcards.sample} $jobdir/{output}"
