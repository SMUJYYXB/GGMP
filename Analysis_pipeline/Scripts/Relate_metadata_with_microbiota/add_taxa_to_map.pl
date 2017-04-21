#!/usr/bin/perl -w
use strict;
#Author: Huimin Zheng
#Date: 2017.04.16
#Contact: 328093402@qq.com
#Copyright: Hong-Wei Zhou

die "perl $0 <taxonomy_dir> <output_file> <otu_table.txt_prefix> <intrest_taxa.list> <map.txt>\n" unless @ARGV==5;

open OUT,">$ARGV[1]" or die "can't create output_file\n";

#save map.txt into $mapfirst and %map(key:sampleid;value:rest of line)
open MAP,"$ARGV[4]" or die "can't open map.txt\n";
chomp(my $mapfirst=<MAP>);
my %map;
while(<MAP>)
{
	chomp;
	my @map=split(/\t/);
	my $sid=shift @map;
	my $map=join("\t",@map);
	$map{$sid}=$map;
}
close MAP;
#save map.txt into $mapfirst and %map(key:sampleid;value:rest of line)

#save intrest_taxa.list into %list
open LIST,"$ARGV[3]" or die "can't open intrest_taxa.list\n";
my %list;
while(<LIST>)
{
	chomp;
	$list{$_}=$_;
}
close LIST;
#save intrest_taxa.list into %list

#search taxafiles for intrest taxa
my $first;
foreach my $i(2..6)
{
	open IN,"$ARGV[0]/$ARGV[2]$i.txt" or die "can't open taxonomic file:$ARGV[0]/$ARGV[2]$i.txt\n";
	<IN>;
	$first=<IN>;
	chomp $first;
	my @first=split(/\t/,$first);
	while(<IN>)
	{
		chomp;
		my @line=split(/\t/);
		if($list{$line[0]})
		{
			$list{$line[0]}="found";
			my %hash;
			my @colname=split(/;/,$line[0]);
			$mapfirst=$mapfirst."\t".$colname[-1];
			for my $x(1..$#first)
			{
				$hash{$first[$x]}=$line[$x];
			}
			foreach my $key(keys %map)
			{
				if($hash{$key})
				{
				$map{$key}=$map{$key}."\t"."$hash{$key}";	
				}else{
				$map{$key}=$map{$key}."\t"."NA";
				}
			}
		}
	}
	close IN;
}

foreach my $key1(keys %list)
{
	if ($list{$key1} ne "found")
	{
		print "please check: $key1\n";
	}
}

print OUT "$mapfirst\n";


foreach my $key2(sort keys %map)
{
	print OUT "$key2\t$map{$key2}\n";
}
close OUT;
