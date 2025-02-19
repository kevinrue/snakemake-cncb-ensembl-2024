import pandas

SAMPLES=pandas.read_csv('config/samples.tsv', sep='\t').set_index("sample_name", drop=False)
SCRNASEQ=pandas.read_csv('config/scrnaseq.tsv', sep='\t')
