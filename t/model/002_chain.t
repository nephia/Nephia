use strict;
use warnings;
use Test::More;
use Test::Exception;
use Voson::Chain;

subtest normal => sub {
    my $obj = Voson::Chain->new;
    isa_ok $obj, 'Voson::Chain';
    my $chain = $obj->{chain};
    
    $obj->append(foo => sub {'bar'}, hoge => sub{'fuga'});
    isa_ok $chain->[ $obj->index($_) ], "Voson::Chain::Item::$_" for qw/foo hoge/;
    is $obj->size, 2;
    
    $obj->prepend(piyo => sub {'poo'});
    isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
    isa_ok $chain->[1], 'Voson::Chain::Item::foo';
    isa_ok $chain->[2], 'Voson::Chain::Item::hoge';
    is $obj->size, 3;
    
    $obj->after('foo', x => sub {123});
    isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
    isa_ok $chain->[1], 'Voson::Chain::Item::foo';
    isa_ok $chain->[2], 'Voson::Chain::Item::x';
    isa_ok $chain->[3], 'Voson::Chain::Item::hoge';
    is $obj->size, 4;
    
    $obj->before('hoge', y => sub {321});
    isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
    isa_ok $chain->[1], 'Voson::Chain::Item::foo';
    isa_ok $chain->[2], 'Voson::Chain::Item::x';
    isa_ok $chain->[3], 'Voson::Chain::Item::y';
    isa_ok $chain->[4], 'Voson::Chain::Item::hoge';
    is $obj->size, 5;
    
    is join(',', map {$_->()} $obj->as_array), 'poo,bar,123,321,fuga', 'as_array';

    $obj->delete('foo');
    isa_ok $chain->[0], 'Voson::Chain::Item::piyo';
    isa_ok $chain->[1], 'Voson::Chain::Item::x';
    isa_ok $chain->[2], 'Voson::Chain::Item::y';
    isa_ok $chain->[3], 'Voson::Chain::Item::hoge';
    is $obj->size, 4;
    
};

subtest failure => sub {
    my $obj = Voson::Chain->new;
    throws_ok { $obj->append(foo => sub {'bar'}, 'hoge') } qr/^code for hoge is undefined/;
    dies_ok { $obj->append(foo => sub {'bar'}, 'hoge') } 'say error and die';
    is $obj->size, 0;
};

done_testing;
