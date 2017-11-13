##############################################################
# $Id: Be.pm,v 1.7 2017-07-24 02:13:20+03 beast Exp beast $
##############################################################
#
#          Just a set of my favourite subroutines.
#          ---------------------------------------
#
##############################################################
# Changelog:
# ----------
# v.1.7: [2017-07-24 02:13:20+03]
# After two years minor changes to all subroutines. Making
# use of 'autodie' pragma and 'Modern::Perl' and
# 'constant::boolean' modules now. 'use strict' and
# 'use warnings' and 'Carp' have gone with the wind.
# Started (at last!) writing the date of release near the
# version in Changelog.
#-------------------------------------------------------------
#
# v.1.6:
# Minor changes to all subroutines.
#-------------------------------------------------------------
#
# v 1.5:
# Replaced die() with confess() of Carp module
#-------------------------------------------------------------
#
# v 1.4:
# Minor changes to all subroutines.
#-------------------------------------------------------------
#
# v 1.3:
# Fix to read_file() subroutine changing it's behavior.
# From now on $skip_comments should be 1 to skip comments
# and 0 to return file contents AS-IS.
#-------------------------------------------------------------
#
# v 1.2:
# Moved read_dir() subroutine to new module Be::read_dir
# because had rewritten the subroutine to make use of
# 'Path::Iterator::Rule' module.
# Added option to return scalar value containing the whole 
# file to read_file() subroutine.
# Minor bugfix to kno_my_name().
#-------------------------------------------------------------
#
# v 1.1: Initial public release.
##############################################################
package Be;
#
$VERSION = '1.7';
#
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	read_file
	kno_my_name
	template
	trim
	ext_cfg
);
#
##############################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use File::Basename;
use Cwd 'abs_path';
use constant::boolean;
##############################################################
#
##############################################################
# read_file($file[, $skip_comments])
#
# Reads a file and returns an array of lines
# w/o comments and blank lines
# (unless $skip_comments is set to 0).
##############################################################
sub read_file ($;$) {
	my $file = shift;
	my $comm = shift || 0;
#
	return undef unless (defined wantarray && $file && -s $file);
#	
	my @arr;
	my $txt;
#
	open(my $fh, "<", $file);
	if(wantarray || $comm) {
		@arr = <$fh>;
	}
	else {
		local $/;
		$txt = <$fh>;
	}
	close $fh;
#	
	return ( wantarray ? @arr : $txt ) if ( $comm == 0 );
#
	my @a;
	for(@arr) {
		chomp;
		s/^\s+$//;
		next if (m/^#/ || m/^$/);
		push(@a, $_);
	}
	undef @arr;
#		
	return ( wantarray ? @a : join("\n", @a) ) if @a;
	return FALSE;
}
#
##############################################################
# kno_my_name($file)
#
# Returns file's full name or array of file's path, name and
# extension..
##############################################################
sub kno_my_name (;$) {
	my $name = shift || $0;
#
	$name = abs_path($name);
#
	if( wantarray ) {
		my($file, $dir, $suff) = fileparse($name, qr/\.[^.]*$/);
		return ($dir, $file, $suff);
	}
	elsif(defined(wantarray)) {
		return $name;
	}
	else {
		return FALSE;
	}
}
#
##############################################################
# template($file, $fillings)
#
# A sub I like very much. Took it from Perl Cookbook 2nd edition.
# Recipe # 20.9. Slight changes.
##############################################################
sub template ($$) {
	my ($filename, $fillings) = @_;
#
	return undef unless -s $filename;
#
	my $text;
#
	local $/;
#
	open(my $fh, "<", $filename);
	$text = <$fh>;
	close $fh;
#
	return unless $text;
#
	$text =~ s{ %% ( .*? ) %% }
	{ exists( $fillings->{$1} )
		? $fillings->{$1}
		: ""
	}gsex;
#
	chomp $text;
#
	return $text;
}
#
##############################################################
# trim($string)
#
# Trim whitespaces from both sides of the line. 
##############################################################
sub trim ($) {
	my $s = shift;
#	
	return undef unless $s;
#
	chomp $s;
#
	$s =~ s/^\s+//;
	$s =~ s/\s+$//;
#
	return $s if length($s);
#
	return FALSE;
}
#
##############################################################
# ext_cfg($file[, $name_value_delimiter])
#
# Reads external simple configuration file and returns a hash
# reference containing the data.
##############################################################
sub ext_cfg ($;$) {
        my $file  = shift;
        my $delim = shift || "=";
#
        my %ret; # Reference to the hash will be returned.
#
        open(my $fh, "<", $file);
        while(<$fh>) {
                chomp;
				s/^\s+$//;
                next if ( m/^#/ || m/^$/ );
                next unless m/^([^${delim} ]*)\s?${delim}\s?[\"\']?(.*)$/;
                my $key = $1;
                my $val = $2;
                $val =~ s/[\"\']$//;
                $ret{$key} = $val;
        }
        close $fh;
#
        return ( %ret ? \%ret : FALSE );
}
##############################################################
#
1;
#
##############################################################
#
##EOF##
