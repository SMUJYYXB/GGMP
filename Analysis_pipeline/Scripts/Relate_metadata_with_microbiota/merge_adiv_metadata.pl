#!/usr/bin/perl -w
use strict;
#Author: Yan He
##Date: 2016.08.08
##Contact: 197053351@qq.com or bioyanhe@gmail.com
##Copyright: Hong-Wei Zhou

die "perl $0 <adiv.txt> <map.txt> <output>\n" unless @ARGV==3;

# Open alpha diversity file
open IN,$ARGV[0] or die "can't open adiv.txt\n";
# Open metadata file
open IN2,$ARGV[1] or die "can't open map.txt\n";
# Create output file
open OUT,">$ARGV[2]" or die "can't create output\n";

# Get the header line of metadata
my $first_map=<IN2>;
chomp $first_map; # Remove the "\n"
$first_map=substr($first_map,1);# Remove the "#" 
# Get the header line of metadta, finished

# Output the merged header line
# Get the header line of alpha diversity file
my $first_adiv=<IN>;
chomp $first_adiv; # Remove the "\n"
# Remove the "#SampleID"
my @first_adiv=split(/\t/,$first_adiv);
shift @first_adiv;
$first_adiv=join("\t",@first_adiv);
# Remove the "#SampleID", finished
print OUT $first_map,"\t",$first_adiv,"\n";
# Output the merged header line, finishied

# Read the metadata into %hash
my %hash;
while (<IN2>)
{
	chomp;
	my @line=split(/\t/);
	my $sample=shift @line;
	my $meta=join("\t",@line);
	$hash{$sample}=$meta; 
}
# Read the metadata into %hash, finished

# Read the alpha diversity and output with metadata 
while (<IN>)
{
	chomp;
	my @line=split(/\t/);
	my $sample=shift @line;
	my $line=join("\t",@line);
	next unless exists $hash{$sample};
	# Print out samples both in metadata and alpha diversity file
	print OUT $sample,"\t",$hash{$sample},"\t",$line,"\n";
}
# Read the alpha diversity and output with metadata, finished
close IN;
close IN2;
close OUT;

