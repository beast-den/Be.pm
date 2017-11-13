##################################################################
# $Id: read_dir.pm,v 1.1 2017-07-24 03:50:34+03 beast Exp beast $
##################################################################
#
#                Provides read_dir() subroutine.
#                -------------------------------
#
#-----------------------------------------------------------------
# Changelog:
# ----------
#
# v.1.1
# Initial public release.
##################################################################
package Be::read_dir;

$VERSION = '1.1';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	read_dir
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use Path::Iterator::Rule;
use File::Spec::Functions;
##################################################################

##################################################################
# read_dir([$dir, $options])
#
# Reads $dir and returns result according to $options
##################################################################
sub read_dir (;$$) {
	my $dir = shift || '.';
	my $opt = shift || {};
	$dir =~ s/\/$//;

	return undef unless -d $dir;

	my @ret;

	my $rule = Path::Iterator::Rule->new;
	if(exists $opt->{'name'}) {
		$rule->name($opt->{'name'});
	}

	my $it = $rule->iter($dir);
	while(my $file = $it->()) {
		if(exists $opt->{'substr_dir'}) {
			$file = substr($file, (length($dir) + 1) - length($file));
		}

		if(exists $opt->{'dirs_only'}) {
			next if $file =~ m/^\.\.?$/;
			next unless -d catfile($dir, $file);
		}
		
		push(@ret, $file);
	}

	@ret = sort @ret;
	return ( wantarray ? @ret : \@ret );
}

##################################################################

1;

##################################################################
#
##EOF##
