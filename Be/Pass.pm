#
##################################################################
# $Id: Pass.pm,v 1.1 2015-03-01 00:55:18+03 beast Exp beast $
##################################################################
#
# Passwords related subroutines
#
##################################################################
#
package Be::Pass;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	read_pass
);

#
##################################################################
#
use strict;
use warnings FATAL => 'all';
use Term::ReadKey;
#
##################################################################

##################################################################
# read_pass([$prompt])
#
# Shows password prompt and returns entered data.
##################################################################
sub read_pass {
	my $prompt = shift || "password";

	print $prompt, ": ";
	ReadMode('noecho');
	chomp(my $pass = ReadLine( 0 ));
	ReadMode('normal');
	print "\n";

	return $pass if length $pass;
	return 0;
}

##################################################################

1;

##################################################################
#
##EOF##
