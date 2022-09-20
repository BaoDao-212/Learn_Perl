#Example 1: Introduce to Perl
use strict;
use warnings;
use Getopt::Long;
my $help="";
&GetOptions(
    "h|help"    =>\$help);
    if($help){
        PrintHelp();
    }
    ###PrintHelp()###
    sub PrintHelp{
        print "Usage:prel $0\n";
        exit;
    }
print "Name          :Nguyen Van A\n";
print "Date of birth :01/01/1990\n";
print "Place of birth: Hai Ba Trung - Ha Noi\n";
print "Address       : 124 Minh Khai - Hai Ba Trung - Ha Noi\n";
