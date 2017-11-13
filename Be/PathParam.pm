##################################################################
# $Id: PathParam.pm,v 1.1 2017-07-24 03:39:33+03 beast Exp beast $
##################################################################
#
#               CGI-PathParam related subroutines
#               ---------------------------------
#
#-----------------------------------------------------------------
# Changelog:
# ----------
#
# v.1.1
# Initial public release.
##################################################################
package Be::PathParam;

$VERSION = '1.1';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	get_path_params
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use CGI::PathParam;
use constant::boolean;
##################################################################

##################################################################
# get_path_params($cgi)
# Takes CGI.pm object and returns PATH Params
##################################################################
sub get_path_params ($) {
	my $q = shift;

	return unless defined wantarray;

	my @a = $q->path_param;

	return FALSE unless @a;
	return @a if wantarray;
	
	my %ret;
	my $last;
	for(my $i = 0; $i <= $#a; $i++) {
		if( $i % 2 ) {
			$ret{$last} = $a[$i];
		}
		else {
			$last = $a[$i];
			$ret{$last} = 1 unless $a[$i + 1];
		}
	}

	return \%ret if %ret;
	return FALSE;
}

##################################################################

1;

##################################################################
#
##EOF##
