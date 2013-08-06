package Voson::Plugin::Basic;
use strict;
use warnings;
use parent 'Voson::Plugin';

sub exports {
    qw/req param/;
}

sub req {
    my ($self, $context) = @_;
    return sub () {$context->{req}};
}

sub param {
    my ($self, $context) = @_;
    return sub (;$) {$_[0] ? $context->{req}->param($_[0]) : $context->{req}->parameters};
}

1;

__END__

=encoding utf-8

=head1 NAME

Voson::Plugin::Basic - A Voson plugin that provides two basic DSL

=head1 DESCRIPTION

This plugin provides req and param DSL for Voson.

=head1 DSL

=head2 req

    app {
        my $req = req; # returns Voson::Request object
        ...
    };

Returns Voson::Request object.

=head2 param

    app {
        my $id     = param('id'); # returns query-parameter that named 'id'
        my $params = param;       # returns query-parameters as hashref
    };

Returns query-parameter.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<Voson::Plugin>

=cut

