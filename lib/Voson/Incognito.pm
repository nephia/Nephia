package Voson::Incognito;
use strict;
use warnings;
use Voson::Core;

our $SPACE = {};

sub incognito {
    my ($class, %opts) = @_;
    $opts{caller}  ||= caller();
    my $instance = Voson::Core->new(%opts);
    $instance->export_dsl;
    my $name = $class->_incognito_namespace($instance->caller_class);
    $SPACE->{$name} = $instance;
    return $name;
}

sub unmask {
    my $class = shift;
    my $appname = shift || caller();
    my $name = $class->_incognito_namespace($appname);
    return $SPACE->{$name};
}

sub _incognito_namespace { 
    my ($class, $appname) = @_;
    'Voson::Incognito::'.$appname.'::'. $$
} 

1;
