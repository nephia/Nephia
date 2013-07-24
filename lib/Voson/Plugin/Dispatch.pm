package Voson::Plugin::Dispatch;
use strict;
use warnings;
use parent 'Voson::Plugin';
use Router::Simple;

sub exports {
    qw/get post put del path_param/;
}

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    my $app = $self->app;
    $app->action_chain->after('Core', Dispatch => $self->can('dispatch'));
    $app->{router} = Router::Simple->new;
    return $self;
}

sub dispatch {
    my ($app, $context) = @_;
    my $router = $app->{router};
    my $req    = $context->get('req');
    my $env    = $req->env;
    my $res    = [404, [], ['not found']];
    if (my $p = $router->match($env) ) {
        my $action = delete $p->{action};
        $context->set(path_param => $p);
        $res = $action->($app, $context);
    }
    $context->set(res => $res);
    return $context;
}

sub path_param {
    my ($self, $context) = @_;
    return sub (;$) {
        my $path_param = $context->get('path_param');
        $_[0] ? $path_param->{$_[0]} : $path_param;
    };
}

sub path {
    my ($self, $context, $method) = @_;
    my $router = $self->app->{router};
    return sub ($&) {
        my ($path, $code) = @_;
        my @pathes = ref($path) eq 'ARRAY' ? @$path : ( $path );
        $router->connect($_, {action => $code}, {method => $method}) for @pathes;
    };
}

{
    no strict qw/refs/;
    my %methods = (get => 'GET', post => 'POST', put => 'PUT', del => 'DELETE');
    for my $dsl (keys %methods) {
        *$dsl = sub {
            my ($self, $context) = @_;
            $self->path($context, $methods{$dsl});
        };
    };
}

1;
