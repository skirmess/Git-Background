#!perl

# vim: ts=4 sts=4 sw=4 et: syntax=perl
#
# Copyright (c) 2021-2023 Sven Kirmess
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

use Test::MockModule 0.14;
use Test::More 0.88;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), qw(.. t lib) );

use Carp;

use Local::Test::Exception qw(exception);

use Git::Background 0.003;

my $bindir = File::Spec->catdir( File::Basename::dirname( File::Basename::dirname( Cwd::abs_path __FILE__ ) ), 'corpus', 'bin' );
my $mock   = Test::MockModule->new('Path::Tiny');

note('stdout / read error');
{
    $mock->redefine( 'lines_utf8', sub { croak '47' } );

    my $obj = Git::Background->new( { git => [ $^X, File::Spec->catdir( $bindir, 'my-git.pl' ) ] } );
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    my $f = $obj->run( '-x128', '-ostdout 3', '-ostdout 3 line 2', '-eerror 3', '-eerror 3 line 2', { fatal => 0 } );
    isa_ok( $f, 'Git::Background::Future', 'run() returns a Git::Background::Future' );
    my $e = exception { $f->get };
    isa_ok( $e, 'Future::Exception' );
    ok( !$f->is_done,  '!is_done' );
    ok( $f->is_ready,  'is_ready' );
    ok( $f->is_failed, 'is_failed' );

    like( $e, qr{\A\QCannot read stdout: 47 \E}, '... throws an error if file cannot be read' );

    $mock->unmock('lines_utf8');
}

note('stderr / read error');
{
    my $c = 0;
    $mock->redefine(
        'lines_utf8',
        sub {
            $c++;

            # skip over the first error call, which is the one for stdout
            return $mock->original('lines_utf8')->(@_) if $c == 1;

            croak '19';
        },
    );

    my $obj = Git::Background->new( { git => [ $^X, File::Spec->catdir( $bindir, 'my-git.pl' ) ] } );
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    my $f = $obj->run( '-x128', '-ostdout 3', '-ostdout 3 line 2', '-eerror 3', '-eerror 3 line 2', { fatal => 0 } );
    isa_ok( $f, 'Git::Background::Future', 'run() returns a Git::Background::Future' );
    my $e = exception { $f->get };
    isa_ok( $e, 'Future::Exception' );
    ok( !$f->is_done,  '!is_done' );
    ok( $f->is_ready,  'is_ready' );
    ok( $f->is_failed, 'is_failed' );

    like( $e, qr{\A\QCannot read stderr: 19 \E}, '... throws an error if file cannot be read' );

    $mock->unmock('lines_utf8');
}

#
done_testing();

exit 0;
