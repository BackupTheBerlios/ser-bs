#!/usr/bin/perl -w
my $time=time();
my $width=($ARGV[3]*4);
system("rrdtool graph -a PNG /usr/local/lib/bs/www/graphs/$ARGV[1].png --start $time-$ARGV[2] --end $time --width $width --height $ARGV[3] -v amount -t 'Amount of $ARGV[0]' DEF:$ARGV[0]=/usr/local/lib/bs/ser_rrd/databases/$ARGV[0].rrd:amount:LAST LINE2:$ARGV[0]#ff000");

