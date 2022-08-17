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

use Test::More 0.88;

use Scalar::Util qw(blessed);

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Thing;
use Local::Test::TempDir qw(tempdir);

use Git::Background 0.003;

note('new()');
{
    my $obj = Git::Background->new;
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note(q{new( { fatal => 0, git => 'my-git' } )});
{
    my $obj = Git::Background->new( { fatal => 0, git => 'my-git' } );
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( !$obj->{_fatal}, 'fatal is false' );
    is_deeply( $obj->{_git}, ['my-git'], 'git is configured to my-git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note(q{new( { git => [qw(nice -19 git)] } )});
{
    my $obj = Git::Background->new( { git => [qw(nice -19 git)] } );
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, [qw(nice -19 git)], 'git is configured to nice -19 git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note('new($dir)');
{
    my $dir = tempdir();
    my $obj = Git::Background->new($dir);
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
}

note(q{new( $dir, { fatal => 0, git => 'my-git' } )});
{
    my $dir = tempdir();
    my $obj = Git::Background->new( $dir, { fatal => 0, git => 'my-git' } );
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( !$obj->{_fatal}, 'fatal is false' );
    is_deeply( $obj->{_git}, ['my-git'], 'git is configured to my-git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
}

note('new($dir_obj)');
{
    my $dir = tempdir();

    # We need an object that can stringify
    my $dir_obj = Local::Thing->new($dir);

    my $obj = Git::Background->new($dir_obj);
    isa_ok( $obj, 'Git::Background', 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
    ok( !blessed $obj->{_dir}, 'dir is not an object' );
}

#
done_testing();

exit 0;
