package Voson::Plugin::View::MicroTemplate;
use strict;
use warnings;
use parent 'Voson::Plugin';
use Text::MicroTemplate::File;
use Encode;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->app->{stash} = {};
    $self->app->{view} = Text::MicroTemplate::File->new(%opts);
    return $self;
}

sub exports { qw/ render / }

sub render {
    my ($self, $context) = @_;
    return sub ($;$) {
        my ($template, $args) = @_;
        my $content = $self->app->{view}->render_file($template, $args);
        Encode::encode_utf8($content);
    };
}

1;
