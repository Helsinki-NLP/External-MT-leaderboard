#!/usr/bin/env perl

use strict;

my %scores = ();
my %benchmarks = ();
my %models = ();

exit unless (@ARGV);

foreach my $file (sort @ARGV){
    my @parts = split(/\//,$file);
    my $benchmark = $parts[-2];

    # skip this benchmark, which does not seem to be a valid MT task
    next if ($benchmark eq 'multi30k_task2_test_2016');

    # make benchmark categories
    $benchmark=~s/(flores).*$/$1/;
    $benchmark=~s/(tatoeba)-test.*/$1/;
    $benchmark=~s/(news).*$/$1/;
    $benchmark=~s/(multi30k).*$/$1/;
    $benchmark=~s/(iwslt).*$/$1/;

    # sum scores for each category
    # print STDERR "read $file ($benchmark)\n";
    open F,"<$file" || die "cannot read $file\n";
    while (<F>){
	my ($score,$model) = split(/\t/);
	## tatoeba test is unreliable for OPUS-MT models
	## (oberlap between train and test)
	unless ($benchmark eq 'tatoeba' && $model=~/OPUS-MT-models\//){
	    $scores{$model}{$benchmark} += $score;
	    $benchmarks{$benchmark}{$model}++;
	    $models{$model}++;
	}
    }
    close F;
}


# average scores per category
foreach my $m (keys %scores){
    foreach my $b (keys %{$scores{$m}}){
	$scores{$m}{$b} /= $benchmarks{$b}{$m};
    }
}


# select benchmarks that we have for most models

my %selected_benchmarks = ();
my %selected_models = ();
my $nr_models = scalar keys %models;
my $nr_benchmarks = scalar keys %benchmarks;
my %selection_score = ();

# print STDERR "$nr_models models in total, $nr_benchmarks categories in total\n";

foreach my $b (sort {scalar keys %{$benchmarks{$b}} <=> scalar keys %{$benchmarks{$a}}} keys %benchmarks){
    # print STDERR "check benchmark $b: ";
    # print STDERR scalar keys %{$benchmarks{$b}};
    # print STDERR " models available\n";
    $selected_benchmarks{$b}++;
    foreach my $m (keys %models){
	unless (exists $benchmarks{$b}{$m}){
	    delete $models{$m};
	}
    }
    my $nr_selected_benchmarks = scalar keys %selected_benchmarks;
    my $nr_selected_models = scalar keys %models;
    my $key = join(',',keys %selected_benchmarks);

    $selection_score{$key} = ($nr_selected_benchmarks/$nr_benchmarks) * ($nr_selected_models/$nr_models);
    foreach my $m (keys %models){
	$selected_models{$key}{$m}++;
    }
}

unless (keys %selection_score){
    die "no benchmark selected - strange!\n";
}

my ($best_set) = sort {$selection_score{$b} <=> $selection_score{$a}} keys %selection_score;



%selected_models = %{$selected_models{$best_set}};
%selected_benchmarks = ();

foreach my $b (split(/,/,$best_set)){
    $selected_benchmarks{$b}++;
}



my %avg = ();
my %count = ();
my $nr_models = scalar keys %models;
my $nr_benchmarks = scalar keys %benchmarks;

foreach my $m (keys %scores){
    next unless (exists $selected_models{$m});
    foreach my $b (keys %{$scores{$m}}){
	next unless (exists $selected_benchmarks{$b});
	$avg{$m}+=$scores{$m}{$b};
	$count{$m}++;
    }
}

foreach my $m (keys %avg){
    $avg{$m} /= $count{$m};
}

# my $testsets = join(',',sort keys %selected_benchmarks);
print join(' ',sort keys %selected_benchmarks)."\n";
foreach my $m (sort {$avg{$b} <=> $avg{$a}} keys %avg){
    # print join("\t",($testsets,$avg{$m},$m));
    print join("\t",($avg{$m},$m));
}
