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

use Voson plugins => [
    'Dispatch',
    'JSON',
    'HashHandler' => { handler => 'json_res' },
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
