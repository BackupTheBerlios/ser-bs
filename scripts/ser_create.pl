#!/usr/bin/perl
local $time=time();
system("rrdtool create ../databases/@ARGV[0].rrd --start now --step 1 DS:amount:GAUGE:15:0:U RRA:LAST:0.5:1:2592000");
