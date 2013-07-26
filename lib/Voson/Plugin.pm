package Voson::Plugin;
use strict;
use warnings;
use Carp;

sub new {
    my ($class, %opts) = @_;
    warn 'do not use Voson::Plugin directly' if $class eq 'Voson::Plugin';
    $class->check_needs($opts{app});
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

sub needs { return () }

sub check_needs {
    my ($class, $app) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    for my $need ($class->needs) {
        $need = $need =~ /^Voson::Plugin/ ? $need : "Voson::Plugin::$need";
        croak "$class needs $need, you have to load $need first" unless $app->loaded_plugins->index($need) > 0;
    }
}
1;
