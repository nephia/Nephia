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
         get '/say' => sub {
             my $message = param('message');
             [200, [], sprintf('You said "%s"', $message)];
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
    $res = $cb->(GET '/say?message=hoge');
    is $res->content, 'You said "hoge"';
};
done_testing;
