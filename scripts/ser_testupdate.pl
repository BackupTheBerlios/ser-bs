#!/usr/bin/perl
BEGIN {
	push(@INC,"/usr/local/lib/bs/ser_rrd/scripts");
}	
use strict;
use SerUpdate;
my $check;
#Getting needed values
my $host="195.37.78.202";
my $mysql_database="dbi:mysql:dbname=ser";
my $mysql_user="root";
my $mysql_passwd="oks";
#Create a list consiting of all package number 
my @PNo;
push(@PNo,200);
push(@PNo,202);
push(@PNo,"2xx");
push(@PNo,300);
push(@PNo,301);
push(@PNo,302);
push(@PNo,"3xx");
push(@PNo,400);
push(@PNo,401);
push(@PNo,403);
push(@PNo,404);
push(@PNo,407);
push(@PNo,408);
push(@PNo,483);
push(@PNo,"4xx");
push(@PNo,500);
push(@PNo,"5xx");
push(@PNo,"6xx");
push(@PNo,"xxx");
push(@PNo,"failure");

foreach (@PNo){
	SerUpdate::packet($_ );
}
sleep 0.5;
SerUpdate::user($mysql_database,$mysql_user,$mysql_passwd);
sleep 0.5;
SerUpdate::latency($host);
sleep 0.5;
SerUpdate::missedcalls($mysql_database,$mysql_user,$mysql_passwd);
sleep 0.5;
SerUpdate::pendingcalls($mysql_database,$mysql_user,$mysql_passwd);
sleep 0.5;
SerUpdate::totalcalltime($mysql_database,$mysql_user,$mysql_passwd);
sleep 0.5;
SerUpdate::totalcalls($mysql_database,$mysql_user,$mysql_passwd);
sleep 0.5;
#Dies ist der Aufruf, doch leider scheint etwas noch nicht zu gehen -> akayed
exec("/usr/local/lib/bs/ser_rrd/scripts/ser_testupdate.pl");


