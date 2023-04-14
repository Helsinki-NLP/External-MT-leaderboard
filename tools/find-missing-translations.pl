#!/usr/bin/env perl
#
# find sentences for which we already have translations
# to avoid translating them again
#
# find-missing-translations -i source.txt -o source-with-translations.txt < existing-translations.txt > missing-translations.txt
#
#   -i input-text
#   -o output-text
#
#  source.txt: input text with one sentence per line (MT testset)
#  source-with-translations.txt: tsv file with source sentences and target sentences
#                                (for sentences where we already know the translation)
#  existing-translations.txt: translations of sentences (blocks of 3 lines: source, reference, system translation)
#  missing-translations.txt: all sentences for which no translation could be found (unique set, sorted by length)


use strict;

use Getopt::Std;

our($opt_i, $opt_o);
getopt('i:o:');


my %trans = ();

while (<>){
    chomp;
    next unless /\S/;  # skip empty lines (separates blocks)
    my $r = <>;        # reference translation (ignore)
    my $t = <>;        # system translatino (save)
    $trans{$_} = $t;
}

open I,"<$opt_i" || die "cannot read from $opt_i";
open O,">$opt_o" || die "cannot write to $opt_o";

my %missing = ();
my $nrfound = 0;
my $nrmissing = 0;

while (<I>){
    chomp;
    if (exists $trans{$_}){
	print O $_,"\t",$trans{$_};
	$nrfound++;
    }
    else{
	print O $_,"\n";
	$missing{$_} = length($_);
	$nrmissing++;
    }	
}

print STDERR " - nr of translations found: ",$nrfound,"\n";
print STDERR " - nr of translations missing: ",$nrmissing,"\n";
print STDERR " - nr of unique sentences to be translated: ",scalar keys %missing,"\n";

foreach (sort {$missing{$a} <=> $missing{$b}} keys %missing){
    print $_,"\n";
}

