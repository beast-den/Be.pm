#
##################################################################
# $Id: SNMP.pm,v 1.1 2015-03-01 01:02:14+03 beast Exp beast $
##################################################################
#
# SNMP related subroutines
#
##################################################################
#
package Be::SNMP;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	snmp_get_vendor
);

#
##################################################################
#
use strict;
use warnings FATAL => 'all';
use Net::SNMP;
use Carp qw/cluck/;
#
##################################################################

##################################################################
#
# snmp_get_vendor($cfg)
# Takes configuration data for a host and returns it's vendor
#
##################################################################
sub snmp_get_vendor {
	my $cfg = shift;

	return unless defined wantarray;

	my $oid = '.1.3.6.1.2.1.1.2.0';
	my ($ses, $err) = Net::SNMP->session(
		-hostname 	=> $cfg->{'host'},
		-community 	=> $cfg->{'community'},
		-version 	=> $cfg->{'version'} || 'snmpv2c',
	);

	cluck $err if $err;
	return undef unless $ses;

	my $res = $ses->get_request(-varbindlist => [ $oid ],);

	return 0 unless $res;

	my $vstr = substr($res->{$oid}, 13);

	$ses->close();

	return split(/\./, $vstr) if wantarray;

	$vstr =~ m/^(\d+)\./;

	return $1 if $1;
	return 0;
}

##################################################################

1;

##################################################################
#
##EOF##
