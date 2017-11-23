###########################################################################
# $Id: SMTP.pm,v 1.1 2017-07-31 14:05:43+03 beast Exp beast $
###########################################################################
# Changelog:
# ---------
# v.1.1: [2017-07-31 14:05:43+03]
# Initial public release.
###########################################################################
package Be::SMTP;

$VERSION = '1.1';

require Exporter;
@ISA = qw(Exporter);
###########################################################################
@EXPORT = qw(
	send_mail
	$HELP
);
###########################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use Net::SMTP;
use constant::boolean;
###########################################################################
#
###########################################################################
sub send_mail ($$$$$) {
	my $realn = shift; # Recipient's real name
	my $email = shift; # Recipient's email
	my $subjt = shift; # Subject
	my $messg = shift; # Message body
	my $optns = shift; # { mail_from => $Config->{'mail_from'}, smtp_user => $Config->{'smtp_user'}, smtp_pass => $Config->{'smtp_pass'}, smtp_host => 'smtp.yandex.ru', smtp_SSL => 1, smtp_port => 465, msg_type => 'html', smtp_debug => 0 };
	################################################################
    	my $from  = $optns->{'mail_from'};
	my $uname = $optns->{'smtp_user'};
	my $passw = $optns->{'smtp_pass'};
	my $htmlm = $optns->{'mail_type'} || 'plain';

	my $smtp = Net::SMTP->new($optns->{'smtp'},
		SSL	=> $optns->{'smtp_SSL'} || 0,
		Port	=> $optns->{'smtp_port'} || 25,
		Debug	=> $optns->{'smtp_debug'} || 0,
	);

	$smtp->auth($uname, $passw);

	my @lin = split(/\n/, $messg);

	$smtp->mail($uname);
	$smtp->to($email);
	$smtp->data();
	$smtp->datasend("Content-type: text/" . $htmlm . "; charset=utf-8\n");
	$smtp->datasend("Content-Transfer-Encoding: quoted-printable\n") if $htmlm eq 'html';
	$smtp->datasend("Subject: " . $subjt . "\n");	
	$smtp->datasend("From: " . $from . " <" . $uname . ">\n");	
	
	$realn =~ s/[\"\'\,]//g;
	if($realn) {
		$smtp->datasend("To: " . $realn . "<" . $email . ">\n");
	}
	else {
		$smtp->datasend("To: " . $email . "\n");
	}

	$smtp->datasend("\n");

	for( @lin ) {
		$smtp->datasend($_ . "\n");
	}

	$smtp->dataend();

	return $smtp->quit;
}

###########################################################################
$HELP = <<"HELP";
The module exports single subroutine that sends e-mail messages via SMTP.
It takes a bunch of parameters. Let's see what those parameters are.

1. Recipient's name (nickname possibly).
2. Recipient's e-mail address.
3. E-mail message subject.
4. Body of the essage
5. Hash reference could be received from ext_cfg() subroutine from 'Be.pm'.

The example configuration file could be used to get configuration data
if read by the ext_cfg() sub from 'Be.pm' follows. Of cource you are free
to make the hash ref required by any means.
----- cut ------
smtp_host = 'smtp.myisp.com'
smtp_port = 465
smtp_SSL = 1
smtp_user = 'someuser\@myisp.com'
smtp_pass = 'v3rYsecR3t'
smtp_debug = 0
mail_from = 'Some Person'
mail_type = (html|plain)
----- cut ------

By keeping config similar to shown and having my modules installed in \@INC
sending mail to anybody is as simple as this:

use Be;
use Be::SMTP;

my \$cfg = ext_cfg(CONFIG_FILE);

if(send_mail('My Girl', 'her\@mail.com', 'Hi!', \$msg, \$cfg)) {
	say "Success!";
}

Hope you'll enjoy using this!

-- Denis Kouznetsov

HELP
###########################################################################

1;

###########################################################################
#
#
##EOF##
