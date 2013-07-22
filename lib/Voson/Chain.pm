package Voson::Chain;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless [], $class;
}

sub append {
    my $self = shift;
    push @$self, @_;
}

sub prepend {
    my $self = shift;
    unshift @$self, @_;
}

sub as_array {
    my $self = shift;
    return @$self;
}

1;
