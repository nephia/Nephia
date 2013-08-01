package Voson::Setup::Plugin::Minimal;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin';

sub fix_setup {
    my ($self) = @_;
    $self->setup->action_chain->append(
        CreateProject  => \&create_project,
        CreateClass    => \&create_class,
        CreateTests    => \&create_tests,
        CreatePSGI     => \&create_psgi,
        CreateCPANFile => \&create_cpanfile,
    );
}

sub create_project {
    my ($setup, $context) = @_;
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

1;

__DATA__

@@ MyClass.pm
package {{$c->appname}};
use strict;
use warnings;
use Voson;

app {
    [200, [], 'Hello, World!'];
};

1;

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
use {{$c->appname}};

{{$c->appname}}->run;

