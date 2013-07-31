use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;
use utf8;
use Encode;

subtest normal => sub {
    my $v = Voson::Core->new(
        plugins => ['JSON'],
        app => sub { json_res({foo => 'ばー'}) },
    );
    
    test_psgi $v->run, sub {
        my $cb     = shift;
        my $res    = $cb->(GET '/');
        my $expect = Encode::encode_utf8('{"foo":"ばー"}');
        is $res->content, $expect, 'output with JSON';
    };
};

done_testing;
