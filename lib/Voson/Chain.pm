package Voson::Chain;
use strict;
use warnings;
use Carp;
use Scalar::Util ();

sub new {
    my ($class, %opts) = @_;
    $opts{namespace}      = $class.'::Item' unless defined $opts{namespace};
    $opts{name_normalize} = 1 unless defined $opts{name_normalize};
    bless {chain => [], %opts}, $class;
}

sub append {
    my $self = shift;
    $self->_inject('Tail', 1, @_);
}

sub prepend {
    my $self = shift;
    $self->_inject('Head', 0, @_);
}

sub before {
    my ($self, $search, @opts) = @_;
    $self->_inject($search, 0, @opts);
}

sub after {
    my ($self, $search, @opts) = @_;
    $self->_inject($search, 1, @opts);
}

sub size {
    my $self = shift;
    return scalar( @{$self->{chain}} );
}

sub index {
    my ($self, $name) = @_;
    return 0 if $name eq 'Head';
    return $self->size - 1 if $name eq 'Tail';
    for my $i (0 .. $self->size -1) {
        return $i if $self->{chain}[$i]->isa($self->_normalize_name($name));
    }
}

sub as_array {
    my $self = shift;
    return @{$self->{chain}};
}

sub _inject {
    local $Carp::CarpLevel = $Carp::CarpLevel + 2;
    my ($self, $search, $after, @opts) = @_;
    my $index  = $self->index($search);
    $index += $after;
    my @actions = $self->_bless_actions(@opts);
    splice @{$self->{chain}}, $index, 0, @actions;
}

sub _validate_action_opts {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my ($self, $name, $code) = @_;
    croak "name is undefined" unless $name;
    croak "code for $name is undefined" unless $code;
    croak "illegal name $name" if ref($name);
    return ( $self->_normalize_name($name), $code );
}

sub _check_duplicates {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my ($self, @action) = @_;
    for my $name ( map {ref($_)} @action ) {
        croak "name $name is already stored" if $self->index($name);
        croak "duplicate name $name" if scalar( grep {ref($_) eq $name} @action ) > 1;
    }
}

sub _normalize_name {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my ($self, $name) = @_;
    return $name unless $self->{name_normalize};
    my $namespace = $self->{namespace};
    return $namespace.'::'.$name;
}

sub _bless_actions {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my ($self, @opts) = @_;
    my @rtn;
    while (@opts) {
        push @rtn, $self->_shift_as_action(\@opts);
    }
    $self->_check_duplicates(@rtn);
    return wantarray ? @rtn : $rtn[0];
}

sub _shift_as_action {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my ($self, $opts) = @_;
    return shift(@$opts) if Scalar::Util::blessed($opts->[0]);
    my $name = shift(@$opts);
    my $code = shift(@$opts);
    ($name, $code) = $self->_validate_action_opts($name, $code);
    return bless($code, $name);
}

1;
