#!/usr/bin/perl

use strict;

MAIN : {

    my ($super_matrix, $SV_file,$window_size) = @ARGV;
    if ((not defined $super_matrix) ||
	(not defined $SV_file) ||
	(not defined $window_size)) {
	die ("Usage: ./extract_diamonds_SV.pl <super matrix> <SV file> <window size>\n");
    }

    my $hash;
    #print "Loading matrix...\n";
    open(FILE,$super_matrix)||die"$super_matrix does not exist!\n";
    while (my $line = <FILE>) {
	chomp $line;
	my ($loc1, $loc2, $n) = split(/\t/,$line);
	my ($c1, $r1) = split(/:/,$loc1);
	my ($c2, $r2) = split(/:/,$loc2);
	my ($s1, $e1) = split(/-/,$r1);
	my ($s2, $e2) = split(/-/,$r2);
	$hash->{$c1}->{$s1}->{$c2}->{$s2} = $n;
	$hash->{$c2}->{$s2}->{$c1}->{$s1} = $n;
    }
    close FILE;
    #print "Matrix loaded.\n";
    open(SV,$SV_file)||die"$SV_file does not exist!\n";
    my $bin_size = 40000;
    my (@lines,$chr1,$chr2,$s11,$s12,$s21,$s22,$std1,$std2,$site1,$site2)=();
    while(my $line = <SV>){
    	@lines = split /\s+/,$line;
	#print "$lines[0]	$lines[1]	$lines[2]	$lines[3]	$lines[4]	$lines[5]	$lines[6]	$lines[7]	$lines[8]	$lines[9]\n";
	$chr1 = $lines[1];
	$s11 = (int($lines[2]/$bin_size)+1)*$bin_size;
	$s12 = (int($lines[3]/$bin_size))*$bin_size;
	$std1 = $lines[4];
	$chr2 = $lines[5];
	$s21 = (int($lines[6]/$bin_size)+1)*$bin_size;
	$s22 = (int($lines[7]/$bin_size))*$bin_size;
	$std2 = $lines[8];
	if($std1 eq '-'){
		if($std2 eq '-'){
			$site1 = $s11;
			$site2 = $s21;
			for(my $j = $site2+$window_size; $j>$site2; $j-=$bin_size){
				for(my $i = $site1+$bin_size; $i<=$site1+$window_size;$i += $bin_size){
					my $n;
					if(defined $hash->{$chr1}->{$i}->{$chr2}->{$j}){
						$n = $hash->{$chr1}->{$i}->{$chr2}->{$j};
					}else{
						$n = 0;
					}
					print $n."\t";
				}
			}
			print "\n";
		}elsif($std2 eq '+'){
			$site1 = $s11;
			$site2 = $s22;
			for (my $i = $site1+$window_size;$i>$site1;$i-=$bin_size){
				for(my $j = $site2-$bin_size;$j>=$site2-$window_size;$j-=$bin_size){
                                        my $n;
                                        if(defined $hash->{$chr1}->{$i}->{$chr2}->{$j}){
                                                $n = $hash->{$chr1}->{$i}->{$chr2}->{$j};
                                        }else{  
                                                $n = 0;
                                        }
                                        print $n."\t";
				}
			}
			print "\n";
		}else{die;}
	}elsif($std1 eq '+'){
		if($std2 eq '-'){
			$site1 = $s12;
			$site2 = $s21;
			for(my $i = $site1-$window_size;$i<$site1;$i+=$bin_size){
				for(my $j = $site2+$bin_size;$j<=$site2+$window_size;$j+=$bin_size){
                                        my $n;
                                        if(defined $hash->{$chr1}->{$i}->{$chr2}->{$j}){
                                                $n = $hash->{$chr1}->{$i}->{$chr2}->{$j};
                                        }else{
                                                $n = 0;
                                        }
                                        print $n."\t";
				}
			}
			print "\n";
		}elsif($std2 eq '+'){
			$site1 = $s12;
			$site2 = $s22;
			for(my $j =$site2-$window_size;$j<$site2;$j+=$bin_size ){
				for(my $i =$site1-$bin_size;$i>=$site1-$window_size;$i-=$bin_size){
                                        my $n;
                                        if(defined $hash->{$chr1}->{$i}->{$chr2}->{$j}){
                                                $n = $hash->{$chr1}->{$i}->{$chr2}->{$j};
                                        }else{
                                                $n = 0;
                                        }
                                        print $n."\t";
				}
			}
			print "\n";
		}else{die;}
	}else{die;}
    }
    close SV;
}
