use strict;
use warnings;
use Test::More;
use Test::Exception;
use Voson::Plugin;
use Voson::Core;

{
    package Voson::Plugin::TestAlpha;
    use parent 'Voson::Plugin';
    sub exports { qw/ one / };
    sub one     { sub () { 1 } };
}
{
    package Voson::Plugin::TestBeta;
    use parent 'Voson::Plugin';
    sub needs   { qw/ TestAlpha / };
    sub exports { qw/ incr / };
    sub incr    { 
        sub ($) { 
            my $num = $_[0];
            $num ? ++$num : one();
        }; 
    };
}
{
    package Voson::Plugin::TestSeta;
    use parent 'Voson::Plugin';
    sub requires { qw/one/ };
    sub two {
        sub ($) { one() + 1 };
    }
}
    
subtest basal => sub {
    my $x = Voson::Plugin->new;
    isa_ok $x, 'Voson::Plugin';
    is $x->exports, undef, 'not export anything';
};
    
subtest needs_failure => sub {
    throws_ok(
        sub{Voson::Core->new(plugins => [qw/TestBeta/])}, 
        qr/Voson::Plugin::TestBeta needs Voson::Plugin::TestAlpha, you have to load Voson::Plugin::TestAlpha first/
    );
};

subtest needs_ok => sub {
    my $v;
    lives_ok(sub{$v = Voson::Core->new(plugins => [qw/TestAlpha TestBeta/])}, 'no error when loaded a plugin that needs other plugin');
    $v->export_dsl;
    is $v->dsl('one')->(), 1;
    is $v->dsl('incr')->(2), 3;
};

subtest requires_failure => sub {
    throws_ok(
        sub { Voson::Core->new(plugins => [qw/TestSeta/]) },
        qr/Voson::Plugin::TestSeta requires one DSL, you have to load some plugin that provides one DSL/
    );
};

done_testing;
