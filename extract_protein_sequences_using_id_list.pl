#!/usr/bin/env perl

# Script to extract protein sequences of interest

use strict;
use warnings;
use Path::Tiny;
use Bio::SeqIO;
use Getopt::Long;

my $USAGE = <<"_USAGE";
Usage:
$0 [required]

Required:
                --fasta                    FASTA file to be filtered
                --ids_file                 Files of sequence ids to extract entries from FASTA
                --fasta_out                FASTA file to contain the extracted sequences

Example:
$0 \
   --fasta                       metagenome_contigs.faa \
   --ids_file                    ids_of_interest.dat \
   --fasta_out                   metagenome_contigs.extracted_genes_of_interest.faa

Content example for --ids_file:
1244082_1
1244082_2
1244082_3
1244638_1
1244638_2
1244638_3

Takes a FASTA file and extracts sequences using a specified list of ids.

_USAGE

sub USAGE {
        print $USAGE;
        print "Error: @_\n" if scalar @ARGV;
        exit;
}

USAGE() unless scalar @ARGV;

# user inputs
my $file;      # FASTA file input
my $ids_file;  # list of ids file input
my $out_fh;    # output file

GetOptions(
    "fasta=s"         => \$file,
    "ids_file=s"       => \$ids_file,
    "fasta_out=s"     => sub{ $out_fh = path( $_[1] )->openw() },
) or die( "Error in command line args.\n" );

USAGE( "FASTA file to filter must be specified" ) unless defined $file;
USAGE( "File of ids must be specified" ) unless defined $ids_file;
USAGE( "Output file must be specified" ) unless defined $out_fh;

print "WARN: Retrieving all id strings of interest and excluding any characters after whitespace, e.g. will extract '1244082_2' from '1244082_2 gene=1244082_2.gene'\n";
my $ids_of_interest = parse_ids( $ids_file );
my $num_ids_of_interest = scalar @$ids_of_interest;
print "Found $num_ids_of_interest ids of interest to extract from FASTA file.\n";

# create a new Bio::SeqIO object
my $in = Bio::SeqIO->new( -file   => "<$file",
    			  -format => "fasta");

print "Created Bio::SeqIO object for file: $file\n";

# iterate through each sequence in the FASTA file
while(my $seq = $in->next_seq()) {

    # get sequence id
    my $id = $seq->id;

    print "Processing sequence ID: $id\n";

    # if find this seq id in the chosen list of ids
    if (grep( /^$id$/, @$ids_of_interest )) {

        # get the sequence
        my $sequence = $seq->seq;

        print "Matched sequence ID from list: $id\n";

        # print out the id and sequence to file
        print $out_fh ">$id\n$sequence\n";
    }

}

# go through file and pull out all ids
# getting just the id before the white space
sub parse_ids {
  my $ids_file = shift;

  my @ids_from_file = path( $ids_file )->lines( { chomp => 1 } );
  my @ids_of_interest;

  foreach my $id ( @ids_from_file ) {
    if ( $id =~ /(\w+)\s/ ) {
      my $shortened_id = $1;
      push( @ids_of_interest, $shortened_id );
    }

  }

  return \@ids_of_interest;
}
