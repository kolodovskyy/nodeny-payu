#!/usr/bin/perl
# by Yuriy Kolodovskyy aka Lexx
# lexx@ukrindex.com
# +380445924814
# last 20130419

use Digest::HMAC_MD5 qw(hmac_md5 hmac_md5_hex);
use Time::localtime;
use Time::Local;
use MIME::Base64;
use DBI;
use CGI;

require '/usr/local/nodeny/nodeny.cfg.pl';
require '/usr/local/nodeny/web/calls.pl';

$MERCHANT = "MERCHANT";
$SECRET_KEY = "SECRET_KEY";
$CATEGORY = 94;

$cgi=new CGI;
$SALEDATE=$cgi->param('SALEDATE');
$PAYMENTDATE=$cgi->param('PAYMENTDATE');
$COMPLETE_DATE=$cgi->param('COMPLETE_DATE');
$REFNO=$cgi->param('REFNO');
$REFNOEXT=$cgi->param('REFNOEXT');
$ORDERNO=$cgi->param('ORDERNO');
$ORDERSTATUS=$cgi->param('ORDERSTATUS');
$PAYMETHOD=$cgi->param('PAYMETHOD');
$PAYMETHOD_CODE=$cgi->param('PAYMETHOD_CODE');
$AMOUNT=$cgi->param('IPN_TOTALGENERAL');

# connect to database
$dbh=DBI->connect("DBI:mysql:database=$db_name;host=$db_server;mysql_connect_timeout=$mysql_connect_timeout;",$user,$pw,{PrintError=>1});
$dbh->do("SET NAMES UTF8");

sub ret
{
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=CORE::localtime(time);
  $date = sprintf "%4d%02d%02d%02d%02d%02d",$year+1900,$mday,$mon+1,$hour,$min,$sec;
  
  $IPN_PID = $cgi->param('IPN_PID[]');
  $IPN_PNAME = $cgi->param('IPN_PNAME[]');
  $IPN_DATE = $cgi->param('IPN_DATE');
  
  $hash =  hmac_md5_hex(
    length($IPN_PID) . $IPN_PID .
    length($IPN_PNAME) . $IPN_PNAME .
    length($IPN_DATE) . $IPN_DATE .
    length($date) . $date, $SECRET_KEY);
 
  print "Content-type: text/html\n\n";
  print "<EPAYMENT>$date|$hash</EPAYMENT>";
}

if ($REFNOEXT && $AMOUNT && 
    &sql_select_line($dbh, "SELECT id FROM users WHERE id='$REFNOEXT'") &&
    !&sql_select_line($dbh, "SELECT id FROM pays WHERE category='$CATEGORY' AND reason='$REFNO'")) {

  $dbh->do("INSERT INTO pays SET
    mid='$REFNOEXT',
    cash='$AMOUNT',
    time=UNIX_TIMESTAMP(NOW()),
    admin_id=0,
    admin_ip=0,
    office=0,
    bonus='y',
    reason='$REFNO',
    coment='PayU ($REFNO)',
    type=10,
    category=$CATEGORY");
    
  $dbh->do("UPDATE users SET state='on', balance=balance+$AMOUNT WHERE id='$REFNOEXT'");
  $dbh->do("UPDATE users SET state='on' WHERE mid='$REFNOEXT'");
}

&ret;
1;
