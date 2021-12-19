#!perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;
use Test::Fatal;

use Scalar::Util qw(blessed);

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::TempDir qw(tempdir);

use Git::Background;
use Git::Background::Exception;

use constant CLASS => 'Git::Background';

note('new()');
{
    my $obj = CLASS()->new;
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note(q{new( { fatal => 0, git => 'my-git' } )});
{
    my $obj = CLASS()->new( { fatal => 0, git => 'my-git' } );
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( !$obj->{_fatal}, 'fatal is false' );
    is_deeply( $obj->{_git}, ['my-git'], 'git is configured to my-git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note(q{new( { git => [qw(nice -19 git)] } )});
{
    my $obj = CLASS()->new( { git => [qw(nice -19 git)] } );
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, [qw(nice -19 git)], 'git is configured to nice -19 git' );
    ok( !exists $obj->{_dir}, 'dir is not set' );
}

note(q{new( { invalid_argument => 17 } )});
{
    like( exception { CLASS()->new( { invalid_argument => 17 } ) }, qr{\QUnknown argument: 'invalid_argument'\E}, 'new throws an exception for an invalid argument' );
}

note('new($dir)');
{
    my $dir = tempdir();
    my $obj = CLASS()->new($dir);
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
}

note(q{new( $dir, { fatal => 0, git => 'my-git' } )});
{
    my $dir = tempdir();
    my $obj = CLASS()->new( $dir, { fatal => 0, git => 'my-git' } );
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( !$obj->{_fatal}, 'fatal is false' );
    is_deeply( $obj->{_git}, ['my-git'], 'git is configured to my-git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
}

note(q{new( $dir, { dir => $dir } )});
{
    my $dir = tempdir();
    like( exception { CLASS()->new( $dir, { dir => $dir } ); }, qr{\A\QCannot specify dir as positional argument and in argument hash\E}, 'throws an exception if dir is specified twice' );
}

note('new($dir_obj)');
{
    my $dir = tempdir();

    # We need an object that can stringify
    my $dir_obj = Git::Background::Exception->new( { stderr => $dir } );

    my $obj = CLASS()->new($dir_obj);
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( $obj->{_fatal}, 'fatal is true' );
    is_deeply( $obj->{_git}, ['git'], 'git is configured to git' );
    is( $obj->{_dir}, $dir, 'dir is set' );
    ok( !blessed $obj->{_dir}, 'dir is not an object' );
}

note(q{to many/wrong arguments});
{
    my $dir = tempdir();
    like( exception { CLASS()->new( $dir, { fatal => 0, git => 'my-git' }, 'hello world' ) }, qr{\Qusage: new( [DIR], [ARGS] )\E}, 'new throws an exception with to many arguments' );
    like( exception { CLASS()->new( $dir, 'hello world' ) }, qr{\Qusage: new( [DIR], [ARGS] )\E}, 'new throws an exception with wrong argument' );
}

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
