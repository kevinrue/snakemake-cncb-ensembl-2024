# Function called by rule: download_gtf
def download_gtf_cmd(config):
    source_url = config["genome"]["gtf"]
    basename = os.path.basename(source_url)
    cmd = f"curl {source_url} > resources/genome/genome.gtf.gz"
    return cmd

download_gtf_cmd_str = download_gtf_cmd(config)

# Download the GTF file
rule download_gtf:
    output:
        "resources/genome/genome.gtf.gz",
    log:
        "logs/genome/download_gtf.log",
    resources:
        mem="2G",
        runtime="5m",
    shell:
        "({download_gtf_cmd_str}) 2> {log}"

# Function called by rule: download_concatenate_genome_fasta
def download_concatenate_genome_fasta_cmd(config):
    # constants
    tmp_dir = "tmp_genome"
    curl_template_cmd = "curl {source_url} > {tmp_dir}/{basename} && "
    # concatenate commands into a string
    cmd = f"mkdir -p {tmp_dir} && "
    for source_url in config["genome"]["fastas"]:
        basename = os.path.basename(source_url)
        cmd += curl_template_cmd.format(source_url=source_url, basename=basename, tmp_dir=tmp_dir)
    cmd += f"zcat {tmp_dir}/*.fa.gz | bgzip > resources/genome/genome.fa.gz && "
    cmd += f"rm -rf {tmp_dir}"
    return cmd

download_concatenate_genome_fasta_cmd_str = download_concatenate_genome_fasta_cmd(config)

# Download a list of genome FASTA files (see config/config.yaml).
# Concatenate them into a single FASTA file.
# Compress it.
# See above for a function that generates the command (cmd_download_genome_fastas).
rule download_concatenate_genome_fasta:
    output:
        "resources/genome/genome.fa.gz",
    log:
        "logs/genome/prepare_reference_fasta.log",
    resources:
        mem="8G",
        runtime="5m",
    threads: 1
    shell:
        "({download_concatenate_genome_fasta_cmd_str}) 2> {log}"
