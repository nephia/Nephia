use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;

subtest normal => sub {
    my $v = Voson::Core->new(
        plugins => ['JSON'],
        app => sub { json_res({foo => 'bar'}) },
    );
    
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, '{"foo":"bar"}', 'output with JSON';
    };
};

done_testing;
