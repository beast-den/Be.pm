##################################################################
# $Id: Crypt.pm,v 1.2 2017-07-24 02:50:06+03 beast Exp beast $
##################################################################
#
# String encryption and decryption subroutines.
#
# Have stolen somewhere on the Internet. I'm ashamed, but still
# don't remember where I got these subroutines from.
#
# ----------------------------------------------------------------
# Changelog:
# ---------
# v.1.2
# After two years, minor changes to all subroutines. Making use of
# 'autodie' pragma and 'Modern::Perl' and 'constant::boolean'
# modules. 'use strict' and 'use warnings' have gone with the wind.
# ----------------------------------------------------------------
#
# v.1.1
# Initial public release
##################################################################
package Be::Crypt;

$VERSION = '1.2';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	encryptString
	decryptString
	md5hex
);

##################################################################
use autodie qw/:all/;
use Modern::Perl '2017';
use Convert::PEM;
use Crypt::OpenSSL::RSA;
use MIME::Base64;
use Digest::MD5;
use constant::boolean;
##################################################################

##################################################################
# encryptString($str)
# Encrypts $str and returns encrypted string.
##################################################################
sub encryptString ($$) {
	my ($public_key, $string) = @_;

	return undef unless( -s $public_key && length($string) );

	my $key_string;
	open(my $pub, $public_key);
	read($pub, $key_string, -s $pub);
	close($pub);

	my $public = Crypt::OpenSSL::RSA->new_public_key($key_string);
	return encode_base64($public->encrypt($string));
}

##################################################################
# decryptString($str)
# Decrypts $str and returns decrypted string.
##################################################################
sub decryptString ($$$) {
	my ($private_key, $password, $string) = @_;

	return undef unless( -s $private_key && length($password) );

	my $key_string = readPrivateKey($private_key, $password);
	return undef unless $key_string;

	my $private = Crypt::OpenSSL::RSA->new_private_key($key_string);

	return $private->decrypt(decode_base64($string));
}

##################################################################
sub readPrivateKey ($$) {
	my ($file, $password) = @_;

	return undef unless( -s $file && length($password) );

	my $key_string;
	$key_string = decryptPEM($file, $password);

	return $key_string if $key_string;

	return FALSE;
}

##################################################################
sub decryptPEM ($$) {
	my ($file, $password) = @_;

	return undef unless( -s $file && length($password) );

	my $pem = Convert::PEM->new(
		Name => 'RSA PRIVATE KEY',
		ASN => qq(
			RSAPrivateKey SEQUENCE {
				version INTEGER,
				n INTEGER,
				e INTEGER,
				d INTEGER,
				p INTEGER,
				q INTEGER,
				dp INTEGER,
				dq INTEGER,
				iqmp INTEGER
			}
			)
		);

		my $pkey = $pem->read(Filename => $file, Password => $password);
		return FALSE unless $pkey;

		return $pem->encode(Content => $pkey);
}

##################################################################
# md5hex(@str)
#
# Makes MD5 hexdigest string length of 32 chars out of array of
# strings.
##################################################################
sub md5hex (@) {
	my @str = @_;

	my $md5 = Digest::MD5->new;
	for(@str) {
		$md5->add( $_ );
	}

	my $ret = $md5->hexdigest;
	return $ret	if length($ret) == 32;
	return FALSE;
}

##################################################################

1;

##################################################################
#
##EOF##
