package Voson::Setup::Plugin::Minimal;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin';
use File::Spec;

sub fix_setup {
    my ($self) = @_;
    $self->setup->action_chain->append(
        CreateProject  => \&create_project,
        CreateClass    => \&create_class,
        CreateTests    => \&create_tests,
        CreatePSGI     => \&create_psgi,
        CreateCPANFile => \&create_cpanfile,
        CreateChanges  => \&create_changes,
    );
}

sub create_project {
    my ($setup, $context) = @_;
    my $path = File::Spec->catdir($setup->approot);
    $setup->stop("Project directory %s already exists.", $path) if -d $path;
    $setup->makepath();
    return $context;
}

sub create_class {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('MyClass.pm');
    $setup->spew($setup->classfile, $setup->process_template($data));
    return $context;
}

sub create_tests {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('001_use.t');
    $setup->spew('t', '001_use.t', $setup->process_template($data));
    return $context;
}

sub create_psgi {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('app.psgi');
    $setup->spew('app.psgi', $setup->process_template($data));
    return $context;
}

sub create_cpanfile {
    my ($setup, $context) = @_;
    my $data = $setup->cpanfile;
    $setup->spew('cpanfile', $data);
    return $context;
}

sub create_changes {
    my ($setup, $context) = @_;
    my $data = $context->get('data_section')->(__PACKAGE__)->get_data_section('Changes');
    $setup->spew('Changes', $setup->process_template($data));
    return $context;
}

1;

__DATA__

@@ MyClass.pm
package {{$c->appname}};
use strict;
use warnings;
use Voson;

our $VERSION = 0.01;

app {
    [200, [], 'Hello, World!'];
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

@@ 001_use.t
use strict;
use warnings;
use Test::More;

BEGIN {
    use {{$c->appname}};
};

ok 1, 'succeed to use';

done_testing;

@@ app.psgi
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__), 'lib'), 
);
use {{$c->appname}};

{{$c->appname}}->run;

@@ Changes
Revision history for Perl extention {{$c->appname}}

{{$NEXT}}

    - original version

__END__

=encoding utf-8

=head1 NAME

Voson::Setup::Plugin::Minimal - Minimal setup of Voson

=head1 DESCRIPTION

Minimal setup plugin

=head1 SYNOPSIS

    $ voson-setup --plugins Minimal YourApp

=head1 ENABLED PLUGINS

=over 4

=item L<Voson::Plugin::Basic>

=back

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

