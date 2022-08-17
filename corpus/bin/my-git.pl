#!perl

# vim: ts=4 sts=4 sw=4 et: syntax=perl
#
# Copyright (c) 2021-2022 Sven Kirmess
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use 5.006;
use strict;
use warnings;

if ( @ARGV == 1 && $ARGV[0] eq '--version' ) {
    print "git version 2.33.1\n";
    exit 0;
}

my $exit_code = 0;
for my $arg (@ARGV) {
    if ( $arg =~ m{ \A -x ( [0-9]+ ) \z }xsm ) {
        $exit_code = $1;
    }
    elsif ( $arg =~ s{ \A -e }{}xsm ) {
        chomp $arg;
        print STDERR "$arg\n";
    }
    elsif ( $arg =~ s{ \A -o }{}xsm ) {
        chomp $arg;
        print STDOUT "$arg\n";
    }
    else {
        die "Invalid argument: $arg";
    }
}

exit $exit_code;
