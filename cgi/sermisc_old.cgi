#!/usr/bin/perl -w

use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);

#Deklaration of needed variables
my @INo;
my $no = param("No");
my $time = param("hour")*3600;
my $zoom = param("ZOOM");
my $name;

#Check if there is a information choice else display all information being available
if ($no == 0){
	push(@INo, "online_user");
	push(@INo, "calls_pending");
	push(@INo, "server_latency");
	}
elsif ($no == 1) {
	push(@INo, "online_user");
	}
elsif ($no == 2) {
	push(@INo, "calls_pending");
	}
elsif ($no == 3) {
	push(@INo, "server_latency");
	}
#Create the desired graphs
foreach (@INo){
	$name=$_."_".$time."_Z".$zoom;
	qx(/usr/bin/perl ../ser_rrd/scripts/ser_graph.pl $_ $name $time $zoom);
	}

#Print the html page
print "Content-type: text/html\n\n";
print "<!DOCTYPE HTML PUBLIC '//W3C//DTD HTML 4.01//EN'> \n";
print "<html><head><title>Graph</title>";
print "<META HTTP-EQUIV='REFRESH' CONTENT='5'>";
print "</head>\n<body>\n";
print "<center>";
print "<FORM action='/cgi/sermisc.cgi' method=get>\n";
print "<h1>Analysis of misc SER-Informations</h1>\n";
print "Show\n";
print "<select Name='No'>";
print "<option value='0'>all</option>\n";
print "<option value='1'>Online users</option>\n";
print "<option value='2'>Pending Calls</option>\n";
print "<option value='3'>Server Latency</option>\n";
print "</select>\n";
print " Information\n";
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
print "at zoom factor\n";
print "<select name=ZOOM>\n";
print "<option value='50'>50%</option>\n";
print "<option value='75'>75%</option>\n";
print "<option value='100' SELECTED>100%</option>\n";
print "<option value='125'>125%</option>\n";
print "<option value='150'>150%</option>\n";
print "<option value='175'>175%</option>\n";
print "<option value='200'>200%</option>\n";
print "</select>\n";
print "<input type=submit value='Update'>\n";
print "</FORM>\n";

#Displaying every graph being created
foreach (@INo){
	$name=$_."_".$time."_Z".$zoom;
	print "<br>\n";
	print "<p><img src='/bs/graphs/$name.png' ></p> \n";
}
print "<br><p><a href='/bs/top.html'>back to main page</a></p>";
print "</center>";
print "</body> \n</html> \n"; 
