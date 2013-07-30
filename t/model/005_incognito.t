use strict;
use warnings;
use Test::More;
use Voson::Incognito;
use t::Util 'mock_env';

is(
    Voson::Incognito->_incognito_namespace('Foo'), 
    'Voson::Incognito::Foo::'.$$, 
    'incognito namespace'
);

Voson::Incognito->incognito(app => sub { [200, [], 'Foo'] });
Voson::Incognito->incognito(caller => 'Funny', app => sub { [200, [], 'Bar'] });

my $x = Voson::Incognito->unmask;
my $y = Voson::Incognito->unmask('Funny');

isa_ok $x, 'Voson::Core';
isa_ok $y, 'Voson::Core';

is_deeply( $x->run->(mock_env), [200, [], ['Foo']] );
is_deeply( $y->run->(mock_env), [200, [], ['Bar']] );

done_testing;
