use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;

my $v = Voson::Core->new(
    plugins => [
        'View::MicroTemplate' => { 
            include_path => [File::Spec->catdir(qw/t psgi tmpl/)],
        }, 
        'JSON',
        'ResponseHandler',
        'Dispatch',
    ],
    app => sub {
        get('/json' => sub {+{foo => 'bar'}});
        get('/html' => sub {+{name => 'html', template => 'foo.html'}});
        get('/array' => sub {[200, [], 'foobar']});
        get('/scalar' => sub {'scalar!'});
    },
);

subtest json => sub {
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/json');
        is $res->content, '{"foo":"bar"}', 'output JSON';
    };
};

subtest html => sub {
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/html');
        is $res->content, 'Hello, html!'."\n", 'output HTML';
    };
};

subtest array => sub {
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/array');
        is $res->content, 'foobar', 'output ARRAY';
    };
};

subtest scalar => sub {
    test_psgi $v->run, sub {
        my $cb = shift;
        my $res = $cb->(GET '/scalar');
        is $res->content, 'scalar!', 'output SCALAR';
    };
};

done_testing;
