package Voson::Context;
use strict;
use warnings;

sub new {
    my ($class, %opts) = @_;
    return bless {%opts}, $class;
}

sub get {
    my ($self, $key) = @_;
    return $self->{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    return $self->{$key} = $val;
}

sub delete {
    my ($self, $key) = @_;
    delete $self->{$key};
    return;
}

1;
