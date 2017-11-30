#!/usr/bin/env perl

# Script to filter a FASTA file using a user-specified length

use strict;
use warnings;
use Bio::SeqIO;
use Path::Tiny;
use Getopt::Long;

my $USAGE = <<"_USAGE";
Usage:
$0 [required]

Required:
                --fasta                    FASTA file to be filtered
                --filter_length            Length of sequence to filter by
                --fasta_out                FASTA file to contain the filtered sequences

Example:
$0 \
   --fasta                       1.10.8.10-ff-9390.faa \
   --filter_length               100 \
   --fasta_out                    1.10.8.10-ff-9390.filtered.faa

Takes a FASTA file and filters out sequences that are lower than a specified threshold.

_USAGE

sub USAGE {
        print $USAGE;
        print "Error: @_\n" if scalar @ARGV;
        exit;
}

USAGE() unless scalar @ARGV;

# define variables with any default values
my $fasta;
my $filter_length;
my $fasta_out;

GetOptions(
    "fasta=s"         => \$fasta,
    "filter_length=s" => \$filter_length,
    "fasta_out=s"     => sub{ $fasta_out = path( $_[1] )->openw() },
) or die( "Error in command line args.\n" );

USAGE( "FASTA file to filter must be specified" ) unless defined $fasta;
USAGE( "Filter length must be specified" ) unless defined $filter_length;
USAGE( "Output file must be specified" ) unless defined $fasta_out;

print "WARN: Filtering out sequences shorter than $filter_length residues\n";

my $in = Bio::SeqIO->new( -file => $fasta, -format => 'fasta' );

# count the number of kept and excluded sequences
my $kept_sequences = 0;
my $excluded_sequences = 0;
my $total_sequence_count = 0;

# to calculate length stats
my @lengths_before_filtering;
my @lengths_after_filtering;

while ( my $seq_obj = $in->next_seq ) {
	my $id = $seq_obj->id;
	my $seq = $seq_obj->seq;
	my $length = $seq_obj->length;

	# sequence counter
	$total_sequence_count++;

	# track lengths before filtering
	push( @lengths_before_filtering, $length );

  # apply sequence length filter
	if ( $length < $filter_length ) {
		print "Excluding id: $id with length: $length\n";

		# count number of excluded sequences
		$excluded_sequences++;

	} else {
		print "Keeping id: $id with sufficient length: $length\n";
		print $fasta_out ">$id\n$seq\n";

		# count number of kept sequences
		$kept_sequences++;

		# track lengths after filtering
		push( @lengths_after_filtering, $length );
	}
}

# calculate the average sequence lengths before and after filtering
my $avg_length_before = calculate_average_sequence_length( \@lengths_before_filtering );
my $avg_length_after = calculate_average_sequence_length( \@lengths_after_filtering );

# print out stats
print "Excluded $excluded_sequences sequences and kept $kept_sequences sequences (out of $total_sequence_count).\n";
print "Average sequence length before filtering: $avg_length_before\n";
print "Average sequence length after filtering: $avg_length_after\n";

# calculate the average sequence length
sub calculate_average_sequence_length {
	my $lengths = shift;

	# print Dumper( $lengths );

	my $num_elements = scalar @$lengths;
	print "num elements: $num_elements\n";
	my $total_sum_of_lengths = 0;

	foreach my $length ( @$lengths ) {
		$total_sum_of_lengths += $length;
	}

	my $avg_length = $total_sum_of_lengths / $num_elements;

	return $avg_length;
}
