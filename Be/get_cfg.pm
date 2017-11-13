#
###########################################################################
# $Id: get_cfg.pm,v 1.1 2016/07/24 13:11:20 beast Exp beast $
###########################################################################
package Be::get_cfg;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
		get_cfg
	);
#
###########################################################################
# 
# Provides subroutine for handling section driven configuration files
#
###########################################################################
use strict;
use warnings FATAL => 'all';
use Config::Simple;
###########################################################################

sub get_cfg {
	my $cfg = Config::Simple->new(shift) or return;
	my %ret = $cfg->vars();
	return ( $cfg, \%ret ) if wantarray;
	return \%ret if %ret;
	return 0;
}

###########################################################################
# 

1;

#
###########################################################################
#
##EOF##
