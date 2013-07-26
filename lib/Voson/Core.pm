package Voson::Core;
use strict;
use warnings;
use Voson::Request;
use Voson::Response;
use Voson::Context;
use Voson::Chain;
use Scalar::Util ();
use Module::Load ();

sub new {
    my ($class, %opts) = @_;
    $opts{caller}  ||= caller();
    $opts{plugins} ||= [];
    $opts{action_chain} = Voson::Chain->new;
    $opts{filter_chain} = Voson::Chain->new;
    $opts{dsl} = {};
    my $self = bless {%opts}, $class;
    $self->action_chain->append(Core => $class->can('action'));
    $self->{loaded_plugins} = [ $self->load_plugins ];
    return $self;
}

sub export_dsl {
    my $self = shift; 
    my $dummy_context = Voson::Context->new;
    $self->load_dsl($dummy_context);
    my $class = $self->caller_class;
    no strict   qw/refs subs/;
    no warnings qw/redefine/;
    *{$class.'::run'} = sub ()  { $self->run };
    *{$class.'::app'} = sub (&) {
        my $app = shift;
        $self->{app} = $app;
    };
}

sub incognito {
    my ($class, %opts) = @_;
    $opts{caller}  ||= caller();
    my $instance = $class->new(%opts);
    $instance->export_dsl;
    my $namespace = $class->_incognito_namespace;
    {
        no strict 'refs';
        $$namespace = $instance;
    };
    return $namespace;
}

sub unmask {
    my $class = shift;
    no strict 'refs';
    my $namespace = $class->_incognito_namespace;
    return $$namespace;
}

sub _incognito_namespace { 'Voson::Incognito::'. $$ }

sub load_plugins {
    my $self = shift;
    my @plugins = (qw/Basic Cookie/, @{$self->{plugins}});
    my @rtn;
    while ($plugins[0]) {
        my $plugin_class = 'Voson::Plugin::'. shift(@plugins);
        my $conf = {};
        if ($plugins[0]) {
            $conf = shift(@plugins) if ref($plugins[0]) eq 'HASH';
        }
        push @rtn, $self->_load_plugin($plugin_class, $conf);
    }
    return @rtn;
}

sub loaded_plugins {
    my $self = shift;
    return @{$self->{loaded_plugins}};
}

sub _load_plugin {
    my ($self, $plugin, $opts) = @_;
    $opts ||= {};
    Module::Load::load($plugin) unless $plugin->isa('Voson::Plugin');
    my $obj = $plugin->new(app => $self, %$opts);
    return $obj;
}

sub app {
    my $self = shift;
    return $self->{app};
}

sub caller_class {
    my $self = shift;
    return $self->{caller};
}

sub action_chain {
    my $self = shift;
    return $self->{action_chain};
}

sub filter_chain {
    my $self = shift;
    return $self->{filter_chain};
}

sub action {
    my ($self, $context) = @_;
    $context->set(res => $self->app->($context));
    return $context;
}

sub load_dsl {
    my ($self, $context) = @_;
    my $class = $self->caller_class;
    no strict   qw/refs subs/;
    no warnings qw/redefine/;
    for my $plugin ($self->loaded_plugins) {
        for my $dsl ($plugin->exports) {
            *{$class.'::'.$dsl} = $plugin->$dsl($context);
            $self->{dsl}{$dsl} = $plugin->$dsl($context);
        }
    }
}

sub run {
    my $self  = shift;
    my $class = $self->{caller};
    return sub {
        my $env     = shift;
        my $req     = Voson::Request->new($env);
        my $context = Voson::Context->new(req => $req);
        $self->load_dsl($context);
        my $res;
        for my $action ($self->{action_chain}->as_array) {
            ($context, $res) = $action->($self, $context);
            last if $res;
        }
        $res ||= $context->get('res');
        $res = Scalar::Util::blessed($res) ? $res : Voson::Response->new(@$res);
        for my $filter ($self->{filter_chain}->as_array) {
            my $body = ref($res->body) eq 'ARRAY' ? $res->body->[0] : $res->body;
            $res->body($filter->($self, $body));
        }
        return $res->finalize;
    };
}

1;
