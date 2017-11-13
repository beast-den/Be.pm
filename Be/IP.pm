##################################################################
# $Id: IP.pm,v 1.1 2017-07-24 03:27:39+03 beast Exp beast $
##################################################################
#
#                     IP related subroutines
#                     ----------------------
#
#-----------------------------------------------------------------
# Changelog:
# ----------
#
# v.1.1
# Initial public release.
##################################################################
package Be::IP;

$VERSION = '1.1';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	is_within
	ip2long
	long2ip
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use Net::Netmask;
use Socket;
use constant::boolean;
##################################################################

##################################################################
# is_within($block, @valid_blocks)
#
# Returns TRUE if $block is contained by any of @valid_blocks.
##################################################################
sub is_within ($@) {
	my $block = Net::Netmask->new(shift);
	my @valid_blocks = @_;

	for(@valid_blocks) {
		my $valid_block = Net::Netmask->new($_);
		return TRUE if $valid_block->contains($block);
	}

	return FALSE;
}

##################################################################
# ip2long($ip)
#
# Converts IP address to long number
##################################################################
sub ip2long ($) {
	return unpack("l*", pack("l*", unpack("N*", inet_aton(shift))));
}

##################################################################
# long2ip($int)
#
# Converts long number to IP address
##################################################################
sub long2ip ($) {
	return inet_ntoa(pack("N*", shift));
}

##################################################################

1;

##################################################################
#
##EOF##
