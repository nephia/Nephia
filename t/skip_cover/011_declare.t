use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

{
    package Voson::TestApp;
    use Voson plugins => [qw/Dispatch/];
    app {
         get '/' => sub {
             [200, [], 'Hello'];
         };
         get '/foo' => sub {
             [200, [], 'Foo'];
         };
    };
}

my $app = Voson::TestApp->run;

test_psgi $app, sub {
    my $cb = shift;
    my $res;
    $res = $cb->(GET '/');
    is $res->content, 'Hello';
    $res = $cb->(GET '/foo');
    is $res->content, 'Foo';
};
done_testing;
