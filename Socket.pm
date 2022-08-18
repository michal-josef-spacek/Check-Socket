package Check::Socket;

use base qw(Exporter);
use strict;
use warnings;

use Config;
use IO::Socket;
use Readonly;

our $ERROR_MESSAGE;
Readonly::Array our @EXPORT_OK => qw(check_socket $ERROR_MESSAGE);

our $VERSION = 0.01;

sub check_socket {
	my ($config_hr, $os, $env_hr) = @_;

	$config_hr ||= \%Config;
	$os ||= $^O;
	$env_hr ||= \%ENV;

	if ($env_hr->{PERL_CORE} and $config_hr->{'extensions'} !~ /\bSocket\b/) {
		$ERROR_MESSAGE = 'Socket extension unavailable.';
		return 0;
	}

	if ($env_hr->{PERL_CORE} and $config_hr->{'extensions'} !~ /\bIO\b/) {
		$ERROR_MESSAGE = 'IO extension unavailable.';
		return 0;
	}

	if ($os eq 'os2') {
		eval { IO::Socket::pack_sockaddr_un('/foo/bar') || 1 };
		if ($@ =~ /not implemented/) {
			$ERROR_MESSAGE = "$os: Compiled without TCP/IP stack v4.";
			return 0;
		}
	}

	if ($os =~ m/^(?:qnx|nto|vos)$/ ) {
		$ERROR_MESSAGE = "$os: UNIX domain sockets not implemented.";
		return 0;
	}

	if ($os eq 'MSWin32') {
		if ($env_hr->{CONTINUOUS_INTEGRATION}) {
			# https://github.com/Perl/perl5/issues/17429
			$ERROR_MESSAGE = "$^O: Skip sockets on CI";
			return 0;
		}

		# https://github.com/Perl/perl5/issues/17575
		if (! eval { socket(my $sock, PF_UNIX, SOCK_STREAM, 0) }) {
			$ERROR_MESSAGE = "$os: AF_UNIX unavailable or disabled.";
			return 0;
		}
	}

	return 1;
}

1;

__END__
