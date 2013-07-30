use strict;
use warnings;
use Test::More;
use Voson::Core;
use t::Util 'mock_env';

my $env = mock_env;

my $app = sub {
    my ($self, $context) = @_;
    [200, [], 'Hello, World!'];
};

subtest normal => sub {
    my $v = Voson::Core->new(app => $app);

    isa_ok $v, 'Voson::Core';
    is $v->caller_class, __PACKAGE__;
    isa_ok $v->loaded_plugins, 'Voson::Chain';
    isa_ok $v->action_chain, 'Voson::Chain';
    isa_ok $v->filter_chain, 'Voson::Chain';
    is $v->dsl, $v->{dsl};
    is_deeply [ map {ref($_)} $v->loaded_plugins->as_array ], [qw[Voson::Plugin::Basic Voson::Plugin::Cookie]], 'Basic and Cookie plugins loaded';
    is $v->app, $app;

    my $psgi = $v->run;
    isa_ok $psgi, 'CODE';

    $v->export_dsl;
    can_ok __PACKAGE__, qw/run app req param/;

    isa_ok $v->run, 'CODE';
    my $res = $v->run->($env);
    isa_ok $res, 'ARRAY';
    is_deeply $res, [200, [], ['Hello, World!']];
};

subtest caller_class => sub {
    my $v = Voson::Core->new(app => $app, caller => 'MyApp');
    isa_ok $v, 'Voson::Core';
    is $v->caller_class, 'MyApp';
};

subtest load_plugin => sub {
    {
        package Voson::Plugin::Test;
        use parent 'Voson::Plugin';
        sub new {
            my ($class, %opts) = @_;
            my $self = $class->SUPER::new(%opts);
            $self->app->filter_chain->append(slate => sub {
                my $content = shift;
                my $world = $opts{world};
                $content =~ s/World/$world/g;
                return $content;
            });
            return $self;
        };
    };

    my $v = Voson::Core->new(plugins => [Test => {world => 'MyHome'}], app => $app);
    isa_ok $v, 'Voson::Core';
    is_deeply [ map {ref($_)} $v->loaded_plugins->as_array ], [qw[Voson::Plugin::Basic Voson::Plugin::Cookie Voson::Plugin::Test]], 'plugins';
};

done_testing;
