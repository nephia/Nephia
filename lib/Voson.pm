package Voson;
use 5.008005;
use strict;
use warnings;
use Voson::Core;
use Voson::Context;

our $VERSION = "0.01";

sub import {
    my ($class, %opts) = @_;
    my $caller = caller;
    Voson::Core->incognito(%opts, caller => $caller);
}

sub run {
    Voson::Core->unmask->run;
}

1;
__END__

=encoding utf-8

=head1 NAME

Voson - A mini-sized WAF that aimed to substitute for Nephia

=head1 SYNOPSIS

    use Voson;

=head1 DESCRIPTION

Voson is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

