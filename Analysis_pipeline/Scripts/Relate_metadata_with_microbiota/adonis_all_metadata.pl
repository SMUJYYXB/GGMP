#!/usr/bin/perl -w
use strict;
use threads;
use threads::shared;

#Author: Yan He
#Date: 2016.08.08
#Contact: 197053351@qq.com or bioyanhe@gmail.com
#Copyright: Hong-Wei Zhou

die "perl $0 <dm.txt> <metadata.txt> <categories> <output_dir> <threads>\n" unless @ARGV==5;

open IN,$ARGV[1] or die "can't open $ARGV[1]\n";#Read in the metadata

#Document targeted categories in %metadata
my @metadata=split(/,/,$ARGV[2]);

#Document metadata in %hash
my $first_line=<IN>;
chomp $first_line;
my @first_line=split(/\t/,$first_line);
shift @first_line;

my %hash;

while (<IN>)
{
	chomp;
	my @line=split(/\t/);
	my $sample=shift @line;
	foreach my $i(0..$#line)
	{
		next if $line[$i] eq "NA"; #exclude NA as adonis do not accept NAs
		$hash{$first_line[$i]}.="$sample\t$line[$i]\n";#Create a seperate mapping file for each metadata category
	}
}
close IN;
#Document metadata in %hash, finished

#Do adonis test for each metadata
mkdir $ARGV[3];
mkdir "$ARGV[3]";
mkdir "$ARGV[3]/adonis";
open RE,">$ARGV[3]/results.txt";
print RE "Category\tNum_not_NA\tSumOfSq_Category\tSumOfSq_Residuals\tR2\tP\n";
my $thread_num = 0;

foreach my $keys(@metadata)
{
	
	if ($thread_num >= $ARGV[4]) #Control the threads of parallel running
        {                                                                                                         
                for my $t (threads->list(threads::joinable))                                                      
                {
			$t->join();                                                                               
                        $thread_num--;                                                                            
                }                                                                                                 
                redo;                                                                                             
        }

	threads->create(\&adonis,"$keys","$hash{$keys}");#Do adonis test
	$thread_num++; 
}

for my $t (threads->list())
{                                                                                                                 
	$t->join();                                                                                               
}
#Do adonis test for each metadata, finished

#Arrange adonis test results, do FDR correction
open R,">$ARGV[3]/results.r";
print R "
data=read.table(\"$ARGV[3]/results.txt\",header=T)
data\$FDR=p.adjust(data\$P,method=\"fdr\")#FDR correction
write.table(data,\"$ARGV[3]/results.txt\",row.names = F,quote = F,sep=\"\\t\")

subset=subset(data,FDR<0.1)#Only output and plot those with FDR P < 0.1

#Let's plot
library(ggplot2)
pdf(\"$ARGV[3]/results.pdf\",height=5,width=4,useDingbats=FALSE)

sort=factor(subset\$Category,subset[order(subset\$R2),]\$Category)
p<-ggplot(subset,aes(y=R2,x=sort))

p + theme_classic() + geom_bar(stat=\"identity\",color=\"black\",fill=\"#797b77\") + ylab(\"Category\") + coord_flip()
";
`R --no-save < $ARGV[3]/results.r`;
#Arrange adonis test results, do FDR correction, finished

#Create a adonis sub-program to do adonis for each metadata
sub adonis{
	
	#Create a distance-matrix and metadata specific to this metadata
	mkdir "$ARGV[3]/adonis/$_[0]";
	open OUT,">$ARGV[3]/adonis/$_[0]/$_[0].meta.txt";   
	print OUT "#SampleID\t$_[0]\n";
	print OUT $_[1];
	
	`filter_distance_matrix.py -i $ARGV[0] -o $ARGV[3]/adonis/$_[0]/$_[0].dm.txt --sample_id_fp $ARGV[3]/adonis/$_[0]/$_[0].meta.txt`;
	#Create a distance-matrix and metadata specific to this metadata, finished
	
	`compare_categories.py --method adonis -i $ARGV[3]/adonis/$_[0]/$_[0].dm.txt -m $ARGV[3]/adonis/$_[0]/$_[0].meta.txt -c $_[0] -o $ARGV[3]/adonis/$_[0]/adonis_out -n 999`;#Do adonis test using QIIME
	
	#Read adonis result, arrange them into one tab-delimited file
	open AD,"$ARGV[3]/adonis/$_[0]/adonis_out/adonis_results.txt" or die "No adonis_results were found for $_[0]\n";
	foreach (1..10)
	{
        	<AD>;#We don't need the first 10 lines
	}
	my @return;
        my $line=<AD>;
	chomp $line;
	my @line=split(/\s+/,$line);
        @return=($line[2],$line[5],$line[6]);
        $line=<AD>;
        @line=split(/\s+/,$line);
        push @return,$line[2];
	$line=<AD>;
	@line=split(/\s+/,$line);
	push @return,$line[1];
	print RE $_[0],"\t",$return[4],"\t",$return[0],"\t",$return[3],"\t",$return[1],"\t",$return[2],"\n";
	#Read adonis result, arrange them into one tab-delimited file, finished

}
