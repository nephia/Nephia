use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Voson::Core;
use utf8;
use Encode;
use File::Spec;

subtest normal => sub {
    my $v = Voson::Core->new(
        plugins => [
            'View::MicroTemplate' => {
                include_path => [File::Spec->catdir(qw/t psgi tmpl/)],
            }, 
        ],
        app => sub { 
            my $content = render('foo.html', {name => 'とんきち'});
            [200, [], $content];
        },
    );
    
    test_psgi $v->run, sub {
        my $cb     = shift;
        my $res    = $cb->(GET '/');
        my $expect = Encode::encode_utf8('Hello, とんきち!'."\n");
        is $res->content, $expect, 'output with template';
    };
};

done_testing;
