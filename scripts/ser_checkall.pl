#!/usr/bin/perl -w

use strict;
use DBI;
sub pending{
	#Basicinformation to connect to database
	my @res;
	my @ergebnis;
	my $erg1;
	my $erg2;
	my $sql;
	my $arg;
	my $dbh= DBI->connect('dbi:mysql:dbname=ser', 'root', 'oks')
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
	return  $res[0]-$res[1];
}

sub missed{
	#Basicinformation to connect to database
	my $ergebnis;
	my $sql;
	my $arg;
	my $time=$_[0];
	my $dbh= DBI->connect('dbi:mysql:dbname=ser', 'root', 'oks')
          or print "Database could not be opened";
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM missed_calls WHERE (sip_method='INVITE') AND sip_status='404  Not found' AND unix_timestamp(time)>unix_timestamp(NOW())-$time};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	$ergebnis=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	return  $ergebnis;
}

sub updateindex{
	my $r = open(INDEX,"/usr/local/lib/bs/www/index1.html");
	if(not defined($r)) {
		die "Fehler beim Öffnen der Datei: $!\n";
	}
	my @file = <INDEX>; 
	my $length=@file;
	my $index=0;
	my $html;
	my @newfile;
	if ($_[0] =~ 'green'){
		$html="<IMG ALIGN='middle' SRC='skins/techie/green_framed.gif' ALT='green' BORDER=0>";
	}
	elsif ($_[0] =~ 'yellow'){
		$html="<IMG ALIGN='middle' SRC='skins/techie/yellow_framed.gif' ALT='yellow' BORDER=0>";
	}
	elsif ($_[0] =~ 'red'){
		$html="<IMG ALIGN='middle' SRC='skins/techie/red_framed.gif' ALT='red' BORDER=0>";
	}
	while ($index<$length-1){
		if ($file[$index+1] =~ /<A HREF='ser_top.html' class=cf>/){
			push(@newfile,$html);
		}
		else {
			push(@newfile,$file[$index]);
			}
		$index++;
	}
	my $w = open(TOFILE,">/usr/local/lib/bs/www/index1.html");
	if(not defined($w)) {
	    die "Fehler beim Öffnen der Datei: $!\n";
	}
	foreach (@newfile){
		print TOFILE $_;
		}
	close(TOFILE);
}

my $r = open(FILE,"/usr/local/lib/bs/www/ser_top.html");
if(not defined($r)) {
    die "Fehler beim Öffnen der Datei: $!\n";
}
my @file = <FILE>; 
close(FILE);
while(1){
	my $pending = pending();
	#Time-lag of 2 hour because of mysql database
	my $missed = missed(7230);
	my $html1;
	my $html2;
	if ($pending >1 && $pending<=2){
		$html1= "<TD ALIGN='center'><A HREF='ser/ser_misc.html'><IMG ALIGN='middle' SRC='skins/default/yellow.gif' ALT='red' BORDER=0></A></TD>\n";
		#updateindex("yellow");
		}
	elsif ($pending>2){
		$html1= "<TD ALIGN='center'><A HREF='ser/ser_misc.html'><IMG ALIGN='middle' SRC='skins/default/red.gif' ALT='red' BORDER=0></A></TD>\n";
		#updateindex("red");
		}
	else{
	$html1="<TD ALIGN='center'><A HREF='ser/ser_misc.html'><IMG ALIGN='middle' SRC='skins/default/green.gif' ALT='green' BORDER=0></A></TD>\n";	
	#updateindex("green");
	}	
	if ($missed >1 && $missed<=2){
		$html2= "<TD ALIGN='center'><A HREF='../cgi/sercallmissed.cgi?hour=1&ZOOM=100'><IMG ALIGN='middle' SRC='skins/default/yellow.gif' ALT='red' BORDER=0></A></TD>\n";
		}
	elsif ($missed >2){
		$html2= "<TD ALIGN='center'><A HREF='../cgi/sercallmissed.cgi?hour=1&ZOOM=100'><IMG ALIGN='middle' SRC='skins/default/red.gif' ALT='red' BORDER=0></A></TD>\n";
		}
	else{
	$html2="<TD ALIGN='center'><A HREF='../cgi/sercallmissed.cgi?hour=1&ZOOM=100'><IMG ALIGN='middle' SRC='skins/default/green.gif' ALT='green' BORDER=0></A></TD>\n";	
	}
	my $length=@file;
	my $index=0;
	my @newfile;
	while ($index<$length){
		push(@newfile,$file[$index]);
		if ($file[$index] =~ /<!--missed-->/){
			$index++;
			push(@newfile,$html2);
		}
		if ($file[$index] =~ /<!--misc-->/){
			$index++;
			push(@newfile,$html1);
			}
		$index++;
	}
	my $w = open(TOFILE,">/usr/local/lib/bs/www/ser_top.html");
	if(not defined($w)) {
	    die "Fehler beim Öffnen der Datei: $!\n";
	}
	foreach (@newfile){
		print TOFILE $_;
		}
	close(TOFILE);
	sleep 5;
}
	