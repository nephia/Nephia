use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;

subtest normal => sub {
    my $v = Voson::Core->new(
        plugins => [HashHandler => {}],
        app => sub { +{foo => 'bar'} },
    );
    
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, "{\n  'foo' => 'bar'\n}\n", 'default output with Dumper';
    };
};

subtest with_handler => sub {
    use JSON;
    my $handler = sub {[200, ['Content-Type' => 'application/json'], JSON->new->utf8->encode(shift)]};

    my $v = Voson::Core->new(
        plugins => [HashHandler => {handler => $handler}],
        app => sub { +{foo => 'bar'} },
    );
    
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, '{"foo":"bar"}', 'output with json';
    };
};

done_testing;
