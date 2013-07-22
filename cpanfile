requires 'perl', '5.008001';
requires 'Scalar::Util';
requires 'Module::Load';
requires 'Plack';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

