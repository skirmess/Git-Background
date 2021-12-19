#!perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;
use Test::Fatal;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::TempDir qw(tempdir);

use Git::Background;

use constant CLASS => 'Git::Background';

my $bindir = File::Spec->catdir( File::Basename::dirname( File::Basename::dirname( Cwd::abs_path __FILE__ ) ), 'corpus', 'bin' );

my $obj = CLASS()->new( { git => [ $^X, File::Spec->catdir( $bindir, 'my-git.pl' ) ] } );
isa_ok( $obj, CLASS(), 'new returned object' );

#like( exception { $obj->wait },     qr{\QNothing run() yet\E}, 'wait throws an exception if nothing is run yet' );
like( exception { $obj->get },      qr{\QNothing run() yet\E}, 'is_ready throws an exception if nothing is run yet' );
like( exception { $obj->is_ready }, qr{\QNothing run() yet\E}, 'is_ready throws an exception if nothing is run yet' );

note('--version');
is( $obj->run('--version'), $obj, 'run() returns itself' );

ok( exists $obj->{_run},         'contains a _run structure' );
ok( $obj->{_run}{_fatal},        '_run has correct _fatal' );
ok( !defined $obj->{_run}{_dir}, '... _dir' );
is_deeply( $obj->{_run}{_git}, $obj->{_git}, '... git' );
isa_ok( $obj->{_run}{_stderr}, 'File::Temp',       '... stderr' );
isa_ok( $obj->{_run}{_stdout}, 'File::Temp',       '... stdout' );
isa_ok( $obj->{_run}{_proc},   'Proc::Background', '... and _proc' );

my ( $stdout, $stderr, $rc ) = $obj->get;
is( $stdout, "git version 2.33.1\n", 'get() returns correct stdout' );
is( $stderr, q{},                    '... stderr' );
is( $rc,     0,                      '... and exit code' );

like( exception { $obj->is_ready }, qr{\QNothing run() yet\E}, 'is_ready throws an exception after get() is run' );
ok( !exists $obj->{_run}, '_run no longer exists' );

#
is( $obj->run('--version'), $obj, 'run() returns itself' );
$stdout = $obj->get;
is( $stdout, "git version 2.33.1\n", 'get() returns correct stdout' );

#
note('stdout and stderr');
is( $obj->run( '-ostdout line 1', '-estderr line 1', '-estderr line 2', '-ostdout line 2' ), $obj, 'run() returns itself' );

( $stdout, $stderr, $rc ) = $obj->get;
is( $stdout, "stdout line 1\nstdout line 2\n", 'get() returns correct stdout' );
is( $stderr, "stderr line 1\nstderr line 2\n", '... stderr' );
is( $rc,     0,                                '... and exit code' );

#
note('stdout()');
is( $obj->run( '-ostdout line 1', '-estderr line 1', '-estderr line 2', '-ostdout line 2' ), $obj, 'run() returns itself' );
$stdout = $obj->stdout;
is_deeply( $stdout, "stdout line 1\nstdout line 2\n", 'stdout() returns correct stdout (scalar)' );

is( $obj->run( '-ostdout line 1', '-estderr line 1', '-estderr line 2', '-ostdout line 2' ), $obj, 'run() returns itself' );
my @stdout = $obj->stdout;
is_deeply( [@stdout], [ 'stdout line 1', 'stdout line 2' ], 'stdout() returns correct stdout (list)' );

#
note('version()');
is( $obj->version, '2.33.1', 'version() returns version' );

is( $obj->version( { git => [ $^X, File::Spec->catdir( $bindir, 'git-version.pl' ) ] } ), '2.33.2', 'version() returns version' );

#
note('Git::Background->version');
is( Git::Background->version( { git => [ $^X, File::Spec->catdir( $bindir, 'git-version.pl' ) ] } ), '2.33.2', 'version() returns version' );
ok( !defined $obj->version( { git => [ $^X, File::Spec->catdir( $bindir, 'git-noversion.pl' ) ] } ), 'version() returns undef on no version' );

#
note('non fatal');
is( $obj->run( '-x77', '-eerror 1', { fatal => 0 } ), $obj, 'run() returns itself' );

ok( exists $obj->{_run},         'contains a _run structure' );
ok( !$obj->{_run}{_fatal},       '_run has correct _fatal' );
ok( !defined $obj->{_run}{_dir}, '... _dir' );
is_deeply( $obj->{_run}{_git}, $obj->{_git}, '... git' );
isa_ok( $obj->{_run}{_stderr}, 'File::Temp',       '... stderr' );
isa_ok( $obj->{_run}{_stdout}, 'File::Temp',       '... stdout' );
isa_ok( $obj->{_run}{_proc},   'Proc::Background', '... and _proc' );

( $stdout, $stderr, $rc ) = $obj->get;

is_deeply( $stdout, q{},         'get() returns correct stdout' );
is_deeply( $stderr, "error 1\n", '... stderr' );
is( $rc, 77, '... exit code' );

#
is( $obj->run( '-x128', '-ostdout 3', '-ostdout 3 line 2', '-eerror 3', '-eerror 3 line 2', { fatal => 0 } ), $obj, 'run() returns itself' );
my $e = exception { $obj->get };
isa_ok( $e, 'Git::Background::Exception' );
is_deeply( [ $e->stdout ], [ 'stdout 3', 'stdout 3 line 2' ], 'error obj contains correct stdout (list)' );
is( $e->stdout, "stdout 3\nstdout 3 line 2\n", '(scalar)' );
is_deeply( [ $e->stderr ], [ 'error 3', 'error 3 line 2' ], 'error obj contains correct stderr (list)' );
is( $e->stderr,    "error 3\nerror 3 line 2\n", '(scalar)' );
is( $e->exit_code, 128,                         'error obj contains correct exit code' );

#
is( $obj->run( '-x129', '-ostdout 3', '-ostdout 3 line 2', '-eerror 3', '-eerror 3 line 2', { fatal => 0 } ), $obj, 'run() returns itself' );
$e = exception { $obj->get };
isa_ok( $e, 'Git::Background::Exception' );
is_deeply( [ $e->stdout ], [ 'stdout 3', 'stdout 3 line 2' ], 'error obj contains correct stdout (list)' );
is( $e->stdout, "stdout 3\nstdout 3 line 2\n", '(scalar)' );
is_deeply( [ $e->stderr ], [ 'error 3', 'error 3 line 2' ], 'error obj contains correct stderr (list)' );
is( $e->stderr,    "error 3\nerror 3 line 2\n", '(scalar)' );
is( $e->exit_code, 129,                         'error obj contains correct exit code' );

#
is( $obj->run( '-x1', '-ostdout 3', '-ostdout 3 line 2', '-eerror 3', '-eerror 3 line 2' ), $obj, 'run() returns itself' );
$e = exception { $obj->get };
isa_ok( $e, 'Git::Background::Exception' );
is_deeply( [ $e->stdout ], [ 'stdout 3', 'stdout 3 line 2' ], 'error obj contains correct stdout (list)' );
is( $e->stdout, "stdout 3\nstdout 3 line 2\n", '(scalar)' );
is_deeply( [ $e->stderr ], [ 'error 3', 'error 3 line 2' ], 'error obj contains correct stderr (list)' );
is( $e->stderr,    "error 3\nerror 3 line 2\n", '(scalar)' );
is( $e->exit_code, 1,                           'error obj contains correct exit code' );

# run twice
is( $obj->run('-ostdout1'), $obj, 'run() returns itself' );
like( exception { $obj->run('-ostdout2') }, qr{\QYou need to get() the result of the last run() first\E}, q{run() croaks if the last run wasn't get()ted} );

# dir
my $dir = tempdir();
$obj = CLASS()->new( $dir, { git => [ $^X, File::Spec->catdir( $bindir, 'my-git.pl' ) ] } );
isa_ok( $obj, CLASS(), 'new returned object' );

ok( $obj->{_fatal}, 'obj has correct _fatal' );
is( $obj->{_dir}, $dir, 'obj has correct _dir' );
is_deeply( $obj->{_git}, $obj->{_git}, 'obj has correct _git' );

is( $obj->run( { dir => undef } ), $obj, 'run returns itself' );
ok( !defined $obj->{_run}{_dir}, '_dir can be overwritten with undef in run' );
is( $obj->{_dir}, $dir, '... but not in obj' );
$obj->get;

my $dir2 = tempdir();
is( $obj->run( { dir => $dir2 } ), $obj,  'run returns itself' );
is( $obj->{_run}{_dir},            $dir2, 'dir can be overwritten with another dir in run' );
is( $obj->{_dir},                  $dir,  '... but not in obj' );

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
