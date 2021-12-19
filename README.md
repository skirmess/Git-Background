# NAME

Git::Background - Perl interface to run Git commands (in the background)

# VERSION

Version 0.001

# SYNOPSIS

    my $git = Git::Background->new($dir);
    $git->run('status', '-s');
    my @status = $git->stdout;

# USAGE

## new( \[DIR\], \[ARGS\] )

Creates and returns a new `Git::Background` object. If you specify the
`dir` positional argument, or use the `dir` argument in the args hash
the directory is passed as `cwd` option to [Proc::Background](https://metacpan.org/pod/Proc%3A%3ABackground) causing it
to change into that directory before running the Git command.

Both, the `dir` positional argument and the args hash are optional. An
exception is thrown if you specify both.

    my $git = Git::Background->new;
    my $git = Git::Background->new($dir);
    my $git = Git::Background->new( { dir => $dir, fatal => 0 } );
    my $git = Git::Background->new( $dir, { fatal => 0 } );

`new` either returns a valid `Git::Background` object or throws an
exception.

The following options can be passed in the args hash to new. They are used
as defaults for calls to `run`.

### dir

This will be passed as `cwd` argument to [Proc::Background](https://metacpan.org/pod/Proc%3A%3ABackground) whenever you
call `run`. If you don't specify a `dir` all Git commands are executed in
whatever the current working directory is when you call `run`.

### fatal

Enabled by default. The `fatal` option controls if `get` and `stdout`
throw an exception when Git returns a non-zero return code.

Please not that `get` and `stdout` always throws an exception if Git
returns 128 (fatal Git error) or 129 (Git usage error) regardless of the
truthiness of `fatal`. `get` and `stdout` also throws an exception if
another error happens, e.g. if the output from Git cannot be read.

### git

The Git command used to run. This defaults to `git` and lets
[Proc::Background](https://metacpan.org/pod/Proc%3A%3ABackground) work its magic to find the binary on your platform.

This can be either a string,

    my $git = Git::Background->new( { git => '/opt/git/bin/git' } );

or an array ref.

    my $git = Git::Background->new({
        git => [ qw( /usr/bin/sudo -u nobody git ) ],
    });

## run( @CMD, \[ARGS\] )

This runs the specified Git command in the background by passing it on to
[Git::Background](https://metacpan.org/pod/Git%3A%3ABackground). The last argument can be an argument hash that takes the
same arguments as `new`.

    my $git = Git::Background->new($dir);
    $git->run('status', '-s', { fatal => 0 } );

    my ($stdout, $stderr, $exit_code) = $git->get;
    if ( $exit_code ) {
        say q{Unable to run 'git status -s'};
    }
    else {
        my @status = split /\n/, $stdout;
        ...;
    }

The call returns immediately and the Git command runs in its own process.
All output produced by Git is redirected to a [File::Temp](https://metacpan.org/pod/File%3A%3ATemp) temporary file.

If there's already a Git command running for this object you have to run
`get` or `stdout` first or `run` will croak.

`run` returns itself to allow chaining.

    # Waits on the clone and dies if an error happens
    Git::Background->new->run('clone', $url, $dir)->get;

`Proc::Background` is run with `autoterminate` set, which will kill the
Git process if the object is destroyed.

## get

Waits for the running Git process to finish. Throws an exception if `run`
was never called. In scalar context, `get` returns the output the Git
process produced on stdout, and inlist context it returns the stdout, stderr
and exit code of the Git process.

    my $git = Git::Background->new($dir);
    # dies, because no run was called
    my $stdout = $git->get;

    my $git = Git::Background->new($dir);
    $git->run('status', '-s');
    # waits for 'git status -s' to finish
    my ($stdout, $stderr, $rc) = $git->get;

`wait` throws an exception if I cannot read the output of Git or if the Git
process was terminated by a signal.

Throws a [Git::Background::Exception](https://metacpan.org/pod/Git%3A%3ABackground%3A%3AException) exception if Git terminated with an
exit code of 128 or 129 and, as long as fatal is true, for any other
non-zero return code. Fatal defaults to true and can be changed by the call
to `new` and `run`.

    my $git = Git::Background->new( { fatal => 0 } );

    # dies, because Git will exit with exit code 129
    $git->run('--unknown-option')->get;

## is\_ready

Returns something false if the Git command is still running, otherwise
something true. Throws an exception if nothing was `run` yet.

## stdout

Calls `get`, then returns either a list or a scalar of all the lines written
by the Git command to stdout.

Because this command calls `get`, the same exceptions can be thrown.

## version( \[ARGS\] )

Returns the version of the used Git binary or undef if no Git command was
found. This call uses the same, optional, argument hash as `run`. The call
is wrapped in an eval which ensures that this method never throws an error
and can be used to check if a Git is available.

    my $version = Git::Background->version;
    if ( !defined $version ) {
        say "No Git binary found.";
    }
    else {
        say "You have Git version $version";
    }

`version` can be run on the class or an object.

    my $git = Git::Background->new( { git => '/opt/git/bin/git' } );
    say 'You have Git version ', $git->version;

# EXAMPLES

## Example 1 Clone a repository

Cloning a repository is a bit special as it's the only Git command that
cannot be run in a workspace and the target directory must not exist.

There are two ways to use a `Git::Background` object without the workspace
directoy:

    my $git = Git::Background->new;
    $git->run('clone', $url, $dir);
    $git->get;

    # later, use a new object for working with the cloned repository
    $git = Git::Background->new($dir);
    $git->run('status', '-s');
    my @stdout = $git->stdout;

Alternatively you can overwrite the directory for the call to clone:

    my $git = Git::Background->new($dir);
    $git->run('clone', $url, $dir, { dir => undef});
    $git->get;

    # then use the same object for working with the cloned repository
    $git->run('status', '-s');
    my @dstdout = $git->stdout;

# SEE ALSO

[Git::Repository](https://metacpan.org/pod/Git%3A%3ARepository), [Git::Wrapper](https://metacpan.org/pod/Git%3A%3AWrapper)

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/skirmess/Git-Background/issues](https://github.com/skirmess/Git-Background/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/skirmess/Git-Background](https://github.com/skirmess/Git-Background)

    git clone https://github.com/skirmess/Git-Background.git

# AUTHOR

Sven Kirmess <sven.kirmess@kzone.ch>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2021 by Sven Kirmess.

This is free software, licensed under:

    The (two-clause) FreeBSD License
