#!/usr/bin/perl -w


use Net::LDAP;


$fudge = 116444736390271392;
$sevenDays = 6048000000000;

$ldap = Net::LDAP->new( '192.168.204.25' ) or die "$@";
$mesg = $ldap->bind( dn => 'cn=veg\, proc,ou=Users,OU=VEG-Oceanic Vega,OU=Vessels,OU=Marine,DC=int,DC=foo,DC=com' ,password => 'Passw0rd2');

$mesg->code && die $mesg->error;

$mesg = $ldap->search( base => 'cn=veg\, proc,ou=Users,OU=VEG-Oceanic Vega,OU=Vessels,OU=Marine,DC=int,DC=foo,DC=com',
#attrs => 'maxPwdAge',
scope => 'base',
filter => 'cn=veg\, proc'
);

$mesg->code && die $mesg->error;
foreach $entry ($mesg->entries) { $entry->dump; }
$ldap->unbind();

exit 0;


$entry = $mesg->entry(0);

@maxPwdAgeArray = $entry->get_value( 'maxPwdAge' );
$maxPwdAge = $maxPwdAgeArray[0];
print $maxPwdAge;

$now = time();
$now = ($now * 10000000) + $fudge;

$expNow = $now + $maxPwdAge;
$expInSevenDays = $expNow + $sevenDays;



$ldap->unbind();

exit 0;

