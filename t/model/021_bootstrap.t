use strict;
use warnings;
use Test::More;

{
    package 
        Oreore;
    use Nephia;
};

can_ok 'Oreore', qw/bootstrap/;
ok( Oreore->can('req'));

Oreore->bootstrap;
can_ok 'Oreore', qw/req/;

done_testing;
