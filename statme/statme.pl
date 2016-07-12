use strict;
use warnings;

#Show Usage
if (!@ARGV) {
    print "\nUsage:\n\n    statme.pl <filename>\n\n";
    exit;
}

my %cond;
my %unit;
for my $file (@ARGV) {
    #Open input file for READ
    open(FILE_IN, '<', $file) or die "Error: Cannot open $file!\n";

    #Skip first line
    <FILE_IN>;

    #Read the file
    while (<FILE_IN>) {
        chomp;
        my ($lot, $wafer, $reticle, $die_x, $die_y, $temp, $tname, $result, $value, $cond1)= split ',',$_;
        $unit{$temp}{$wafer}{"$die_x$die_y"}++;
        $cond{$temp}{$wafer}{$cond1}{"SUM"}+=$value;
        if ((!defined $cond{$temp}{$wafer}{$cond1}{"MIN"}) || $value < $cond{$temp}{$wafer}{$cond1}{"MIN"}) {
            $cond{$temp}{$wafer}{$cond1}{"MIN"} = $value;
        }
        if ((!defined $cond{$temp}{$wafer}{$cond1}{"MAX"}) || $value > $cond{$temp}{$wafer}{$cond1}{"MAX"}) {
            $cond{$temp}{$wafer}{$cond1}{"MAX"} = $value;
        }
    }
    #CLose file
    close(FILE_IN);

    #Write ouput file
    for my $temp (keys  %cond) {
        for my $wafer (keys %{ $cond{ $temp } }) {

            #Generate and open output file for WRITE
            my $output = "stat_prog_nvcm_w".$wafer."_t".$temp.".csv";
            open(FILE_OUT, '>', $output) or die "Error: Cannot open $output!\n";

            #Write Header
            print FILE_OUT "WAFER,TEMP,PROG,N,MIN,MAX,SUM,AVE\n";

            #Write data
            for my $con (keys %{ $cond{$temp}{$wafer} }) {
                printf FILE_OUT "%s,%.2f,%d,%d,%e,%e,%e,%e\n", $wafer,$temp,$con,~~keys %{ $unit{$temp}{$wafer} },$cond{$temp}{$wafer}{$con}{MIN},$cond{$temp}{$wafer}{$con}{MAX},$cond{$temp}{$wafer}{$con}{SUM},$cond{$temp}{$wafer}{$con}{SUM}/~~keys %{ $unit{$temp}{$wafer} };
            }
            #CLose file
            close(FILE_OUT);
        }
    }
    
}

