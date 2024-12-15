import pandas
import os.path

SAMPLES=pandas.read_csv('config/samples.tsv', sep='\t')
SCRNASEQ=pandas.read_csv('config/scrnaseq.tsv', sep='\t')
