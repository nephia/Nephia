use strict;
use warnings;
use Test::More;
use Voson::Plugin;
use Voson::Core;

my $x = Voson::Plugin->new;
isa_ok $x, 'Voson::Plugin';
is $x->exports, undef, 'not export anything';

done_testing;
