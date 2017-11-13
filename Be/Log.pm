##################################################################
# $Id: Log.pm,v 1.1 2017-07-24 03:34:00+03 beast Exp beast $
##################################################################
#
#                  Logging related subroutines
#                  ---------------------------
#
# ----------------------------------------------------------------
# Chanelog:
# ---------
#
# v.1.1
# Initial public release.
##################################################################
package Be::Log;

$VERSION = '1.1';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	file_log
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use Log::Handler;
use constant::boolean;
#
##################################################################

sub file_log ($;$$) {
	my $file = shift;
	my $maxl = shift || 7;
	my $minl = shift || 0;

	my $log = Log::Handler->new();

	$log->add(
		file => {
			filename => $file,
			maxlevel => $maxl,
			minlevel => $minl
		}
	);

	return $log if $log;
	return FALSE;
}

##################################################################

1;

##################################################################
#
##EOF##
