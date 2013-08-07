package Voson::Setup::Plugin::Normal;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin::Minimal';

sub fix_setup {
    my $self = shift;
    $self->SUPER::fix_setup;
    my $chain = $self->setup->action_chain;
    $chain->delete('CreateClass');
    $chain->after('CreateProject', CreateClass => \&create_class);
}

sub create_class {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('MyClass.pm');
    $setup->spew($setup->classfile, $setup->process_template($data));
    return $context;
}

1;

__DATA__

@@ MyClass.pm
package {{$c->appname}};
use strict;
use warnings;

our $VERSION = 0.01;

use Voson plugins => [
    'JSON',
    'HashHandler' => { handler => 'json_res' },
    'Dispatch',
];

app {
    get '/' => sub { 
        [200, [], 'Hello, World!']; 
    };

    get '/json' => sub { 
        {message => 'Hello, JSON World'};
    };
};

1;

:::encoding utf-8

:::head1 NAME

{{$c->appname}} - Web Application that powered by Voson

:::head1 DESCRIPTION

An web application

:::head1 SYNOPSIS

    use {{$c->appname}};
    {{$c->appname}}->run;

:::head1 AUTHOR

clever people

:::head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

:::head1 SEE ALSO

L<Voson>

:::cut

__END__

=encoding utf-8

=head1 NAME

Voson::Setup::Plugin::Normal - Normal setup of Voson

=head1 DESCRIPTION

Normal setup plugin.

=head1 SYNOPSIS

    $ voson-setup YourApp

=head1 ENABLED PLUGINS

=over 4

=item L<Voson::Plugin::JSON>

=item L<Voson::Plugin::HashHandler> (option is {handler => 'json_res'})

=item L<Voson::Plugin::Dispatch>

=back

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

