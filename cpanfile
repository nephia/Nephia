requires 'perl', '5.008001';
requires 'Scalar::Util';
requires 'Module::Load';
requires 'Router::Simple';
requires 'Plack';
requires 'JSON::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
    requires 'Test::WWW::Mechanize::PSGI';
};

