package Voson::Plugin::Basic;
use strict;
use warnings;
use parent 'Voson::Plugin';

sub exports {
    qw/req param/;
}

sub req {
    my ($self, $context) = @_;
    return sub () {$context->{req}};
}

sub param {
    my ($self, $context) = @_;
    return sub (;$) {$_[0] ? $context->{req}->param($_[0]) : $context->{req}->parameters};
}

1;
