package Voson::Plugin::Cookie;
use strict;
use warnings;
use parent 'Voson::Plugin';
use Scalar::Util ();
use Voson::Response;

sub exports {
    qw/cookie/;
}

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    my $app = $self->app;
    $app->action_chain->prepend(CookieEater => $self->can('eat_cookie'));
    $app->action_chain->append(CookieImprinter => $self->can('imprint_cookie'));
    return $self;
}

sub cookie {
    my ($self, $context) = @_;
    return sub (;$$) {
        my $cookies = $context->get('cookies');
        $cookies ||= {};
        if ($_[0] && $_[1]) {
            $cookies->{$_[0]} = $_[1];
            $context->set(cookies => $cookies);
        }
        my $rtn = $_[0] ? $cookies->{$_[0]} : $cookies;
        return $rtn;
    };
}

sub eat_cookie {
    my ($app, $context) = @_;
    my $req = $context->get('req');
    my $cookies = $req->cookies || {};
    $context->set(cookies => $cookies);
    return $context;
}

sub imprint_cookie {
    my ($app, $context) = @_;
    my $res = $context->get('res');
    $res = Scalar::Util::blessed($res) ? $res : Voson::Response->new(@$res);
    my $cookies = $context->get('cookies');
    if ($cookies) {
        $res->cookies->{$_} = $cookies->{$_} for keys %$cookies;
        $context->set(res => $res);
    }
    return $context;
}

1;

__END__
