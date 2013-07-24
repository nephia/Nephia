package Voson::Chain;
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    bless [], $class;
}

sub append {
    my $self = shift;
    push @$self, $self->_bless_action(@_);
}

sub prepend {
    my $self = shift;
    unshift @$self, $self->_bless_action(@_);
}

sub before {
    my ($self, $search, $name, $code) = @_;
    $self->_inject($search, $name, $code);
}

sub after {
    my ($self, $search, $name, $code) = @_;
    $self->_inject($search, $name, $code, 1);
}

sub _inject {
    my ($self, $search, $name, $code, $after) = @_;
    $after ||= 0;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    croak "duplicate name $name" if $self->index($name);
    my $index  = $self->index($search);
    $index += $after;
    my $action = $self->_bless_action($name, $code);
    splice @$self, $index, 0, $action;
}

sub _validate_action_opts {
    my ($self, $name, $code) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    croak "name is undefined" unless $name;
    croak "code is undefined" unless $code;
    croak "illegal name $name" if ref($name);
    return ( $self->_normalize_name($name), $code );
}

sub _normalize_name {
    my ($self, $name) = @_;;
    return "Voson::Chain::Item::$name";
}

sub _bless_action {
    my ($self, @opts) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    croak "odd number parameters are specified" unless scalar @opts % 2 == 0;
    my @rtn;
    while (@opts) {
        my $name = shift(@opts);
        my $code = shift(@opts);
         ($name, $code) = $self->_validate_action_opts($name, $code);
        push @rtn, bless($code, $name);
    }
    return wantarray ? @rtn : $rtn[0];
}

sub index {
    my ($self, $name) = @_;
    for my $i (0 .. $#{$self}) {
        return $i if $self->[$i]->isa($self->_normalize_name($name));
    }
}

sub as_array {
    my $self = shift;
    return @$self;
}

1;
