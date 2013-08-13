package Voson::Setup::Plugin::Normal;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin::Minimal';
use File::Spec;

sub bundle {
    qw/ Assets::Bootstrap Assets::JQuery /;
}

sub fix_setup {
    my $self = shift;
    $self->SUPER::fix_setup;
    my $chain = $self->setup->action_chain;
    $chain->delete('CreateClass');
    $chain->delete('CreatePSGI');
    $chain->after('CreateProject', CreateClass => \&create_class);
    $chain->after('CreateProject', CreatePSGI => \&create_psgi);
    $chain->append(CreateTemplate => \&create_template);
}

sub create_class {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('MyClass.pm');
    $setup->spew($setup->classfile, $setup->process_template($data));
    return $context;
}

sub create_psgi {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('app.psgi');
    $setup->spew('app.psgi', $setup->process_template($data));
    return $context;
}

sub create_template {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('index.html');
    $setup->spew('view', 'index.html', $setup->meta_tmpl->process($setup->process_template($data)));
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

@@ app.psgi
use strict;
use warnings;
use Plack::Builder;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__), 'lib'), 
);
use {{$c->appname}};

my $app = {{$c->appname}}->run;
my $root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__)));

builder {
    enable 'Static', root => $root, path => qr{^/static/};
    $app;
};

@@ index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>[= appname =] - powered by Voson</title>
  <link rel="stylesheet" href="/static/bootstrap/css/bootstrap.min.css">
</head>
<body>
  <div class="navbar navbar-fixed-top">
    <div class="navbar-inner">
      <div class="container">
        <a class="brand" href="/">[= appname =]</a>
      </div>
    </div>
  </div>
  <div class="container">
    <div class="hero-unit">
      <h1>[= appname =]</h1>
      <p>An web-application that is empowered by Voson</p>
    </div>
  </div>
  <script src="/static/js/jquery.min.js"></script>
  <script src="/static/bootstrap/js/bootstrap.min.js"></script>
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

