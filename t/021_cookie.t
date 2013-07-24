use strict;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Voson::Core;
use Data::Dumper;

my $v = Voson::Core->new(
    app => sub {    
        my $cnt = cookie('count') || 0;
warn Dumper({COUNT => $cnt});
        cookie(count => ++$cnt);
        [200, [], "count=$cnt"];
    },
);

my $mech = Test::WWW::Mechanize::PSGI->new(app => $v->run);

$mech->get_ok('/');
$mech->content_is( 'count=1' );
diag explain($mech->res);
$mech->get_ok('/');
$mech->content_is( 'count=2' );

done_testing;
