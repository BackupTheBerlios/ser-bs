#!/usr/bin/perl -w

use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);

#Deklaration of needed variables
my @PNo;
my $no = param("No");
my $time = param("hour")*3600;
my $zoom = param("ZOOM");
my $name;

#Check if there is a desired package to be monitored else monitor all available packages
if ($no == 1){
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
}
elsif ($no == 2){
	push(@PNo,200);
	push(@PNo,202);
	push(@PNo,"2xx");
}
elsif ($no == 3){
	push(@PNo,300);
	push(@PNo,301);
	push(@PNo,302);
	push(@PNo,"3xx");
}
elsif ($no == 4){
	push(@PNo,400);
	push(@PNo,401);
	push(@PNo,403);
	push(@PNo,404);
	push(@PNo,407);
	push(@PNo,408);
	push(@PNo,483);
	push(@PNo,"4xx");
}
elsif ($no == 5){
	push(@PNo,500);
	push(@PNo,"5xx");
}
elsif ($no == 6){
	push(@PNo,"6xx");
}
elsif ($no == 7){
	push(@PNo,"xxx");
	push(@PNo,"failure");
}
else {
	push(@PNo, $no);
	}

#Create the desired graphs
foreach (@PNo){
	$name=$_."_".$time."_Z".$zoom;
	qx(/usr/bin/perl ../ser_rrd/scripts/ser_graph.pl $_ $name $time $zoom);
	}

#Print the html page
print "Content-type: text/html\n\n";
print "<!DOCTYPE HTML PUBLIC '//W3C//DTD HTML 4.01//EN'> \n";
print "<html><head><title>Graph</title>";
print "<META HTTP-EQUIV='REFRESH' CONTENT='10'>";
print "</head>\n<body>\n";
print "<center>";
print "<FORM action='/cgi/serpackages.cgi' method=get>\n";
print "<h1>Analysis of SER-Packages</h1>\n";
print "Show\n";
print "<select Name='No'><option value='1'>all</option>\n";
print "<option>200</option>\n";
print "<option>202</option>\n";
print "<option>2xx</option>\n";
print "<option>300</option>\n";
print "<option>301</option>\n";
print "<option>302</option>\n";
print "<option>3xx</option>\n";
print "<option>400</option>\n";
print "<option>401</option>\n";
print "<option>403</option>\n";
print "<option>404</option>\n";
print "<option>407</option>\n";
print "<option>408</option>\n";
print "<option>483</option>\n";
print "<option>4xx</option>\n";
print "<option>500</option>\n";
print "<option>5xx</option>\n";
print "<option>6xx</option>\n";
print "<option>xxx</option>\n";
print "<option>failure</option>\n";
print "</select>\n";
print " Package\n";
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
foreach (@PNo){
	$name=$_."_".$time."_Z".$zoom;
	print "<br>\n";
	print "<p><img src='/bs/graphs/$name.png' ></p> \n";
}
print "<br><p><a href='/bs/top.html'>back to main page</a></p>";
print "</center>";
print "</body> \n</html> \n"; 
