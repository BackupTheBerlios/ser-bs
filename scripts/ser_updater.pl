#!/usr/bin/perl
BEGIN {
	push(@INC,"/usr/local/lib/bs/ser_rrd/scripts");
}	
use strict;
use SerUpdate;
my $check;
#Getting needed values
print "\nFill in the server IP-Adress: ";
my $host=<STDIN>;
chop($host);
print "Fill in the mysql database to use: ";
my $mysql_database=<STDIN>;
chop ($mysql_database);
$mysql_database="dbi:mysql:dbname=".$mysql_database;
print "Fill in the user name of the specified mysql database: ";
my $mysql_user=<STDIN>;
chop($mysql_user);
print "Fill in the password for $mysql_user: ";
my $mysql_passwd=<STDIN>;
chop($mysql_passwd);
print "Are these information correct?\nHost: ".$host."\nDatabase: ".$mysql_database."\nUser: ".$mysql_user."\nPassword: ".$mysql_passwd."\nElse quit (Ctrl-C) and restart!";
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
while(1){
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
	}
