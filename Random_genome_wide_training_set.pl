#/usr/bin/perl
use strict;
use warnings;
my ($tad_file, $chr_fai,$cellline,$sample) = @ARGV;
if ((not defined $tad_file) ||(not defined $chr_fai)||(not defined $cellline)||(not defined $sample)) {
	die ("Usage: perl ./Random_genome_wide_training_set.pl <tad_file> <chromosome fai file> <cell line> <sample number>\n");
}
open FAI,"<$chr_fai"||die "$chr_fai not found!\n";
my (@array,$sum,%acumchrsize,%chr,$i,@result,$start,$end,%rand) = ();
$sum = 0;
while(<FAI>){
	@array = split /\s+/, $_;
	$acumchrsize{$array[0]} = $sum;
	#print "$array[0]	$sum\n";
	$i = 0;
	while($i<int($array[1]/40000) +1){
		$chr{$sum} = $array[0];
		#print "$sum	$array[0]\n";
		$i++;
		$sum++;
	}
	#$sum += int($array[1]/40000) +1;
}
#print "$sum\n";
open TAD,"<$tad_file"||die "$tad_file not found!\n";
while(<TAD>){
	#print;
	chomp;
	@array = split /\s+/;
	$array[1]%40000==0 || die"$tad_file should be a 40kb bin-sized TAD file!\n";
	$start = $acumchrsize{$array[0]}+$array[1]/40000;
	$end = $acumchrsize{$array[0]}+$array[2]/40000;
	#print "$start	$end\n";
	for($i=$start+1;$i<$end;$i++){
		$result[$i] = 0;
	}
}
for($i=1;$i<=$sum;$i++){
	$result[$i]=1 if(not defined($result[$i]));
	#print "$i	$result[$i]\n";
}
while(scalar(keys %rand)<=$sample){
	my $temp = int(rand($sum+1));
	next if($temp ==0 || $temp ==$sum);
	$rand{$temp} = 1;
}
@array = keys %rand;
open TRAIN,">$cellline.training.diamond.txt";
open CV,">$cellline.crossvalidation.diamond.txt";
for($i=0;$i<$sample;$i++){
	#print "$array[$i]\n";
	defined($result[$array[$i]])||die "$array[$i]";
	defined($chr{$array[$i]})||die "$array[$i]";
	defined($acumchrsize{$chr{$array[$i]}})||die "$array[$i]";
	if($i<int($sample*0.7)){
		print TRAIN $result[$array[$i]],"\t",$chr{$array[$i]},"\t",($array[$i]-$acumchrsize{$chr{$array[$i]}})*40000,"\n";
	}else{
		print CV $result[$array[$i]],"\t",$chr{$array[$i]},"\t",($array[$i]-$acumchrsize{$chr{$array[$i]}})*40000,"\n";
	}
}
close TRAIN;
close CV;
