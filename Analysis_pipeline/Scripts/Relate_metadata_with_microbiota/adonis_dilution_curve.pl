#!usr/bin/perl -w
use strict;
use List::Util qw/shuffle/;
#Author: Huimin Zheng
#Date: 2017.04.16
#Contact: 328093402@qq.com
#Copyright: Hong-Wei Zhou


#Get the location of this script, since it has used other scripts, we need to get the location of all of them
use File::Spec;
my $path_script=File::Spec->rel2abs(__FILE__);
my @path_script=split(/\//,$path_script);
pop @path_script;
my $dir_script=join("/",@path_script);
#Get the location of this script, finished

die "perl $0 <dm.txt> <meta.txt> <variable1,variable2..> <output_dir> <repeat>" unless @ARGV==5;

mkdir $ARGV[3];
mkdir "$ARGV[3]/tmp";

# Document the sample ID
open DM,"$ARGV[0]" or die "can't open $ARGV[0]\n";
chomp(my $samples = <DM>);
my @samples = split(/\t/,$samples);
shift @samples;
close DM;
# Document the sample ID, finished

my $n = 200; # Sample size 
foreach my $i (1..15){
	for my $j (1..$ARGV[4]){
		# Random sampling
		my @samples = shuffle(@samples);
		next if (-e "$ARGV[3]/tmp/s$n\_$j.list");
		open LIST,">$ARGV[3]/tmp/s$n\_$j.list" or die "can't creat\n";
			for my $s (1..$n){
				print LIST "$samples[$s]\n";
			}
		close LIST;
		# Filter distance matrix 
		`filter_distance_matrix.py -i $ARGV[0] -o $ARGV[3]/tmp/s$n\_$j.dm.txt --sample_id_fp $ARGV[3]/tmp/s$n\_$j.list`;
		# Do adonis test
		`perl $dir_script/adonis_all_metadata.pl $ARGV[3]/tmp/s$n\_$j.dm.txt $ARGV[1] $ARGV[2] $ARGV[3]/tmp/s$n\_$j 7`;
	}
	# Step = 200 if Sample size < 2000 else step = 1000
	if ($n <2000){
		$n += 200;
	}else{
		$n += 1000;
	}
}
