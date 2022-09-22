# Example 03: write scipt to store all
#data in the file textEx2.txt to a hash. 
# Print this hash's content to screen.







#####################################################
### Define lib ###
use strict;
use Getopt::Long;
use Data::Dumper;
use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END); 
### End lib ###
my $help = '';

&GetOptions (
              "help|h" => \$help
);
my $key = 'clkslew|cntrl|cols|input_voltage|output_voltage|corner|inputslew|load|muxoption|rows|slewrate|strength';
my $input = $ARGV[0];
if ($help or not defined $input) {
  PrintHelp();
}
my %data = ();
readdata($input, \%data);
  # print Dumper \%data;
###SUB###
###SUB###
sub readdata{
    my ($input, $ptr) = @_;
  open IN ,"$input" or die "$input $!";
  my $title = '';
   my $corner;
  my $endcorner;
  while (<IN>) {
    chomp;
   if (/\.title/) {
      $title = <IN>;
      chomp $title;
    }
    elsif (/\.header/) {
      my $header = <IN>;
      chomp $header;
      $header=~ s/( +|\s+|\t+)/ /g;
      $header =~ s/( +|\s+|\t+)$//g;
      my @tmp = split / /, $header;
      push @{$ptr->{$title}->{header}}, @tmp;
    }
    elsif($title and !/\.data|\.enddata/  ){
      s/( +|\s+|\t+)$//g;
      s/( +|\s+|\t+)/ /g;
      my @line = split / /, $_;
      my @keys = ();
      my @vals = ();
       for (my $i=0;$i<scalar @line;++$i) {
        if ($ptr->{$title}->{header}->[$i] =~ /^($key)$/) {
          push @{$keys[0]}, $line[$i];
          push @{$keys[1]}, $ptr->{$title}->{header}->[$i];
        }
        else {
          push @{$vals[0]}, $line[$i];
          push @{$vals[1]}, $ptr->{$title}->{header}->[$i];
        }
      }
      # 
       getCase(\@keys, \@vals, \%{$ptr->{$title}->{data}}, 0);
      if (not defined $ptr->{$title}->{headerkeys}->[0]) {
        push @{$ptr->{$title}->{headerkeys}}, @{$keys[1]};
        push @{$ptr->{$title}->{headervals}}, @{$vals[1]};
      }
    }
     elsif (/\.enddata/) {
      $title = '';
    } 
     else {
    $corner=tell if ($_=~/^.corner/) ;
    $endcorner=tell if ($_ =~/^.endcorner/);
    }
    
  }
  my $kill;
  seek(IN,$corner,SEEK_SET);
    read IN,$kill,($endcorner-$corner-11);
    my @cornerline= split(/\n/,$kill);
    foreach my $line(@cornerline){
      chomp($line);
     $line=~s/( +|\s+|\t+)$//g;
      $line=~s/( +|\s+|\t+)/ /g;
      my @element=split(/ /,$line);
      $ptr->{corner}->{$element[0]}=[@element[1..3]];
    }
  close(IN);
}

sub getCase {
  my ($keys, $vals, $ptr, $num) = @_;
  if ($num == scalar @{$keys->[0]} - 1) {
    for (my $i=0;$i<scalar @{$vals->[0]};++$i) {
      $ptr->{$keys->[0]->[$num]}->{$vals->[1]->[$i]} = $vals->[0]->[$i];
    }
  }
  else {
    getCase($keys, $vals, \%{$ptr->{$keys->[0]->[$num]}}, $num+1);
  }
}

    ###PrintHelp()###
sub PrintHelp {
    print "Usage: perl $0 <path input file>\n";
    print <<END;
    read          <input>
    store         <input>
    modifly data  <input>
END
    exit;
}