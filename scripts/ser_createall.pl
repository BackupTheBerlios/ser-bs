#!/usr/bin/perl

#RRD-databases needed to be created with a step of 10 sec
push(@databases,200);
push(@databases,202);
push(@databases,"2xx");
push(@databases,300);
push(@databases,301);
push(@databases,302);
push(@databases,"3xx");
push(@databases,400);
push(@databases,401);
push(@databases,403);
push(@databases,404);
push(@databases,407);
push(@databases,408);
push(@databases,483);
push(@databases,"4xx");
push(@databases,500);
push(@databases,"5xx");
push(@databases,"6xx");
push(@databases,"xxx");
push(@databases,"failure");
push(@databases,"online_user");
push(@databases,"online_user_nat");
push(@databases,"calls_totalamount");
push(@databases,"calls_totalmissed");
push(@databases,"calls_totaltime");

#High-Speed databases with a step of 1 sec
push(@hdatabases,"server_latency");
push(@hdatabases,"calls_pending");

local $time=time();
local $result=0;
foreach (@databases){
	system("rrdtool create /usr/local/lib/bs/ser_rrd/databases/$_.rrd --start now --step 10 DS:amount:GAUGE:60:0:U RRA:LAST:0.5:1:518400");
	$result++;
	}
foreach (@hdatabases){
	system("rrdtool create /usr/local/lib/bs/ser_rrd/databases/$_.rrd --start now --step 1 DS:amount:GAUGE:60:0:U RRA:LAST:0.5:1:2592000");
	$result++;
	}
print $result." of 26 Databases were created!\n";
