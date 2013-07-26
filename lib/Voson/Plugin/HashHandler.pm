package Voson::Plugin::HashHandler;
use strict;
use warnings;
use parent 'Voson::Plugin';
use Data::Dumper;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->app->{hash_handler} = $opts{handler} || $self->can('_default_handler');
    my $app = $self->app;
    $app->action_chain->after('Core', HashHandler => $self->can('handle_hash'));
    return $self;
}

sub handle_hash {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    if (ref($res) eq 'HASH') {
        my $handler = $app->{hash_handler};
        $handler = $app->{dsl}{$handler} unless ref($handler) eq 'CODE';
        $res = $handler->($res);
        $context->set(res => $res);
    }
    return $context;
}

sub _default_handler {
    local $Data::Dumper::Terse = 1;
    my $res = shift;
    warn 'Plugin::HashHandler wants "handler" attr';
    return [200, [], Dumper($res)];
}

1;
