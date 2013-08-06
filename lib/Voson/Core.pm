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
    $opts{caller}       ||= caller();
    $opts{plugins}      ||= [];
    $opts{action_chain}   = Voson::Chain->new(namespace => 'Voson::Action');
    $opts{filter_chain}   = Voson::Chain->new(namespace => 'Voson::Filter');
    $opts{loaded_plugins} = Voson::Chain->new(namespace => 'Voson::Plugin', name_normalize => 0);
    $opts{dsl}            = {};
    my $self = bless {%opts}, $class;
    $self->action_chain->append(Core => $class->can('_action'));
    $self->_load_plugins;
    return $self;
}

sub export_dsl {
    my $self = shift; 
    my $dummy_context = Voson::Context->new;
    $self->_load_dsl($dummy_context);
    my $class = $self->caller_class;
    no strict   qw/refs subs/;
    no warnings qw/redefine/;
    *{$class.'::run'} = sub ()  { $self->run };
    *{$class.'::app'} = sub (&) {
        my $app = shift;
        $self->{app} = $app;
    };
}

sub _load_plugins {
    my $self = shift;
    my @plugins = (qw/Basic Cookie/, @{$self->{plugins}});
    while ($plugins[0]) {
        my $plugin_class = 'Voson::Plugin::'. shift(@plugins);
        my $conf = {};
        if ($plugins[0]) {
            $conf = shift(@plugins) if ref($plugins[0]) eq 'HASH';
        }
        $self->loaded_plugins->append($self->_load_plugin($plugin_class, $conf));
    }
}

sub loaded_plugins {
    my $self = shift;
    return wantarray ? $self->{loaded_plugins}->as_array : $self->{loaded_plugins};
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

sub _action {
    my ($self, $context) = @_;
    $context->set(res => $self->app->($context));
    return $context;
}

sub dsl {
    my ($self, $key) = @_;
    return $key ? $self->{dsl}{$key} : $self->{dsl};
}

sub _load_dsl {
    my ($self, $context) = @_;
    my $class = $self->caller_class;
    no strict   qw/refs subs/;
    no warnings qw/redefine/;
    for my $plugin ( $self->loaded_plugins->as_array ) {
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
        $self->_load_dsl($context);
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

__END__

=encoding utf-8

=head1 NAME

Voson::Core - Core Class of Voson

=head1 DESCRIPTION

Core Class of Voson, Object Oriented Interface Included.

=head1 SYNOPSIS

    my $v = Voson::Core->new( 
        appname => 'YourApp::Web',
        plugins => ['JSON', 'HashHandler' => { ... } ],
    );
    $v->app(sub {
        my $req = req();
        [200, [], 'Hello, World'];
    });
    $v->run;

=head1 ATTRIBUTES

=head2 appname

Your Application Name. Default is caller class.

=head2 plugins

Voson plugins you want to load.

=head2 app

Application as coderef.

=head1 METHODS

=head2 action_chain

Returns a Voson::Chain object for specifying order of actions.

=head2 filter_chain

Returns a Voson::Chain object for specifying order of filters.

=head2 caller_class

Returns caller class name as string.

=head2 app

Accessor method for application coderef (ignore plugins, actions, and filters).

=head2 export_dsl

Export DSL (see dsl method) into caller namespace.

=head2 loaded_plugins

Returns objects of loaded plugins.

=head2 dsl

Returns pairs of name and coderef of DSL as hashref.

=head2 run

Returns an application as coderef (include plugins, actions, and filters).

=head1 HOOK MECHANISM

Voson::Core includes hook mechanism itself. These provided as L<Voson::Chain> object.

Voson::Core has action_chain and filter_chain. Look following ASCII Art Image.

    
        [HTTP Request]                              [HTTP Response]
           |                                                   A
           |                                                   |
           v                                                   |
       /------------------------------------\    /---------------------\
       |                                    |    |                     |
       |           Voson::Context           |--->|  Voson::Response    |
       |                                    |    |                     |
       \------------------------------------/    \---------------------/
           |  A    |  A     |   A    |  A           |           A
           |  |    |  |     |   |    |  |        [Content]      |
       /---|--|----|--|-----|---|----|--|--\   /----|-----------|--------\
       |   |  |    |  |     |   |    |  |  |   |    |           |        |
       |   |  |    |  |     |   |    |  |  |   |    |           |        |
       |   v  |    v  |     v   |    v  |  |   |    v           |        |
       |  /~\ |   /~\ |   /~~~\ |   /~\ |  |   |   /~\    /~\   |        |
       |  |A| |   |A| |   | A | |   |A| |  |   |   |F|    |F|   |        |
       |  |c|-/   |c|-/   | p |-/   |c|-/  |   |   |i|--->|i|---+        |
       |  |t|     |t|     | p.|     |t|    |   |   |l|    |l|            |
       |  |i|     |i|     |   |     |i|    |   |   |t|    |t|            |
       |  |o|     |o|     \---/     |o|    |   |   |e|    |e|            |
       |  |n|     |n|               |n|    |   |   |r|    |r|            |
       |  | |     | |               | |    |   |   | |    | |            |
       |  |1|     |2|               |3|    |   |   |1|    |2|            |
       |  \_/     \_/               \_/    |   |   \_/    \_/            |
       |                                   |   |                         |
       | action_chain                      |   | filter_chain            |
       \-----------------------------------/   \-------------------------/
    

Actions (and App) in action_chain affects context. Then, Voson::Response object creates from context. 

Afterwords, filters in filter_chain affects content string in Voson::Response.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<Voson::Chain>

=cut
