#!/usr/bin/perl
#Definition of package
package SerUpdate;	
#Needed packages
use strict;
use DBI;
#Procedures being exported 
sub packet{
#This subroutine searches an package within an arry and returns the amount of the package
        open (INPUT, "serctl fifo sl_stats|");
        my @input=<INPUT>;
        close(INPUT);
        my $suchen = $_[0]; 
        foreach (@input){
        if ($_=~/$suchen: ([0-9]+)/) {
                system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/$_[0].rrd N:$1");
                }
        }
}

sub user{
	my $user;
	my $sql;
	my $arg;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT username,domain) FROM location};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$user=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/online_user.rrd N:$user");
}

sub user_nat{
	my $user_nat;
	my $sql;
	my $arg;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT username,domain) FROM location WHERE flags>0};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$user_nat=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/online_user_nat.rrd N:$user_nat");
}

sub latency{
	my $rw = open(FILE,"/usr/local/lib/bs/ser_rrd/log/serlog_5060");
	if(not defined($rw)) {
	    die "Error opening file: $!\n";
	}
	my $host=$_[0];
	my $client;
	my $time1=0;
	my $time2=0;
	my $latency=0;
	my $temp;
	my $count=0;
	my @file = <FILE>; 
	close(FILE);
	my $index =1;
	my $length=@file;
	while ($index<$length-1){
		if ($file[$index] =~ /(.*) (.*):(.*) (.*) -> $host:5060/){
			$client = $4;
			$time1 = $3;
			}
		elsif ($file[$index] =~ /(.*) (.*):(.*) $host:5060 -> $client/){
			$time2 = $3;
			$temp = $time2-$time1;
			$count++;
			if ($temp<0){
				$temp= $temp+60;
				}
			$latency = $latency+$temp;
			$client=0;
			}
		$index++;
		while (($file[$index] =~ /\S/) && ($index<$length-1)) {
			$index++;
			} 
		$index++;
	}
	if ($count<1){
		$latency = 0;
	}
	else{
	$latency = $latency/$count*1000;
	}
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/server_latency.rrd N:$latency");

}

sub missedcalls{
	#Basicinformation to connect to database
	my $missed;
	my $sql;
	my $arg;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM missed_calls WHERE (sip_method='INVITE')};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$missed=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/calls_totalmissed.rrd N:$missed");
}

sub pendingcalls{
	#Basicinformation to connect to database
	my @res;
	my $erg1;
	my $erg2;
	my $sql;
	my $arg;
	my $pendingcalls;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM `acc` WHERE sip_method='INVITE' OR sip_method='CANCEL' OR sip_method='ACK'};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$erg1=$sth->fetchrow_array;
	push(@res, $erg1);
	$sth->finish();
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM `acc` WHERE sip_method='CANCEL' OR sip_method='ACK'};
	$sth = $dbh->prepare( $sql );
	$sth->execute();
	$erg2=$sth->fetchrow_array;
	push(@res, $erg2);	
	$sth->finish();
	$dbh->disconnect();
	$pendingcalls = $res[0]-$res[1];
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/calls_pending.rrd N:$pendingcalls");
}

sub totalcalltime{
	#Basicinformation to connect to database
	my @result;
	my @ergebnis;
	my $sql;
	my $arg;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT sip_callid, unix_timestamp(timestamp) FROM acc WHERE (sip_method='BYE' OR sip_method='ACK') ORDER BY sip_callid};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	while(@ergebnis=$sth->fetchrow_array)
		{
		push(@result,@ergebnis);
		}
	$sth->finish();
	$dbh->disconnect();	

	my $length = @result;
	my $calltime=0;
	if ($length == 0){
		}
	else{	
		my $index2=0;
		my $index1=0;
		my $time1=0;
		my $time2=0;
		do{
			my $callid = $result[$index1];
			$time1 = $result[$index1+1];
			$index2=$index1+2;
			while (($callid =~ $result[$index2])){
				$index2=$index2+2;
				if ($index2>=($length-1)) {last;}
				}
			$time2 = $result[$index2-1];
			$index1=$index2;
			$calltime = $calltime + ($time2-$time1);
		} while ($index1<($length-2))
	}
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/calls_totaltime.rrd N:$calltime");
}

sub totalcalls{
	#Basicinformation to connect to database
	my $calls;
	my $sql;
	my $arg;
	my $dbh= DBI->connect($_[0], $_[1], $_[2])
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM acc WHERE sip_method='ACK'};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$calls=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	system("rrdtool update /usr/local/lib/bs/ser_rrd/databases/calls_totalamount.rrd N:$calls");
}
#Needed to return a true-value
1;
