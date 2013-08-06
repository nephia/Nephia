package Voson::Plugin;
use strict;
use warnings;
use Carp;

sub new {
    my ($class, %opts) = @_;
    $class->_check_needs($opts{app});
    return bless {%opts}, $class;
}

sub app {
    my $self = shift;
    return $self->{app};
}

sub exports {
    my $self = shift;
    return ();
}

sub needs { return () }

sub _check_needs {
    my ($class, $app) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    for my $need ($class->needs) {
        $need = $need =~ /^Voson::Plugin/ ? $need : "Voson::Plugin::$need";
        croak "$class needs $need, you have to load $need first" unless $app->loaded_plugins->index($need) > 0;
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Voson::Plugin - Base Class of Voson Plugin

=head1 DESCRIPTION

This class is a base class of Voson Plugin. 

If you want to create a plugin for Voson, your plugin have to inherit it.

=head1 METHODS

=head2 app

    my $app = $self->app; 

Returns application-class object.

=head2 exports

    sub exports {
        return qw/exportee of your plugin/;
    }

Specifier for target of exports. 

You have to override it if you want to export some DSL.

=head2 needs

    sub needs {
        return qw/PluginA PluginB/;
    }

Specifier for needs plugins.

You have to override it if you want to export some DSL.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<Voson::Plugin>

=cut

