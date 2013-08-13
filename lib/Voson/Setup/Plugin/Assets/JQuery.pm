package Voson::Setup::Plugin::Assets::JQuery;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin';

sub fix_setup {
    my $self = shift;
    $self->setup->action_chain->append('Assets::JQuery' => \&_assets_jquery);
}

sub _assets_jquery {
    my ($setup, $context) = @_;
    $setup->assets('http://code.jquery.com/jquery-1.10.1.min.js', qw/static js jquery.min.js/);
}

1;
