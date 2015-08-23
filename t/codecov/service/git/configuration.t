use strict;
use warnings FATAL => 'all';
use utf8;

use Config;
use Cwd qw/abs_path/;
use Cwd::Guard qw/cwd_guard/;
use File::Temp qw/tempdir/;
use File::Which qw/which/;
use Capture::Tiny qw/capture/;

use t::Util;
use Devel::Cover::Report::Codecov::Service::Git;

sub configuration {
    Devel::Cover::Report::Codecov::Service::Git->configuration(@_);
}

if (which 'git') {
    subtest integrated => sub {
        my $dir = tempdir;
        extract_tar('t/data/git.tar.bz2', $dir);
        my $guard = cwd_guard("$dir/git");

        subtest master => sub {
            capture { `git reset --hard master` };

            cmp_deeply
                configuration,
                {
                    branch => 'master',
                    commit => '3713ace1c825f6626e439e3cb72e2ce37f0cd63e',
                };
        };

        subtest HEAD => sub {
            capture { `git checkout HEAD~` };

            cmp_deeply
                configuration,
                {
                    branch => 'master',
                    commit => '8074326f663b7929608b9748ae0728fc3971acca',
                };
        };
    };
}

subtest mock => sub {
    local $ENV{PATH} =
        abs_path('t/data/libexec') . $Config::Config{path_sep} . $ENV{PATH};

    cmp_deeply
        configuration,
        {
            branch => 'master',
            commit => '3713ace1c825f6626e439e3cb72e2ce37f0cd63e',
        };
};

done_testing;
