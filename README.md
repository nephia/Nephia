# NAME

Voson - A mini-sized WAF that aimed to substitute for Nephia

# SYNOPSIS

    use Voson plugins => [...];
    app {
        my $req  = req;         ### Request object
        my $id   = param('id'); ### query-param that named "id" 
        my $body = sprintf('ID is %s', $id);
        [200, [], $body];
    };

# DESCRIPTION

Voson is microcore architecture WAF. 

# GETTING STARTED

Let's try to create your project.

    voson-setup YourApp::Web

Then, you may plackup on your project directory.

Please see [Voson::Setup::Plugin::Basic](http://search.cpan.org/perldoc?Voson::Setup::Plugin::Basic) for detail.

# BOOTSTRAP A MINIMALIST STRUCTURE

Use "--plugins Minimal" option to minimalistic setup.

    voson-setup --plugins Minimal YourApp::Mini

Please see [Voson::Setup::Plugin::Minimal](http://search.cpan.org/perldoc?Voson::Setup::Plugin::Minimal) for detail.

# LOAD OPTIONS 

Please see [Voson::Core](http://search.cpan.org/perldoc?Voson::Core).

# DSL

## app

    app { ... };

Specify code-block of your webapp.

## other two basic DSL

Please see [Voson::Plugin::Basic](http://search.cpan.org/perldoc?Voson::Plugin::Basic).

## dispatcher DSL

Please see [Voson::Plugin::Dispatch](http://search.cpan.org/perldoc?Voson::Plugin::Dispatch).

# EXPORTS

## run

In app.psgi, run() method returns your webapp as coderef.

    use YourApp::Web;
    YourApp::Web->run;

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
