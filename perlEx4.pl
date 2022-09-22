# Example 03: write scipt to store all
#data in the file textEx2.txt to a hash. 
# Print this hash's content to screen.
#####################################################
### Define lib ###
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END); 
### End lib ###
my $help = '';

&GetOptions (
              "help|h" => \$help
);
my $key = 'clkslew|cntrl|input_voltage|output_voltage|cols|corner|inputslew|load|muxoption|rows|slewrate|strength';
my $input =shift @ARGV;
my $output=shift @ARGV;
if ($help or not defined $output) {
  PrintHelp();
}
if ($help or not defined $input) {
  PrintHelp();
}
my %data = ();
my @ele;
my @header;
my $l="";
readdata($input, \%data);
writedata($output,\%data);
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
    for (my $i=0;$i<scalar @{$vals->[0]};++$i) 
    {
      $ptr->{$keys->[0]->[$num]}->{$vals->[1]->[$i]} = $vals->[0]->[$i];
    }
  }
  else 
  {
    getCase($keys, $vals, \%{$ptr->{$keys->[0]->[$num]}}, $num+1);
  }
}
sub writedata{
    my($output,$ptr)=@_;
    open (OUT,'>',"$output") or die "$output $!";
    say OUT "\#Rev_1.0\n\.corner";
    my $n=0;
    foreach my $corner(keys %{$ptr->{corner}}) 
    {
      my @vals= @{$ptr->{corner}->{$corner}};
      my $line=$corner."\t".join("\t",@vals);
      $n++;
      say OUT $line;
      say OUT ".endcorner" if $n==6;
     }
   foreach my $title(keys %data){
    unless($title=~/corner/){ 
        my $numkey=0;
        $l="";
        @header=@{$ptr->{$title}->{header}};
        my $lineheader =join ("\t",@header);
        foreach my $head(@header)
        {
          $numkey=$numkey+1 if($head =~/^($key)$/);
        }
        say OUT "\.title\n$title\n\.header\n$lineheader\.data";
        getLine(\%{$ptr->{$title}->{data}},$numkey,1);
        my @Rline=split("\n",$l);
        foreach my $line(@Rline)
        {
          say OUT $line;
        }
        say OUT "\.enddata";
      }
   }
  close OUT;
}
sub getLine{
  my($ptr,$numkey,$num)=@_;
  foreach my $key(sort keys %{$ptr})
  { 
      $ele[$num]=$key;
      if($num==$numkey)
      {
        $l.=join("\t",@ele[1..$numkey])."\t$ptr->{$key}->{blpchdly}\n"if($numkey==2) ; 
        $l.=join("\t",@ele[1..$numkey])."\t$ptr->{$key}->{output_current}\n"if($numkey==3 or ($numkey==4 and $#header<10)) ; 
        if($#header>10)
        {
          $l.=join("\t",@ele[1..4]);
          my $count=4;
          for my $k(keys %{$ptr->{$key}}){
            $l.="\t$ptr->{$key}->{$header[$count++]}";
          }
          $l.="\n";
        } 
      } 
      else
       {
         getLine(\%{$ptr->{$key}},$numkey,$num+1);
       }
    }
}

    ###PrintHelp()###
sub PrintHelp {
    print "Usage: perl $0 <path input file> <path output file>\n";
    print <<END;
    read          <input>
    write         <input>
    store         <input>
    modifly data  <input>
END
    exit;
}