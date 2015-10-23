use strict;
use argola;

my $filen;
my $filefound;
my $snhour;
my $snmin;
my $snstfound;
my $cmd;

my @taskray;    # Contents of task file
my @rvtaskray;  # Contents of task file - in reverse order
my $outpot;     # Output content
my $crhour;     # Current hour in schecule
my $crmin;      # Current minute in schecule


$filefound = 0;
$snstfound = 0;

sub opto__f_do {
  $filen = &argola::getrg;
  $filefound = 10;
} &argola::setopt("-f",\&opto__f_do);

sub opto__snst_do {
  $snhour = &argola::getrg;
  $snmin = &argola::getrg;
  $snstfound = 10;
} &argola::setopt("-snst",\&opto__snst_do);

&argola::runopts();



if ( $filefound < 5 ) { die "\nshabbat-prep-sched: FATAL ERROR:\n    No tasklist file specified: (-f filename)\n\n"; }
if ( $snstfound < 5 ) { die "\nshabbat-prep-sched: FATAL ERROR:\n    Candle lighting time not provided: (-snst hr min)\n\n"; }

{
  my $lc_a;
  my @lc_b;
  my $lc_c;
  
  $cmd = "cat";
  &argola::wraprg_lst($cmd,$filen);
  $lc_a = `$cmd`;
  @lc_b = split(/\n/,$lc_a);
  @taskray = ();
  foreach $lc_c (@lc_b)
  {
    if ( $lc_c ne "" ) { @taskray = (@taskray, $lc_c); }
  }
}

@rvtaskray = reverse @taskray;
$crhour = $snhour;
$crmin = $snmin;
{
  my $lc_a;
  foreach $lc_a (@rvtaskray)
  {
    &goforound($lc_a);
  }
}
print $outpot;
sub chopfld {
  my $lc_a;
  my $lc_b;
  ($lc_a,$lc_b) = split(/:/,$_[0],2);
  $_[0] = $lc_b;
  return $lc_a;
}
sub goforound {
  my $lc_src;
  my $lc_act;
  
  $lc_src = $_[0];
  &chopfld($lc_src);
  $lc_act = &chopfld($lc_src);
  if ( $lc_act eq "" ) { return; }
  
  if ( $lc_act eq "min" ) { &subtra_min($lc_src); return; }
  
  die("\nshabbat-prep-sched: Unknown line-type: " . $lc_act . ":\n  " . $_[0] . "\n\n");
}

sub subtra_min {
  my $lc_src;
  my $lc_togo;
  
  $lc_src = $_[0];
  $lc_togo = &chopfld($lc_src);
  if ( $lc_togo < ( $crmin + 0.5 ) )
  {
    $crmin = int(($crmin - $lc_togo) + 0.2);
    $lc_togo = 0;
  }
  if ( $lc_togo > ( $crmin + 0.5 ) )
  {
    $lc_togo = int(($lc_togo - $crmin) + 0.2);
    $crmin = 0;
  }
  while ( $lc_togo > 59.5 )
  {
    $crhour = int($crhour - 0.8);
    if ( $crhour < 0.5 ) { $crhour = 12; }
    $lc_togo = int($lc_togo - 59.8);
  }
  if ( $lc_togo > 0.5 )
  {
    $crhour = int($crhour - 0.8);
    if ( $crhour < 0.5 ) { $crhour = 12; }
    $crmin = int((60.2 + $crmin) - $lc_togo);
    $lc_togo = 0;
  }
  &commendo($lc_src);
}

sub commendo {
  my $lc_line;
  $lc_line = "";
  if ( $crhour < 9.5 ) { $lc_line .= " "; }
  $lc_line .= $crhour . ":";
  if ( $crmin < 9.5 ) { $lc_line .= "0"; }
  $lc_line .= $crmin . ": " . $_[0];
  
  $outpot = $lc_line . "\n" . $outpot;
}





