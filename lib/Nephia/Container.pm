package Nephia::Container;
use strict;
use warnings;
use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/core/],
);

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;
    my ($class, $method) = $AUTOLOAD =~ /^(.+)::(.+?)$/;
    return if  $method =~ /^[A-Z]/;
    $self->core->dsl($method)->(@_);
}

1;

__END__

=encoding utf-8

=head1 NAME

Nephia::Container - DSL Container class

=head1 SYNOPSIS

In your app class

    package MyApp;
    use Nephia plugins => [...];
    
    my $external_logic = Nephia->call('C::Root#index');
    app($external_logic);
    1;

Then, In your external class

    package MyApp::C::Root;
    sub index {
        my $c = shift; ### <--- it is a Nephia::Container object that contains all DSLs as method.
        my $id = $c->param('id');
        [200, [], ["id is $id"]];
    };
    1;

=head1 DESCRIPTION

It's DSL container, DO NOT INSTANTIATE DIRECTLY.

=head1 METHODS

=head2 core

Returns Nephia::Core object.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut


