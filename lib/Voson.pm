package Voson;
use 5.008005;
use strict;
use warnings;
use Voson::Incognito;

our $VERSION = "0.01";

sub import {
    my ($class, %opts) = @_;
    my $caller = caller;
    Voson::Incognito->incognito(%opts, caller => $caller);
}

sub run {
    my $caller = caller;
    Voson::Incognito->unmask($caller)->run;
}

1;
__END__

=encoding utf-8

=head1 NAME

Voson - A mini-sized WAF that aimed to substitute for Nephia

=head1 SYNOPSIS

    use Voson plugins => [...];
    app {
        my $req  = req;         ### Request object
        my $id   = param('id'); ### query-param that named "id" 
        my $body = sprintf('ID is %s', $id);
        [200, [], $body];
    };

=head1 DESCRIPTION

Voson is microcore architecture WAF. 

=head1 GETTING STARTED

Let's try to create your project.

    voson-setup YourApp::Web

Then, you may plackup on your project directory.

=head1 LOAD OPTIONS 

Please see L<Voson::Core>.

=head1 DSL

=head2 app

    app { ... };

Specify code-block of your webapp.

=head2 other two basic DSL

Please see L<Voson::Plugin::Basic>.

=head1 EXPORTS

=head2 run

In app.psgi, run() method returns your webapp as coderef.

    use YourApp::Web;
    YourApp::Web->run;

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

