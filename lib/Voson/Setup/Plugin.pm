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

=encoding utf-8

=head1 NAME

Voson::Setup::Plugin - Base class of plugin for Voson::Setup

=head1 DESCRIPTION

If you want to create a new plugin for Voson::Setup, inherit this class.

=head1 SYNOPSIS

    package Voson::Setup::Plugin::MyWay;
    use parent 'Voson::Setup::Plugin';
    
    sub fix_setup {
        my $self = shift;
        $self->SUPER::fix_setup;
        my $setup = $self->setup;
        my $chain = $setup->chain;
        ### append feature here
        ...
    }

=head1 METHODS

=head2 new

Constructor.

=head2 setup

Returns a Voson::Setup instance.

=head2 fix_setup

You have to override this method if you want to append some action to Voson::Setup.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

