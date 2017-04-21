#!usr/bin/perl -w
use strict;
use List::Util qw/shuffle/;

die "perl $0 <adonis_dilution_curve_results_dir> <output_dir>" unless @ARGV==2;

`ls $ARGV[0]/tmp/*/results.txt > $ARGV[0]/results.list`;
mkdir $ARGV[1];
# Combine the adonis results
open OUT,">$ARGV[1]/results.txt" or die "can't open $ARGV[1]/results.txt\n";
print OUT "Category\tNum_not_NA\tSumOfSq_Category\tSumOfSq_Residuals\tR2\tP\tFDR\tNum_Samples\tNO.Repeat\n"; # Print the header line
# Open the results list
open LIST,"$ARGV[0]/results.list" or die "can't open $ARGV[0]/results.list\n";
while(<LIST>){
	chomp;
	my @results_dir = split(/\//);
	my @names = split(/\_/,$results_dir[-2]);
	my $samples = substr($names[0],1); # Sample size 
	# Open the results files in the list
	open IN,$_ or die "can't open $_\n";
	<IN>;
	while(my $line = <IN>){
		chomp($line);
		print OUT $line,"\t$samples\t$names[1]\n";
	}
	close IN;
}
close LIST;
close OUT;
# Combine the adonis results, finished

# Plot with R 
open R,">$ARGV[1]/results.r" or die "can't create\n";# Create R script
print R "
library(ggplot2)
dta <- read.table(\"$ARGV[1]/results.txt\", header = T, sep = \"\\t\") # Read in the data
dta\$logFDR <- -log10(dta\$FDR) # Transformation
ggplot(dta,aes(Num_Samples,logFDR)) + geom_point() + geom_smooth(color = \"steelblue\") + geom_hline(yintercept = -log10(0.05),color=\"tomato3\") + theme_bw() + facet_wrap(~Category,scales = \"free_y\") + ylab(\"-lg(FDR)\") # Plot
ggsave(\"$ARGV[1]/results_logFDR.pdf\") # Save the plot
";
close R;
`R --no-save < $ARGV[1]/results.r`;
# Plot with R, finished 
