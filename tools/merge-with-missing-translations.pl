#!/usr/bin/env perl
#
# merge new translations with existing ones
# (output from find-missing-translations.pl + translations)
#
# merge-with-missing-translations.pl -i input.txt -t translations.txt < input-with-existing-translations.txt > output.txt
#
# -i input.txt
# -t translations.txt
#


use strict;

use Getopt::Std;

our($opt_i, $opt_t);
getopt('i:t:');


my %trans = ();

if ($opt_i && $opt_t){
    if ( (-f $opt_i) && (-f $opt_t) ){
	open I,"<$opt_i" || die "cannot read from $opt_i";
	open T,"<$opt_t" || die "cannot read from $opt_t";
	while (<I>){
	    chomp;
	    my $t = <T>;
	    $trans{$_} = $t;
	}
    }
}

while (<>){
    chomp;
    my ($s,$t) = split(/\t/);
    if ($t){
	print $t,"\n";
    }
    elsif (exists $trans{$s}){
	print $trans{$s};
    }
    else{
	print STDERR "Houston, we have a problem! No translation found for '$s'!\n";
	print "\n";
    }
}

