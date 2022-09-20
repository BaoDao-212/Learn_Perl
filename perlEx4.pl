# Example 03: write scipt to store all
#data in the file textEx2.txt to a hash. 
# Print this hash's content to screen.







#####################################################
### Define lib ###
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
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
readdata($input, \%data);
  # print Dumper \%data;
writedata($output,\%data);


###SUB###
sub readdata{
    my ($input, $ptr) = @_;
  open IN ,"$input" or die "$input $!";
  my $title = '';
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
sub writedata{
    my($output,$ptr)=@_;
    open (OUT,'>',"$output") or die "$output $!";
   foreach my $title(keys %data){
    say OUT ".title";
    say OUT $title;
    say OUT ".header";
    my @header=@{$ptr->{$title}->{header}};
    my $lineheader =join ("\t",@header);
    say OUT $lineheader;
    say OUT ".data";
     my $numheader= scalar @{$ptr->{$title}->{header}};
    if($numheader==3){
      foreach my $key1(keys %{$ptr->{$title}->{data}}){
        for my $key2(keys %{$ptr->{$title}->{data}->{$key1}})
        {
           for my $ele (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}}) 
          {
            my $line3 = "$key1\t$key2\t $ptr->{$title}->{data}->{$key1}->{$key2}->{$ele}" ;
          say OUT $line3;
          }
        }
      }
    }
    elsif($numheader==4){
      foreach my $key1(keys %{$ptr->{$title}->{data}}){
        
        for my $key2(keys %{$ptr->{$title}->{data}->{$key1}})
        {
           for my $key3 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}}) 
          { 
           for my $key4 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}}) 
           { 
            my $line4 = "$key1\t$key2\t$key3\t $ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}->{$key4}" ;
            say OUT $line4;
          }
          }
        }
    }
   }
    elsif($numheader==5){
      foreach my $key1(keys %{$ptr->{$title}->{data}}){
        
        for my $key2(keys %{$ptr->{$title}->{data}->{$key1}})
        {
           for my $key3 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}}) 
          { 
           for my $key4 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}}) 
           {  
            for my $key5 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}->{$key4}}) 
           { 
            my $line5 = "$key1\t$key2\t$key3\t$key4 $ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}->{$key4}->{$key5}" ;
            say OUT $line5;
          }
           }
          }
        }
    }
   }
    else{
       foreach my $key1(keys %{$ptr->{$title}->{data}}){
        
        for my $key2(keys %{$ptr->{$title}->{data}->{$key1}})
        {
           for my $key3 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}}) 
          { 
           for my $key4 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}}) 
           {  
            my $line5 = "$key1\t$key2\t$key3\t$key4" ;
            my $i=4;
            for my $key5 (keys %{$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}->{$key4}}) 
           { 
            $line5.="\t$ptr->{$title}->{data}->{$key1}->{$key2}->{$key3}->{$key4}->{$header[$i++]}"
          }
            say OUT $line5;
           }
          }
        }
    }
    }
    say OUT "\.enddata";
   }
    close OUT;
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