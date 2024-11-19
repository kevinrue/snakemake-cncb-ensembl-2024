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
        runtime="12h",
    shell:
        "export ALEVIN_FRY_HOME=af_home &&"
        " simpleaf set-paths &&"
        " gunzip -c {input.genome} > tmp_alevin_index.fa  &&"
        " simpleaf index"
        " --output {output.index}"
        " --fasta tmp_alevin_index.fa"
        " --gtf {input.gtf}"
        " --rlen 150"
        " --threads 16"
        " --use-piscem"
        " > {log.out} 2> {log.err} &&"
        " rm tmp_alevin_index.fa"
