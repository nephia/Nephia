use strict;
use warnings;
use Test::More;
use Voson::Chain;

my $chain = Voson::Chain->new;
isa_ok $chain, 'Voson::Chain';

$chain->append(foo => sub {'bar'}, hoge => sub{'fuga'});
isa_ok $chain->[ $chain->index($_) ], "Voson::Chain::Item::$_" for qw/foo hoge/;

$chain->prepend(piyo => sub {'poo'});
isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
isa_ok $chain->[1], 'Voson::Chain::Item::foo';
isa_ok $chain->[2], 'Voson::Chain::Item::hoge';

$chain->after('foo', x => sub {123});
isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
isa_ok $chain->[1], 'Voson::Chain::Item::foo';
isa_ok $chain->[2], 'Voson::Chain::Item::x';
isa_ok $chain->[3], 'Voson::Chain::Item::hoge';

$chain->before('hoge', y => sub {321});
isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
isa_ok $chain->[1], 'Voson::Chain::Item::foo';
isa_ok $chain->[2], 'Voson::Chain::Item::x';
isa_ok $chain->[3], 'Voson::Chain::Item::y';
isa_ok $chain->[4], 'Voson::Chain::Item::hoge';

is join(',', map {$_->()} $chain->as_array), 'poo,bar,123,321,fuga', 'as_array';

done_testing;
