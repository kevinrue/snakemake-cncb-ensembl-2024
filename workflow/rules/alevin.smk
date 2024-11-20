rule alevin_build_reference_index:
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

# Function used by rule: alevin_quant
def get_alevin_quant_input_fastqs(wildcards):
    print(wildcards.sample)
    sample_fastqs_info=SAMPLES[SAMPLES['sample_name'] == wildcards.sample].filter(items=['directory', 'R1', 'R2'])
    print(sample_fastqs_info)
    fq1=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R1'][i]) for i in sample_fastqs_info.index]
    fq2=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R2'][i]) for i in sample_fastqs_info.index]
    return {
        'fq1': fq1,
        'fq2': fq2,
    }

rule alevin_quant:
    input:
        unpack(get_alevin_quant_input_fastqs),
        index="resources/genome/index/alevin",
    output:
        directory("results/alevin/{sample}"),
    params:
        reads1=lambda wildcards, input: ','.join(input.fq1),
        reads2=lambda wildcards, input: ','.join(input.fq2),
    log:
        out="logs/alevin/quant/{sample}.out",
        err="logs/alevin/quant/{sample}.err",
    threads: 16
    resources:
        mem="16G",
        runtime="4h",
    shell:
        " simpleaf quant"
        " --reads1 {params.reads1}"
        " --reads2 {params.reads2}"
        " --index {input.index}/index"
        " --chemistry 10xv3 --resolution cr-like --expected-ori fw --unfiltered-pl" # from tutorial, to be confirmed
        " --t2g-map {input.index}/index/t2g_3col.tsv"
        " --threads {threads}"
        " --output alevin_quant_{wildcards.sample}"
        " > {log.out} 2> {log.err}"
