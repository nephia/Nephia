package Voson::Plugin::Basic;
use strict;
use warnings;
use parent 'Voson::Plugin';

sub exports {
    qw/req param cookie/;
}

sub req {
    my ($app, $context) = @_;
    return sub () {$context->{req}};
}

sub param {
    my ($app, $context) = @_;
    return sub (;$) {$_[0] ? $context->{req}->param($_[0]) : $context->{req}->parameters};
};

sub cookie {
    my $context = shift;
    return sub (;$) {$_[0] ? $context->{req}->cookies->{$_[0]} : $context->{req}->cookies};
};

1;
