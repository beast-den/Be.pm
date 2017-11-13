##################################################################
# $Id: DNS.pm,v 1.2 2017-07-24 03:22:15+03 beast Exp beast $
##################################################################
#
#                     DNS related subroutines
#                     -----------------------
#
#-----------------------------------------------------------------
# Changelog:
# ---------
# v.1.2
# See 'Be.pm' changelog about 'strict', 'arnings', 'autodie' etc.
#-----------------------------------------------------------------
#
# v.1.1
# Initial public release.
##################################################################
package Be::DNS;

$VERSION = '1.2';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	dns_get_serial
	dns_make_serial
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use POSIX qw/strftime/;
use constant::boolean;
##################################################################

##################################################################
# dns_get_serial($zone_file)
#
# Takes zone filename and returns current zone serial number.
##################################################################
sub dns_get_serial ($) {
	my $zone_file = shift;

	-s $zone_file or return undef;

	my $old_serial;

	open(my $fh, "<", $zone_file);
	while(<$fh>) {
		next unless (m/(\d{10})\s+\;\s+serial$/i);
		$old_serial = $1;
		last if $old_serial;
	}
	close($fh);

	return $old_serial if $old_serial;
	return FALSE;
}

##################################################################
# dns_make_serial([$old_serial])
#
# Takes an old zone serial number and returns a new one.
##################################################################
sub dns_make_serial (;$) {
	my $old_serial = shift || "00000000";

	my $today = strftime("%Y%m%d", localtime);
	
	my $olddate = substr($old_serial, 0, 8);
	my $count = (($olddate == $today) ? substr($old_serial, 8, 2) + 1 : 1);

	return sprintf("%8d%02d", $today, $count);
}

##################################################################

1;

##################################################################
#
##EOF##
