#!/usr/bin/perl -w
use strict;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
sub db_get{
	#Basicinformation to connect to database
	my $ergebnis;
	my $sql;
	my $arg;
	my $time=$_[0];
	#Connection to database
	my $dbh= DBI->connect('dbi:mysql:dbname=ser', 'root', 'oks')
          or print "Database could not be opened";
	#Preparing the sql-query and executing it
	$sql = qq{SELECT COUNT(DISTINCT sip_callid) FROM acc WHERE sip_method='ACK' AND unix_timestamp(timestamp)>unix_timestamp(NOW())-$time};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	#Getting the result of query
	$ergebnis=$sth->fetchrow_array;
	$sth->finish();
	$dbh->disconnect();
	return  $ergebnis;
}
#Parameters being delivered by website-selection
my $time = param("hour")*3600;
my $min = param("hour")*60;
my $zoom = param("ZOOM");
my $result = db_get($time);
#Name of graph to be created and then executing the script that creates the graph
my $name="calls_totalamount"."_".$time."_Z".$zoom;
qx(/usr/bin/perl ../ser_rrd/scripts/ser_graph.pl calls_totalamount $name $time $zoom);
#Begin of print out for website
print "Content-type: text/html\n\n";
print "<!DOCTYPE HTML PUBLIC '//W3C//DTD HTML 4.01//EN'> \n";
print "<html><head><title>Graph</title>";
print "<META HTTP-EQUIV='REFRESH' CONTENT='10'>";
print "</head>\n<body>\n";
print "<center>";
print "<FORM action='/cgi/sercallamount.cgi' method=get>\n";
print "<h1>Analysis of calls</h1>\n";
print "<br>\n";
print "Zoom factor\n";
print "<select name=ZOOM>\n";
print "<option value='50'>50%</option>\n";
print "<option value='75'>75%</option>\n";
print "<option value='100' SELECTED>100%</option>\n";
print "<option value='125'>125%</option>\n";
print "<option value='150'>150%</option>\n";
print "<option value='175'>175%</option>\n";
print "<option value='200'>200%</option>\n";
print "</select>\n";
print "<p><img src='/bs/graphs/$name.png' ></p> \n";
print "Show\n";
print "<select name='hour'>\n";
print "<option value='0.25' >15 min.</option>\n";
print "<option value='0.5' >30 min.</option>\n";
print "<option value='1' SELECTED>1 hour</option>\n";
print "<option value='3'>3 hours</option>\n";
print "<option value='6' >6 hours</option>\n";
print "<option value='12'>12 hours</option>\n";
print "<option value='24'>1 day</option>\n";
print "<option value='48'>2 days</option>\n";
print "<option value='168'>1 week</option>\n";
print "<option value='336'>2 weeks</option>\n";
print "<option value='720'>1 month</option>\n";
print "</select>\n";
print "<input type=submit value='Update'>\n";
print "</FORM>\n";
print "Calls since last $min minutes: $result \n";
print "<br><p><a href='/bs/top.html'>back to main page</a></p>";
print "</center>";
print "</body> \n</html> \n"; 