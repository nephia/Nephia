package Voson::Plugin::JSON;
use strict;
use warnings;
use parent 'Voson::Plugin';
use JSON::Tiny ();

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    my $app = $self->app;
    $app->{json_obj} = JSON::Tiny->new;
    return $self;
}

sub exports { qw/json_res encode_json decode_json/ }

sub json_res {
    my ($self, $context) = @_;
    return sub ($) {
        $context->set(res => [
            200, 
            [
                'Content-Type'           => 'applcation/json',
                'X-Content-Type-Options' => 'nosniff',  ### For IE 9 or later. See http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2013-1297
                'X-Frame-Options'        => 'DENY',     ### Suppress loading web-page into iframe. See http://blog.mozilla.org/security/2010/09/08/x-frame-options/
                'Cache-Control'          => 'private',  ### no public cache
            ], 
            $self->app->{json_obj}->encode($_[0])
        ]);
    };
}

sub encode_json {
    my ($self, $context) = @_;
    return sub ($) {$self->app->{json_obj}->encode($_[0])};
}

sub decode_json {
    my ($self, $context) = @_;
    return sub ($) {$self->app->{json_obj}->decode($_[0])};
}

1;
