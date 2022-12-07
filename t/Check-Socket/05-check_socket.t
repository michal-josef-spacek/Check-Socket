use strict;
use warnings;

use Check::Socket qw(check_socket);
use Config;
use Socket;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $ret = check_socket;
if ($ENV{PERL_CORE} and $Config{'extensions'} !~ /\bSocket\b/) {
	is($ret, 0, 'Test the impossibility of socket communication (missing Socket extension).');
} elsif ($ENV{PERL_CORE} and $Config{'extensions'} !~ /\bIO\b/) {
	is($ret, 0, 'Test the impossibility of socket communication (missing IO extension).');
} elsif ($^O eq 'qnx') {
	is($ret, 0, 'Test the impossibility of socket communication (qnx).');
} elsif ($^O eq 'tos') {
	is($ret, 0, 'Test the impossibility of socket communication (tos).');
} elsif ($^O eq 'nto') {
	is($ret, 0, 'Test the impossibility of socket communication (nto).');
} elsif ($^O eq 'MSWin32') {
	if ($ENV{'CONTINUOUS_INTEGRATION'}) {
		is($ret, 0, 'Test the impossibility of socket communication - we have continuous integration (Windows).');
	} else {
		if (! eval { socket(my $sock, PF_UNIX, SOCK_STREAM, 0) }) {
			is($ret, 0, 'Test the impossibility of socket communication (Windows).');
		} else {
			is($ret, 1, 'Test for successful socket communication (Windows).');
		}
	}
} else {
	ok(1, 'Test for successful socket communication ('.$^O.').');
}
