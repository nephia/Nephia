package Voson::Plugin;
use strict;
use warnings;

sub new {
    my ($class, %opts) = @_;
    warn 'do not use Voson::Plugin directly' if $class eq 'Voson::Plugin';
    return bless {%opts}, $class;
}

sub app {
    my $self = shift;
    return $self->{app};
}

sub exports {
    my $self = shift;
    warn 'do not use Voson::Plugin directly' if ref($self) eq 'Voson::Plugin';
    return ();
}

1;
