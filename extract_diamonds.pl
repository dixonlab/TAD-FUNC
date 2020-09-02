#!/usr/bin/perl

use strict;

MAIN : {

    my ($super_matrix, $diamond_file,$window_size) = @ARGV;
    if ((not defined $super_matrix) ||
	(not defined $diamond_file) ||
	(not defined $window_size)) {
	die ("Usage: ./extract_diamonds.pl <super matrix> <diamond file> <window size>\n");
    }

#    my ($chr, $site) = split(/:/,$region);
#    my $start = $site-$window_size;
#    my $end = $site+$window_size;

    my $hash;

    open(FILE,$super_matrix)||die"$super_matrix does not exist!\n";
    while (my $line = <FILE>) {
	chomp $line;
	my ($loc1, $loc2, $n) = split(/\t/,$line);
	my ($c1, $r1) = split(/:/,$loc1);
	my ($c2, $r2) = split(/:/,$loc2);
	my ($s1, $e1) = split(/-/,$r1);
	my ($s2, $e2) = split(/-/,$r2);
	if($c1 eq $c2){
		$hash->{$c1}->{$s1}->{$c2}->{$s2} = $n;
		$hash->{$c2}->{$s2}->{$c1}->{$s1} = $n;
	}
    }
    close FILE;
    open(DIAMOND,$diamond_file)||die"$diamond_file does not exist!\n";
    my $bin_size = 40000;
    while(my $line = <DIAMOND>){
   	chomp $line;
    	my ($y,$chr,$site) = split(/\t/,$line);
	my $start = $site - $window_size;
	my $end = $site + $window_size;
	print $y . "\t";
	
    	
    	for (my $i = $start; $i < $site; $i += $bin_size) {
		for (my $j = $site+$bin_size; $j <= $end; $j += $bin_size) {
		    my $n;
		    if (defined $hash->{$chr}->{$i}->{$chr}->{$j}) {
			$n = $hash->{$chr}->{$i}->{$chr}->{$j};
		    } else {
			$n = 0;
		    }
		    print $n . "\t";
		}
		#print "\n";
	}
	print "\n";
    }
    close DIAMOND;
}
