package Voson::Core;
use strict;
use warnings;
use Voson::Request;
use Voson::Response;
use Voson::Context;
use Scalar::Util ();
use Module::Load ();

sub new {
    my ($class, %opts) = @_;
    $opts{caller}  ||= caller();
    $opts{plugins} ||= [];
    my $self = bless {%opts}, $class;
    $self->{loaded_plugins} = [ $self->load_plugins ];
    return $self;
}

sub load_plugins {
    my $self = shift;
    my @plugins = ('Basic', @{$self->{plugins}});
    my @rtn;
    while ($plugins[0]) {
        my $plugin_class = 'Voson::Plugin::'. shift(@plugins);
        my $conf = {};
        if ($plugins[0]) {
            $conf = shift(@plugins) if ref($plugins[0]) eq 'HASH';
        }
        push @rtn, $self->_load_plugin($plugin_class, $conf);
    }
    return @rtn;
}

sub loaded_plugins {
    my $self = shift;
    return @{$self->{loaded_plugins}};
}

sub _load_plugin {
    my ($self, $plugin, $opts) = @_;
    $opts ||= {};
    Module::Load::load($plugin);
    return $plugin->new(%$opts);
}

sub app {
    my $self = shift;
    return $self->{app};
}

sub caller_class {
    my $self = shift;
    return $self->{caller};
}

sub action {
    my ($self, $context) = @_;
    $context = $self->before_action($context);
    return $self->app->($context);
}

sub before_action {
    my ($self, $context) = @_;
    my $class = $self->caller_class;
    no strict   qw/refs subs/;
    no warnings qw/redefine/;
    for my $plugin ($self->loaded_plugins) {
        *{$class.'::'.$_} = $plugin->$_($context) for $plugin->exports;
    }
    return $context;
}

sub run {
    my $self  = shift;
    my $class = $self->{caller};

    return sub {
        my $env     = shift;
        my $req     = Voson::Request->new($env);
        my $context = Voson::Context->new(req => $req);
        my $res = $self->action($context);
        $res = Scalar::Util::blessed($res) ? $res : Voson::Response->new(@$res);
        return $res->finalize;
    };
}

1;
