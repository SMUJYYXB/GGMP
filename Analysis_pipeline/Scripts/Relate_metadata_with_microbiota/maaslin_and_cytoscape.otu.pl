#!/usr/bin/perl -w
use strict;

#Author: Yan He
#Date: 2016.08.08
#Contact: 197053351@qq.com or bioyanhe@gmail.com
#Copyright: Hong-Wei Zhou

die "perl $0 <QIIME_otu_table.txt> <mapping_file> <metadata> <confounders> <metadata_categories> <output_dir>\n" unless @ARGV==6;

mkdir "$ARGV[5]";

#Create MaAsLin input

#Document metadata that we are going to use for analysis
my @metadata=split(/,/,$ARGV[2]);#Those are the metadata we are going to include in MaAsLin analysis
my %metadata;
foreach (@metadata)
{
	$metadata{$_}=1;
}
#Document metadata that we are going to use for analysis, finished

#Processing the mapping file
open IN,$ARGV[1] or die "can't open $ARGV[1]\n";#Read in the mapping file

my $first_map=<IN>;
chomp $first_map;
my @first_map=split(/\t/,$first_map);#The first row of metadata
shift @first_map;

my %map;
while (<IN>)
{
	chomp;
	my @line=split(/\t/);#Processing each row of the metadata
	my $sample_id=shift @line;#SampleID is in the first column
	
	foreach my $i(0..$#line)
	{
		next unless exists $metadata{$first_map[$i]};#Exclude metadata that we do not want to analyze
		$map{$first_map[$i]}{$sample_id}=$line[$i];
	}
}
close IN;
#Processing the mapping file, finished

#Processing the otu table file, and combine it with the mapping file
open IN,$ARGV[0] or die "can't open $ARGV[0]\n";#Read in the otu table file
open OUT,">$ARGV[5]/maaslin.input.txt";#Create the input file for MaAsLin analysis
<IN>;
chomp(my $first_taxa=<IN>);
my @first_taxa=split(/\t/,$first_taxa);
shift @first_taxa;
pop @first_taxa;

#Output the first row of MaAsLin input
my $maaslin_first_row=join("\t",@first_taxa);
print OUT "sample\t$maaslin_first_row\n";
#Output the first row of MaAsLin input, finished

#Output metadata of MaAsLin input
foreach (@metadata)
{
	print OUT $_;
	foreach my $sample(@first_taxa)
	{
		print OUT "\t",$map{$_}{$sample};
	}
	print OUT "\n";
}
#Output metadata of MaAsLin input, finished

#Output taxonomic information of MaAsLin input
my $first_otu="";
my %abundance;#Document average abundances for each otu
my %phylum;#Document phylum information for each otu
my %class;#Document class information for each otu
my %order;#Document order information for each otu
my %family;#Document family information for each otu
my %genus;#Document genus information for each otu
my %species;#Document species information for each otu
my %otu_name;#Document otu names for each otu

while (<IN>)
{
	chomp;
	my @line=split(/\t/);
	my $otu=shift @line;#Otu number is in the first column
	$otu="OTU".$otu;
	my $otu_name=pop @line;
	my $abundance=join("\t",@line);#The rest if abundance information
	
	#Format name
	my @taxa=split(/;/,$otu_name);
	$phylum{$otu}=$taxa[1];#To which phylum does this otu belong.
        $class{$otu}=$taxa[2];#To which phylum does this otu belong.
        $order{$otu}=$taxa[3];#To which order does this otu belong.
        $family{$otu}=$taxa[4];#To which family does this otu belong.
        $genus{$otu}=$taxa[5];#To which genus does this otu belong.
        $species{$otu}=$taxa[6];#To which species does this otu belong.

	while($taxa[-1]=~/__$/){
		pop @taxa;
	}
	my $otu_shortname=$taxa[-1];
	$otu_shortname=substr($otu_shortname,3);
	#Format name, finished	
	
	$otu_name{$otu}=$otu_shortname;
	
	$first_otu=$otu if $first_otu eq "";#We need to know the first otu in the MaAsLin input for formatting
	print OUT $otu,"\t",$abundance,"\n";

	#Calcualte average abundance
	my $total_abundance=0;
	foreach my $abundance(@line)
	{
		$total_abundance+=$abundance;
	}
	$abundance{$otu}=$total_abundance/($#line+1);
	#Calcualte average abundance, finished
}

#Output taxonomic information of MaAsLin input, finished
#Processing the taxonomy file, and combine it with the mapping file, finished		

#Create MaAsLin input, finished

=pod
Document categories of each metadata
The format of metadata categories file:
Category	Metadata
Dietary	frequency_meat
Dietary	frequency_milk
Economy	income
...
=cut

my %category;
open IN,$ARGV[4] or die "can't open $ARGV[4]\n";#Read in the category file
<IN>;
while (<IN>)
{
	chomp;
	my @line=split(/\t/);
	$category{$line[1]}=$line[0];
}
#Document categories of each metadata, finished

#Do MaAsLin analysis
#Transpose the input file according to MaAsLin's requirement
`transpose.py < $ARGV[5]/maaslin.input.txt > $ARGV[5]/maaslin.tsv`;

 
#Do MaAsLin for all metadata with the named confounders
mkdir "$ARGV[5]/maaslin_all_vs_confounders";
open OUT,">$ARGV[5]/maaslin_all_vs_confounders/maaslin.config";

print OUT "
Matrix: Metadata
Read_PCL_Rows: -$metadata[-1]

Matrix: Abundance
Read_PCL_Rows: $first_otu-
";

`Maaslin.R $ARGV[5]/maaslin.tsv $ARGV[5]/maaslin_all_vs_confounders/maaslin_output -i $ARGV[5]/maaslin_all_vs_confounders/maaslin.config -d 0.25 -O -a -F $ARGV[3] -r 0.00001 -p 0.005 -Q -s none`;

close OUT;
#Do MaAsLin for all metadata with the named confounders, finished


#Re-arrange MaAsLin output for cytoscape
#Create the output file and write the head line
open OUT,">$ARGV[5]/edge.txt" or die "can't create $ARGV[5]/edge.txt\n";#Edge file
open OUT2,">$ARGV[5]/node.txt" or die "can't create $ARGV[5]/node.txt\n";#Node file

print OUT "Metadata\tOTU\tOTU_name\tCoefficient\tQ.value\tCorrelation_level\tCorrelation_direction\tMetadata_category\tTaxa_phylum\tTaxa_class\tTaxa_order\tTaxa_family\tTaxa_genus\tTaxa_species\n";
print OUT2 "Node\tGroup\tMetadata_Category\tOTU_name\tTaxa_phylum\tTaxa_class\tTaxa_order\tTaxa_family\tTaxa_genus\tTaxa_species\tTaxa_abundance\n";
my %node; #Document outputed node to avoid replication
my %confounders; #Document outputed confounders to avoid replication

#Process the results for all vs. confounders
open IN,"$ARGV[5]/maaslin_all_vs_confounders/maaslin_output/maaslin.txt" or die "can't open\n";#Read in all vs. confounders results
<IN>;
while (<IN>)
{
	chomp;
	my @line=split(/\t/);

        my $metadata_category = "NA";#If we didn't give the category of this metadata, name it NA
        $metadata_category=$category{$line[1]} if exists $category{$line[1]};

	my $level="all_vs_confounders";#Document the correlation type

	my $direction="Positive";#Document the correlation direction, positive or negative?
        $direction="Negative" if $line[4] < 0;

	print OUT $line[3],"\t",$line[2],"\t",$otu_name{$line[2]},"\t",$line[4],"\t",$line[8],"\t",$level,"\t",$direction,"\t",$metadata_category,"\t",$phylum{$line[2]},"\t",$class{$line[2]},"\t",$order{$line[2]},"\t",$family{$line[2]},"\t",$genus{$line[2]},"\t",$species{$line[2]},"\n";#Output this correlation

	#For each correlation, we have two node, if we haven't outputed them yet, do it 
	unless (exists $node{$line[1]})
	{
		print OUT2 $line[3],"\tMetadata\t",$metadata_category,"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\t1\n";
		$node{$line[1]}=1;
	}

	unless (exists $node{$line[2]})
	{
		print OUT2 $line[2],"\tTaxa\tNA\t",$otu_name{$line[2]},"\t",$phylum{$line[2]},"\t",$class{$line[2]},"\t",$order{$line[2]},"\t",$family{$line[2]},"\t",$genus{$line[2]},"\t",$species{$line[2]},"\t",$abundance{$line[2]},"\n";
		$node{$line[2]}=1;
	}
	#Output node, finished
}


close IN;
close OUT;
close OUT2;
