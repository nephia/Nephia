package Voson::Plugin;
use strict;
use warnings;
use Carp;

sub new {
    my ($class, %opts) = @_;
    $class->_check_needs($opts{app});
    $class->_check_requires($opts{app});
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

sub requires { return () }

sub _check_needs {
    my ($class, $app) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    for my $need ($class->needs) {
        $need = $need =~ /^Voson::Plugin/ ? $need : "Voson::Plugin::$need";
        croak "$class needs $need, you have to load $need first" unless $app->loaded_plugins->index($need) > 0;
    }
}

sub _check_requires {
    my ($class, $app) = @_;
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    for my $requires ($class->requires) {
        croak "$class requires $requires DSL, you have to load some plugin that provides $requires DSL" unless $app->{DSL}{$requires};
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

=head2 requires

    sub requires {
        return qw/dsl_a dsl_b/;
    }

Specifier for required DSLs.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<Voson::Plugin>

=cut

