package Voson::Setup::Plugin;
use strict;
use warnings;

sub new { 
    my ($class, %opts) = @_;
    bless {%opts}, $class;
}

sub setup {
    my $self = shift;
    return $self->{setup};
}

sub fix_setup {
    my ($self) = @_;
}

1;

__END__
