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
