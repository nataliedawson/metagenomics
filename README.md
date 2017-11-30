# metagenomics

This project provides scripts for basic metagenome analysis.

Filtering a FASTA file by sequence length
-----------------------------------------
Use `filter_fasta.pl` to filter to provided FASTA file with a user-specified sequence length. For usage, run the script without any options.

```
$ ./filter_fasta.pl
Usage:
./filter_fasta.pl [required]

Required:
                --fasta                    FASTA file to be filtered
                --filter_length            Length of sequence to filter by
                --fasta_out                FASTA file to contain the filtered sequences

Example:
./filter_fasta.pl 
   --fasta                       1.10.8.10-ff-9390.faa 
   --filter_length               100 
   --out_file                    1.10.8.10-ff-9390.filtered.faa

Takes a FASTA file and filters out sequences that are lower than a specified threshold.
```

Extract protein sequences of interest from a FASTA file
-------------------------------------------------------
This script was written to help a collaborator who wants to extract numerous, specific protein sequences of interest from a large FASTA file. This avoids the issues involved in attempting to open files that are GBs in size, and then (if the file actually opens) having to then look for numerous sequences to copy and paste.

A typical FASTA file in this case is one containing contiguous sequences (contigs), assembled from metagenome sequence reads. These files are very large in terms of: size, the number of sequences, sequence lengths. You may be interested in genes that code for a particular family of enzymes, for example, and you can specify the ids that these genes correspond to in the FASTA file.

Use `extract_protein_sequences_using_id_list.pl` to extract protein sequences of interest from a FASTA file using a specific list of ids.

```
$ ./extract_protein_sequences_using_id_list.pl
Usage:
./extract_protein_sequences_using_id_list.pl [required]

Required:
                --fasta                    FASTA file to be filtered
                --ids_file                 Files of sequence ids to extract entries from FASTA
                --fasta_out                FASTA file to contain the extracted sequences

Example:
./extract_protein_sequences_using_id_list.pl 
   --fasta                       metagenome_contigs.faa 
   --ids_file                    ids_of_interest.dat 
   --fasta_out                   metagenome_contigs.extracted_genes_of_interest.faa

Content example for --ids_file:
1244082_1
1244082_2
1244082_3
1244638_1
1244638_2
1244638_3

Takes a FASTA file and extracts sequences using a specified list of ids.
```

