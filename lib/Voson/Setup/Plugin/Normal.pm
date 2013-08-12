package Voson::Setup::Plugin::Normal;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin::Minimal';
use File::Spec;

sub fix_setup {
    my $self = shift;
    $self->SUPER::fix_setup;
    my $chain = $self->setup->action_chain;
    $chain->delete('CreateClass');
    $chain->after('CreateProject', CreateClass => \&create_class);
    $chain->append(CreateTemplate => \&create_template);
}

sub create_class {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('MyClass.pm');
    $setup->spew($setup->classfile, $setup->process_template($data));
    return $context;
}

sub create_template {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('index.html');
    $setup->spew('view', 'index.html', $setup->process_template($data));
}

1;

__DATA__

@@ MyClass.pm
package {{$c->appname}};
use strict;
use warnings;
use File::Spec;

our $VERSION = 0.01;

use Voson plugins => [
    'JSON',
    'View::MicroTemplate' => {
        include_path => [File::Spec->catdir('view')],
    },
    'ResponseHandler',
    'Dispatch',
];

app {
    get '/' => sub {
        {template => 'index.html', appname => '{{$c->appname}}'};
    };

    get '/simple' => sub { 
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

@@ index.html

? my $arg = shift;
<html>
<head>
<title><?= $arg->{appname} ?> - powered by Voson</title>
<body>
<h1><?= $arg->{appname} ?> - powered by Voson</h1>
</body>
</html>


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

=item L<Voson::Plugin::View::MicroTemplate>

=item L<Voson::Plugin::ResponseHandler>

=item L<Voson::Plugin::Dispatch>

=back

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

