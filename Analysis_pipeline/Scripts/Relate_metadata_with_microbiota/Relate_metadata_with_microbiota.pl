#!/usr/bin/perl
#Author: Huimin Zheng
#Date: 2017.04.18
#Contact: 328093402@qq.com
#Copyright: Hong-Wei Zhou

use warnings; 
use strict;

die "perl $0 <otu_table.biom> <metadata> <output_dir>\n" unless @ARGV==3;

#These are the categories we would like to correlate with gut microbiota:
my $metadata="MetS,anthrop_waist,biochem_TG,biochem_SBP,biochem_DBP,biochem_HDL,biochem_FBG";

#Get the location of this script, since it has used other scripts, we need to get the location of all of them
use File::Spec;

my $path_script=File::Spec->rel2abs(__FILE__);
my @path_script=split(/\//,$path_script);
pop @path_script;
my $dir_script=join("/",@path_script);
#Get the location of this script, finished

mkdir $ARGV[2];#Put results in this directory
mkdir "$ARGV[2]/tmp/";

#Rarefy our biom
`single_rarefaction.py -i $ARGV[0] -o $ARGV[2]/tmp/CGMP.otu_table_even10000.biom -d 10000`;#Normalize all samples to 10000 sequences/sample
#Generate taxononomic profile for the rarefied biom, this biom will be used in the following analysis
`summarize_taxa.py -i $ARGV[2]/tmp/CGMP.otu_table_even10000.biom -o $ARGV[2]/tmp/Taxonomy_even10000 -L 2,3,4,5,6,7`;

#Alpha diversity analysis
mkdir "$ARGV[2]/tmp/Alpha_diversity";

#Using QIIME to calculate alpha diversity for each sample, -t point to the tree for GreenGenes tree file (v13_8)
my $alpha_diversity="PD_whole_tree,shannon";#Four indices we would like to calculate
my @alpha_diversity=split(/,/,$alpha_diversity);

`alpha_diversity.py -i $ARGV[2]/tmp/CGMP.otu_table_even10000.biom -o $ARGV[2]/tmp/Alpha_diversity/adiv.txt -m chao1,PD_whole_tree,shannon,observed_species -t /usr/local/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/trees/97_otus.tree`;

#Correlate alpha diversity with metadata
#Merge metadata with alpha diversity
`perl $dir_script/merge_adiv_metadata.pl $ARGV[2]/tmp/Alpha_diversity/adiv.txt $ARGV[1] $ARGV[2]/tmp/Alpha_diversity/adiv.metadata.txt`;

#Beta diversity analysis
mkdir "$ARGV[2]/tmp/Beta_diversity";
#Using QIIME to generate beta diversity distance matrix
my $beta_diversity="bray_curtis,unweighted_unifrac,weighted_unifrac";
my @beta_diversity=split(/,/,$beta_diversity);

`beta_diversity.py -i $ARGV[2]/tmp/CGMP.otu_table_even10000.biom -o $ARGV[2]/tmp/Beta_diversity/distance_matrix -m $beta_diversity -t /usr/local/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/trees/97_otus.tree`;

#Adonis test for each metadata
mkdir "$ARGV[2]/tmp/Beta_diversity/Adonis";

foreach (@beta_diversity)
{
	`perl $dir_script/adonis_dilution_curve.pl $ARGV[2]/tmp/Beta_diversity/distance_matrix/$_\_CGMP.otu_table_even10000.txt $ARGV[1] $metadata $ARGV[2]/tmp/Beta_diversity/Adonis/$_ 50`;# 50 replicates done at each step
	`perl $dir_script/adonis_dilution_curve_plot.pl $ARGV[2]/tmp/Beta_diversity/Adonis/$_ $ARGV[2]/tmp/Beta_diversity/Adonis/$_\_plot`;
}
#Adonis test for each metadata, fininished

#Beta diversity analysis, finished

#MaAsLin analysis correlating metadata with specific bacteria
mkdir "$ARGV[2]/tmp/MaAsLin";
#Normalize and filter otus for maaslin analysis
`biom normalize-table -i $ARGV[2]/tmp/CGMP.otu_table_even10000.biom -r -o $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized.biom`;
`filter_otus_from_otu_table.py -i $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized.biom -o $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized_s700.biom -s 700`;
`biom convert -i $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized_s700.biom -o $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized_s700.txt --to-tsv --header-key taxonomy`;
#MaAsLin analysis
`perl $dir_script/maaslin_and_cytoscape.otu.pl $ARGV[2]/tmp/MaAsLin/CGMP.otu_table_even10000_normalized_s700.txt $ARGV[1] MetS,anthrop_waist,anthrop_SBP,anthrop_DBP,biochem_FBG,biochem_TG,biochem_HDL,county_level_code,age,gender,Bristol_stool_type county_level_code,age,gender,Bristol_stool_type $dir_script/metadata_category.txt $ARGV[2]/tmp/MaAsLin/maaslin_MetS_c4_OTUs700`;
#MaAsLin analysis, finished

#Add raletive abundance of some taxonomy in metadata
`perl $dir_script/add_taxa_to_map.pl $ARGV[2]/tmp/Taxonomy_even10000 $ARGV[2]/tmp/metadata.txt CGMP.otu_table_even10000_L $dir_script/taxa.list $ARGV[1]`;
#Add raletive abundance of some taxonomy in metadata, finished

#Collapsed metadata into county level
`perl $dir_script/collapsed_metadata.pl -m $ARGV[2]/tmp/metadata.txt -l county_level_code -a MetS,gender -b anthrop_waist,anthrop_SBP,anthrop_DBP,biochem_FBG,biochem_TG,biochem_HDL,age,fam_income_year_avg,fam_spend_year_avg,c__Alphaproteobacteria,c__Betaproteobacteria,c__Deltaproteobacteria,c__Gammaproteobacteria,p__Proteobacteria -o $ARGV[2]/tmp/collapsed_metadata`;
#Collapsed metadata into county level, finished

#MetS incidences between quartiles
`Rscript MetS_incidences_between_quartiles.R -i $ARGV[2]/tmp/metadata.txt -o $ARGV[2]/tmp/MetS_incidences_between_quartiles`;
#MetS incidences between quartiles, finished
