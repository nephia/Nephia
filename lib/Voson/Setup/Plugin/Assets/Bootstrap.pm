package Voson::Setup::Plugin::Assets::Bootstrap;
use strict;
use warnings;
use parent 'Voson::Setup::Plugin';

sub fix_setup {
    my $self = shift;
    $self->setup->action_chain->append('Assets::Bootstrap' => \&_assets_bootstrap);
}

sub _assets_bootstrap {
    my ($setup, $context) = @_;
    $setup->assets_archive('http://getbootstrap.com/2.3.2/assets/bootstrap.zip', qw/static/);
}

1;
