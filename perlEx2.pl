#Example 02: read to print to screen the lines from .data to .enddata
use warnings;#catch unsafe code
use strict;#restrict unsafe constructs
use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END); 
use Getopt::Long;
my $help = '';

&GetOptions (
              "help|h" => \$help
);
my $input = $ARGV[0];
if ($help or not defined $input) {
  PrintHelp();
}
#open file textEx2.txt to read
open (FH,'<',"$input") or die $!;
my %hash;
my $key;
# read file and save location /.data/, /.enddata/ into %hash
while(my $line=<FH>)
{   
    chomp($line);
    $key=tell if ($line=~/^.data/) ;
    $hash{$key}=tell if ($line =~/^.enddata/);
}
my $kill;
# read data to demand from .data to .enddata
foreach my $k( sort {$a <=> $b} keys %hash){
    seek(FH,$k,SEEK_SET);
    read FH,$kill,($hash{$k}-$k-9);
    print $kill;
    # print $key1." : ".$hash{$key1}."\n";
}
close(FH);#close file
sub PrintHelp {
    print "Usage: perl $0 <path input file>\n";
    print <<END;
    read          <input>
    store         <input>
    modifly data  <input>
END
    exit;
}
