use strict;
use warnings;
use Test::More;
use Voson::Context;

subtest normal => sub {
    my $context = Voson::Context->new(foo => "bar");
    isa_ok $context, 'Voson::Context';
    can_ok $context, qw/get set delete/;
    is $context->get('foo'), 'bar', 'foo is bar';
    $context->set(hoge => 'fuga');
    is $context->get('hoge'), 'fuga', 'hoge is fuga';
    $context->delete('hoge');
    is $context->get('hoge'), undef, 'hoge was deleted';
};

done_testing;
