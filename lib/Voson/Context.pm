package Voson::Context;
use strict;
use warnings;

sub new {
    my ($class, %opts) = @_;
    return bless {%opts}, $class;
}

sub get {
    my ($self, $key) = @_;
    return $self->{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    return $self->{$key} = $val;
}

sub delete {
    my ($self, $key) = @_;
    delete $self->{$key};
    return;
}

1;

__END__

=encoding utf-8

=head1 NAME

Voson::Context - Context Class for Voson

=head1 DESCRIPTION

HASHREF plus alpha

=head1 SYNOPSIS

    my $c = Voson::Context->new( foo => 'bar', hoge => [qw/fuga piyo/] );
    $c->get('foo');           ### 'bar'
    $c->get('hoge');          ### ['fuga', 'piyo'];
    $c->set(fizzbuzz => sub { 
        my $x = ''; 
        $x .= 'fizz' if ! $x % 3; 
        $x .= 'buzz' if ! $x % 5; 
        $x .= $_[0] unless $x; 
        return $x;
    });
    $c->delete('hoge');
    $c->get('hoge')           ### undef
    $c->get('fizzbuzz')->(12) ### 'fizz'

=head1 METHODS

=head2 new

    my $c = Voson::Context->new( %items );

Instantiate Voson::Context. Then, store specified items.

=head2 get

    my $item = $c->get( $name );

Fetch specified item that stored.

=head2 set

    $c->set( $name => $value );

Store specified item.

=head2 delete

    $c->delete( $name );

Delete a specified item.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

