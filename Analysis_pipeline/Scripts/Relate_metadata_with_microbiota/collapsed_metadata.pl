#!/usr/bin/perl -w
use strict;
use Getopt::Std;

#Author: Huimin Zheng
#Date: 2017.04.16
#Contact: 328093402@qq.com
#Copyright: Hong-Wei Zhou

my $usage="perl $0 -m <metadata.txt> -l <group> -a [CatVar1,CatVar2..] -b [ConVar1,ConVar2..] -o <output_dir>
This program computes means of continuous variables and proportion of categorical variables for each group.
-o <path of output_dir>        Requried.
-m <path of mapping file>	Requried.
-l <group>	Requried. 
-a [categorical variables]	One of -a and -b is requried.
-b [continuous variables]	
-h [help]
";

use vars qw($opt_l $opt_o $opt_m $opt_a $opt_b $opt_h);
getopts('l:o:m:a:b:h');

if ($opt_h){       
	print $usage,"\n";
        exit(1);
}

unless ($opt_l and $opt_o and $opt_m and ($opt_a or $opt_b)){
        print "$usage\n";
        exit(1);
}

if (-e $opt_o){
        print "output_dir already exists\n";
        exit(1);
}
`mkdir $opt_o`;

my %var_a;# for checking if all categorical variable is in metadata
my %var_b;# for checking if all continuous variable is in metadata
my $var_l;# for checking if $opt_l is in metadata 
my $a;# a logical indicating whether a categorical variable is input
my $b;# a logical indicating whether a continuous variable is input

# get variables
if (!$opt_a){
	$a = "FALSE";
}else{
	$a = "TRUE";
	my @a = split(/,/,$opt_a);
	foreach (@a){$var_a{$_}=0;}
}

if (!$opt_b){
        $b = "FALSE";
}else{
        $b = "TRUE";
        my @b = split(/,/,$opt_b);
	foreach (@b){$var_b{$_}=0;}
}

my $catvar_index;# categorical variable index

# check if variables are in metadata
open IN,"$opt_m" or die "can't open $opt_m\n";
chomp(my $header = <IN>);
my @header = split(/\t/,$header);
for my $i (1..$#header){
	if (exists $var_a{$header[$i]}){
		$var_a{$header[$i]} = 1;
		$catvar_index.= "," . ($i);
	}elsif(exists $var_b{$header[$i]}){
		$var_b{$header[$i]} = 1;
	}elsif($header[$i] eq $opt_l){
		$var_l = 1;
	}
}
$catvar_index = substr($catvar_index,1);
die "Please make sure $opt_l is in metadata.\n" if $var_l != 1;
foreach my $key(keys %var_a){
	die "Please make sure $key is in metadata.\n" if $var_a{$key}==0;
}
foreach my $key(keys %var_b){
        die "Please make sure $key is in metadata.\n" if $var_b{$key}==0;
}
# check if variables are in metadata, finished

# Create R script
open R,">$opt_o/$opt_l.r" or die "can't create $opt_l.r\n";
print R "
library(reshape)
read.table.meta <- function(filename, ...){
	lines <- readLines(filename)
	n <- grep(\"^#\", lines)
	if(length(n) > 0){start <- n[length(n)]}else{start <- 1}
	end <- length(lines)
	x <- read.table(text=lines[start:end],comment.char = '',check.names=F,...)
}
# Read metadata.txt
meta <- read.table.meta(\"$opt_m\",header = T, sep = \"\\t\",row.names = 1)

# Count number of samples
$opt_l <- data.frame(table(meta\$$opt_l),row.names = 1)

# CatVar prop
if ($a){
  dstats_CatVar <- function(dta,catvar,level,name){
    x <- cast(data.frame(t(xtabs(~ catvar + level,data = dta))),level~catvar,value = \"Freq\")
    na <- aggregate(catvar,by=list(level=level),function(sna){sum(is.na(sna))})
    x <- data.frame(merge(x,na,by=\"level\"),row.names = 1)
    p <- data.frame(t(apply(x,1,prop.table)))
    p <- p[,-ncol(p)]
    names(p) <- paste(name,names(p),sep=\"_\")
    if (length(names(p))==2){
      p <- subset(p,select = names(p)[2])
    }
    return(p)
  }

  d.catvar <- $opt_l
  for (i in c($catvar_index)){
    d <- dstats_CatVar(meta,meta[,i],meta\$$opt_l,names(meta)[i])
    d.catvar <- data.frame(merge(d.catvar,d,by=\"row.names\",all = T),row.names = 1)
  }
}

# ConVar mean
if ($b){
  mean_na <- function(x)(mean = mean(x,na.rm = T))
  dta.convar <- subset(meta,select = c($opt_l,$opt_b))
  d <- melt(dta.convar,measure.vars = names(dta.convar)[c(2:ncol(dta.convar))],id.vars = c(\"$opt_l\"))
  d.convar <- data.frame(cast(d,$opt_l~variable,mean_na),row.names = 1)
}

# Output
if ($a & $b){
  $opt_l <- merge(d.catvar,d.convar,by=\"row.names\",all =T)
  names($opt_l)[1] <- \"$opt_l\"
  write.table($opt_l,\"$opt_o/$opt_l.map.txt\",quote=F,row.names=F,sep=\"\\t\")
}else if ($a){
  $opt_l <- data.frame($opt_l = row.names(d.catvar),d.catvar)
  write.table($opt_l,\"$opt_o/$opt_l.map.txt\",quote=F,row.names=F,sep=\"\\t\")
}else if ($b){
  $opt_l <- data.frame($opt_l = row.names(d.convar),d.convar)
  write.table($opt_l,\"$opt_o/$opt_l.map.txt\",quote=F,row.names=F,sep=\"\\t\")
}

";
# Create R script, finished
# Execute
`R --no-save < $opt_o/$opt_l.r`;

