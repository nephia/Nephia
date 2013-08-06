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

=encoding utf-8

=head1 NAME

Voson::Incognito - A mechanism that conceal a Voson instance into namespace

=head1 DESCRIPTION

A concealer for Voson.

=head1 SYNOPSIS

    Voson::Incognito->incognito( caller => 'MyApp', plugins => [...], app => sub {...} );
    my $voson_instance = Voson::Incognito->unmask('MyApp');
    $voson_instance->run;

=head1 METHODS

=head2 incognito

    Voson::Incognito->incognito( %opts );

Conceal a Voson instance into namespace. See L<Voson::Core> about option.

=head2 unmask

    my $instance = Voson::Incognito->unmask( $appname );

Returns a Voson instance that has a specified appname.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

