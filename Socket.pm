package Check::Socket;

use base qw(Exporter);
use strict;
use warnings;

use Config;
use IO::Socket;
use Readonly;

Readonly::Array our @EXPORT_OK => qw(check_socket);
Readonly::Scalar our $ERROR_MESSAGE => '';

our $VERSION = 0.01;

sub check_socket {
	if ($ENV{PERL_CORE} and $Config{'extensions'} !~ /\bSocket\b/) {
		$ERROR_MESSAGE = 'Socket extension unavailable.';
		return 0;
	}

	if ($ENV{PERL_CORE} and $Config{'extensions'} !~ /\bIO\b/) {
		$ERROR_MESSAGE = 'IO extension unavailable.';
		return 0;
	}

	if ($^O eq 'os2') {
		eval { IO::Socket::pack_sockaddr_un('/foo/bar') || 1 };
		if ($@ =~ /not implemented/) {
			$ERROR_MESSAGE = 'os2: Compiled without TCP/IP stack v4.';
			return 0;
		}
	}

	if ($^O =~ m/^(?:qnx|nto|vos)$/ ) {
		$ERROR_MESSAGE = "$^O: UNIX domain sockets not implemented.";
		return 0;
	}

	if ($^O eq 'MSWin32') {
		if ($ENV{CONTINUOUS_INTEGRATION}) {
			# https://github.com/Perl/perl5/issues/17429
			$ERROR_MESSAGE = "$^O: Skip sockets on CI";
			return 0;
		}

		# https://github.com/Perl/perl5/issues/17575
		if (! eval { socket(my $sock, PF_UNIX, SOCK_STREAM, 0) }) {
			$ERROR_MESSAGE = "$^O: AF_UNIX unavailable or disabled.";
			return 0;
		}
	}

	return 1;
}

1;

__END__
