package Voson::Plugin::ResponseHandler;
use strict;
use warnings;
use parent 'Voson::Plugin';
use Voson::Response;

sub requires { qw/ json_res render / };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->app->{response_handler} = $opts{handler};
    $self->app->{response_handler}{HASH}   ||= $self->can('_hash_handler');
    $self->app->{response_handler}{ARRAY}  ||= $self->can('_array_handler');
    $self->app->{response_handler}{SCALAR} ||= $self->can('_scalar_handler');
    my $app = $self->app;
    $app->action_chain->after('Core', ResponseHandler => $self->can('_response_handler'));
    return $self;
}

sub _response_handler {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    my $type = ref($res) || 'SCALAR';
    if ($app->{response_handler}{$type}) {
        $app->{response_handler}{$type}->($app, $context);
    }
    return $context;
}

sub _hash_handler {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    $res->{template} ?
        $context->set('res' => Voson::Response->new(200, ['Content-Type' => 'text/html; charset=UTF-8'], $app->dsl('render')->(delete($res->{template}), $res)) ) :
        $app->dsl('json_res')->($res)
    ;
}

sub _array_handler {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    $context->set('res' => Voson::Response->new(@$res));
}

sub _scalar_handler {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    $context->set('res' => Voson::Response->new(200, [], $res));
}

1;
