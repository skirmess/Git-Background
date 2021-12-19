#!perl

use 5.006;
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use Scalar::Util qw(blessed);

use Git::Background;

package Local::Thing;

use overload (
    q("")    => '_stringify',
    bool     => sub () { return 1 },
    fallback => 1,
);

sub _stringify {
    return 'hello world';
}

package main;

{
    my $target = {};
    my $args   = { invalid_arg => 1 };
    like( exception { Git::Background::_set_args( $target, $args ); }, qr{\A\QUnknown argument: 'invalid_arg' \E}, 'throws an exception on an invalid argument' );
}

{
    my $target = {};
    my $args   = { invalid_arg => 1, another_arg => 1 };
    like( exception { Git::Background::_set_args( $target, $args ); }, qr{\A\QUnknown arguments: 'another_arg', 'invalid_arg' \E}, '... or multiple' );
}

{
    my $target = {};
    my $args   = {};
    ok( !defined Git::Background::_set_args( $target, $args ), 'returns undef on success' );
    is_deeply( $target, {}, '... changes nothing on no args' );
}

{
    my $target = {};
    my $args   = { dir => '/tmp/abc', fatal => '0 but true', git => 'git2.1.7' };
    ok( !defined Git::Background::_set_args( $target, $args ), 'returns undef on success' );
    is_deeply( $target, { _dir => '/tmp/abc', _fatal => !!1, _git => ['git2.1.7'] }, '... and changes correct values' );
}

{
    my $dir    = bless {}, 'Local::Thing';
    my $target = {};
    my $args   = { dir => $dir };
    ok( !defined Git::Background::_set_args( $target, $args ), 'returns undef on success' );
    is_deeply( $target, { _dir => 'hello world' }, '... and stringifies dir object' );
    ok( !defined blessed $target->{_dir}, '... really' );
}

{
    my $target = {};
    my $args   = { git => [qw(/usr/bin/sudo -u nobody git)] };
    ok( !defined Git::Background::_set_args( $target, $args ), 'returns undef on success' );
    is_deeply( $target, { _git => [qw(/usr/bin/sudo -u nobody git)] }, '... works for git array ref' );
}

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
