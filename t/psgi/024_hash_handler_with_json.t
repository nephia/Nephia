use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;

subtest with_hash_handler => sub {
    my $v = Voson::Core->new(
        plugins => ['JSON', 'HashHandler' => {handler => 'json_res'}],
        app => sub {+{foo => 'bar'}},
    );

    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, '{"foo":"bar"}', 'output JSON with hash_handler';
    };
};

done_testing;
