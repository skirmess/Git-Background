#!perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;

use Git::Background::Exception;

use constant CLASS => 'Git::Background::Exception';

note('with output');
{
    my $obj = CLASS()->new(
        {
            exit_code => 7,
            stderr    => "an error\nhappend",
            stdout    => "text on\nstdout\n",
        }
    );
    isa_ok( $obj, CLASS(), 'new returned object' );

    is( $obj->{_exit_code}, 7, 'contains exit_code' );
    is( $obj->exit_code,    7, 'can be read by ->exit_code' );

    is( $obj->{_stderr}, "an error\nhappend", 'contains correct stderr' );
    is_deeply( [ $obj->stderr ], [ 'an error', 'happend' ], 'can be read by ->stderr as list' );
    is( $obj->stderr, "an error\nhappend", '... or scalar' );

    is_deeply( $obj->{_stdout},  "text on\nstdout\n",     'contains correct stdout' );
    is_deeply( [ $obj->stdout ], [ 'text on', 'stdout' ], 'can be read by ->stdout as list' );
    is( $obj->stdout, "text on\nstdout\n", '... or scalar' );

    is( "$obj",           "an error\nhappend", 'object stringifies to stderr' );
    is( ( $obj ? 1 : 0 ), 1,                   'booleanizes to true' );
}

note('without output');
{
    my $obj = CLASS()->new(
        {
            exit_code => 11,
            stderr    => q{},
            stdout    => q{},
        }
    );
    isa_ok( $obj, CLASS(), 'new returned object' );

    is( $obj->{_exit_code}, 11, 'contains exit_code' );
    is( $obj->exit_code,    11, 'can be read by ->exit_code' );

    is( $obj->{_stderr}, q{}, 'contains no stderr' );
    is_deeply( [ $obj->stderr ], [], 'can be read by ->stderr as list' );
    is( $obj->stderr, q{}, '... and scalar' );

    is( $obj->{_stdout}, q{}, 'contains no stdout' );
    is_deeply( [ $obj->stdout ], [], 'can be read by ->stdout as list' );
    is( $obj->stdout, q{}, '... and scalar' );

    is( "$obj",           'git exited with fatal exit code 11 but had no output to stderr', 'object stringifies to correct message' );
    is( ( $obj ? 1 : 0 ), 1,                                                                'booleanizes to true' );
}

note('boolean');
{
    my $obj = CLASS()->new(
        {
            exit_code => 13,
            stderr    => '0',
            stdout    => q{},
        }
    );
    isa_ok( $obj, CLASS(), 'new returned object' );

    is( "$obj",           '0', 'object stringifies to stderr' );
    is( ( $obj ? 1 : 0 ), 1,   'booleanizes to true' );
}

note('incorrect usage');
{
    my $obj = CLASS()->new;
    isa_ok( $obj, CLASS(), 'new returned object' );

    ok( !defined $obj->{_exit_code}, q{_exit_code doesn't exist} );
    ok( !defined $obj->{_stderr},    q{_stderr doesn't exist} );
    ok( !defined $obj->{_stdout},    q{_stdout doesn't exist} );

    ok( !defined $obj->exit_code, q{exit_code returns undef} );
    is( $obj->stderr, q{}, q{stderr returns an empty string} );
    is_deeply( [ $obj->stderr ], [], q{... or list} );
    is( $obj->stdout, q{}, q{stdout returns an empty string} );
    is_deeply( [ $obj->stdout ], [], q{... or list} );

    is( "$obj",           'git exited with a fatal exit code but had no output to stderr', 'object stringifies to correct message' );
    is( ( $obj ? 1 : 0 ), 1,                                                               'booleanizes to true' );
}

#
done_testing();

exit 0;

# vim: ts=4 sts=4 sw=4 et: syntax=perl
