##################################################################
# $Id: DB.pm,v 1.4 2018-02-01 19:45:15+03 beast Exp beast $
##########################0########################################
#
#                  Databases related subroutines
#                  -----------------------------
#
# ----------------------------------------------------------------
# Changelog:
# ---------
# v.1.4: [2018-02-01 19:45:15+03]
# Added dbh() subroutine.
#
# v.1.3: [2017-07-31 12:39:33+03]
# Had to get rid of "SET NAMES 'utf8';" request, mentioned in
# previous record. The reason is simple - I started experimenting
# with different UTF-8 collations and encodings. At the time have
# to issue the good old '$dbh->do("SET NAMES 'utf8' COLLATE...
# request in the beginning of scripts working with the DB. Minor
# changes to the get_dbh() sub plus to these described.
#
# v.1.2
# After two years changes to get_dbh() sub. Added
# 'mysql_enable_utf8 => 1' to the default options. Enclosed
# 'connect' method into 'eval' block to track errors myself.
# Added opportunity to use 'mysql_read_default_file' to point DBI
# to read custom my.cnf configuration file.
# Added 'SET NAMES "utf8";' request when connected.
# Got rid of 'strict' and 'warnings' pragmas. Making use of
# 'autodie' pragma and 'Modern::Perl' module instead. Using
# 'constant::boolean' module from now on also.
# ----------------------------------------------------------------
#
# v.1.1
# Initial public release.
##################################################################
package Be::DB;

$VERSION = 1.4;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	get_dbh
	dbh
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use DBI;
use constant::boolean;
##################################################################

##################################################################
# get_dbh($configuration[, $options])
#
# Gets configuration data and returns DBI database object.
##################################################################
sub get_dbh ($;$) {
	my $cfg = shift;
	my $opt = shift ||
	{ RaiseError => 1, AutoCommit => 0 };

	my $dbtype = $cfg->{'DBType'} || 'mysql';
	
	if($dbtype eq 'mysql') {
		$opt->{'mysql_enable_utf8'} = 1;
	}
	
	my $dbname = $cfg->{'DBName'} || '';
	my $dbuser = $cfg->{'DBUser'} || '';
	my $dbpass = $cfg->{'DBPass'} || '';
	my $socket = $cfg->{'DBSock'};
	my $port_n = $cfg->{'DBPort'} || 0;
	my $dbhost = $cfg->{'DBHost'};
	my $my_cnf = $cfg->{'DBConf'};

	return undef unless $dbname;
	
	if( $dbhost eq "127.0.0.1" || lc($dbhost) eq 'localhost' ) {
		$dbhost = 0;
	}

	my $dsn = "dbi:" . $dbtype . ":dbname=" . $dbname;
	$dsn .= ";host=" . $dbhost if $dbhost;
	$dsn .= ";mysql_socket=" . $socket if defined $socket;
	$dsn .= ";port=" . $port_n if int($port_n);
	$dsn .= ";mysql_read_default_file=" . $my_cnf if defined $my_cnf;

	my $dbh;
	eval {
		$dbh = DBI->connect($dsn, $dbuser, $dbpass, $opt) or die;
	};

	return FALSE if ( $@ );

	return $dbh;
}

sub dbh ($) {
	my $cfg = shift;
	return undef unless ref($cfg) eq 'HASH';
	return get_dbh($cfg);
}
##################################################################

1;

##################################################################
#
##EOF##
