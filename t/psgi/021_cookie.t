use strict;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Voson::Core;

my $v = Voson::Core->new(
    app => sub {    
        my $cnt = cookie('count') || 0;
        cookie(count => ++$cnt);
        [200, [], "count=$cnt"];
    },
);

my $mech = Test::WWW::Mechanize::PSGI->new(app => $v->run);

$mech->get_ok('/');
$mech->content_is( 'count=1' );
$mech->get_ok('/');
$mech->content_is( 'count=2' );

done_testing;
