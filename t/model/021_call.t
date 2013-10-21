use strict;
use warnings;
use Test::More;
use Nephia::Core;
use Nephia::Request;
use Nephia::Context;
use t::Util 'mock_env';

my $env = mock_env;
my $req = Nephia::Request->new($env);
my $context = Nephia::Context->new(req => $req, config => {});

{
    package 
        MyApp::C::Root;
    sub index {
        my $c    = shift;
        my $name = $c->param('name');
        [200, [], ["name = $name"]];
    }
};

{
    package 
        Oreore::App::Root;
    sub index {
        my $c    = shift;
        my $name = $c->param('name');
        [200, [], ["$name is cool"]];
    }
}

subtest normal => sub {
    my $v = Nephia::Core->new(caller => 'MyApp');
    my $code = $v->call('C::Root#index');
    is_deeply( $code->($context), [200, [], ['name = ytnobody']] );
};

subtest absolute => sub {
    my $v = Nephia::Core->new(caller => 'MyApp');
    my $code = $v->call('+Oreore::App::Root#index');
    is_deeply( $code->($context), [200, [], ['ytnobody is cool']] );
};

done_testing;
