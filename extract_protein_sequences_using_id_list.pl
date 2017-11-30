#!/usr/bin/env perl

# Script to extract protein sequences of interest

use strict;
use warnings;
use Path::Class;
use Bio::SeqIO;

# check the number of arguments provided
if ( scalar @ARGV < 3 ) {
    print "Usage: $0 <FASTA_file> <IDs_file> <output_file>\n";
    exit;
}

# user inputs
my $file     = file( $ARGV[0] ); # FASTA file input
my $ids_file = file( $ARGV[1] ); # list of ids file input
my $out_file = file( $ARGV[2] ); # output file
my $out_fh = $out_file->openw(); # open output file for writing

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
        #exit;

        # print out the id and sequence to file
        print $out_fh ">$id\n$sequence\n";
    }

}

# go through file and pull out all ids
# getting just the id before the white space
sub parse_ids {
  my $ids_file = shift;

  my @ids_from_file = $ids_file->slurp( chomp => 1 );
  my @ids_of_interest;

  foreach my $id ( @ids_from_file ) {
    if ( $id =~ /(\w+)\s/ ) {
      my $shortened_id = $1;
      push( @ids_of_interest, $shortened_id );
    }

  }

  return \@ids_of_interest;
}
