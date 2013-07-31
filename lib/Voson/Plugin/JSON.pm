package Voson::Plugin::JSON;
use strict;
use warnings;
use parent 'Voson::Plugin';
use JSON::Tiny ();

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    my $app = $self->app;
    $app->{json_obj} = JSON::Tiny->new;
    return $self;
}

sub exports { qw/json_res encode_json decode_json/ }

sub json_res {
    my ($self, $context) = @_;
    return sub ($) {
        $context->set(res => [
            200, ['Content-Type' => 'applcation/json'], $self->app->{json_obj}->encode($_[0])
        ]);
    };
}

sub encode_json {
    my ($self, $context) = @_;
    return sub ($) {$self->app->{json_obj}->encode($_[0])};
}

sub decode_json {
    my ($self, $context) = @_;
    return sub ($) {$self->app->{json_obj}->decode($_[0])};
}

1;
