use strict;
use warnings;
use Test::More;
use Voson::Context;

subtest normal => sub {
    my $c = Voson::Context->new(foo => "bar");
    isa_ok $c, 'Voson::Context';
    can_ok $c, qw/get set delete/;
    is $c->get('foo'), 'bar', 'foo is bar';
    $c->set(hoge => 'fuga');
    is $c->get('hoge'), 'fuga', 'hoge is fuga';
    $c->delete('hoge');
    is $c->get('hoge'), undef, 'hoge was deleted';
};

done_testing;
