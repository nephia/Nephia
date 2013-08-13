package Voson::Setup;
use strict;
use warnings;
use Archive::Extract;
use Carp;
use Data::Section::Simple;
use File::Basename 'fileparse';
use File::Fetch;
use File::Spec;
use File::Temp 'tempdir';
use Module::Load ();
use Voson::Chain;
use Voson::Context;
use Voson::MetaTemplate;
use URI;

our $NEXT;

sub new {
    my ($class, %opts) = @_;
    $opts{nest}           = 0;
    $opts{approot}      ||= $class->_resolve_approot($opts{appname});
    $opts{classfile}    ||= $class->_resolve_classfile($opts{appname});
    $opts{action_chain}   = Voson::Chain->new(namespace => 'Voson::Setup::Action');
    $opts{plugins}      ||= [];
    $opts{options}      ||= {};
    $opts{deps}         ||= $class->_build_deps;
    $opts{meta_tmpl}      = Voson::MetaTemplate->new($opts{meta_tmpl} ? %{$opts{meta_tmpl}} : ());
    my $self = bless {%opts}, $class;
    $self->_load_plugins;
    return $self
}

sub _resolve_approot {
    my ($class, $appname) = @_;
    return ['.', $class->_normalize_appname($appname)];
}

sub _normalize_appname {
    my ($class, $appname) = @_;
    my $rtn = $appname;
    $rtn =~ s|\:\:|\-|g;
    return $rtn;
}

sub _resolve_classfile {
    my ($class, $appname) = @_;
    return ['lib', split('::', $appname.'.pm')];
}

sub _build_deps {
    {
        requires => ['Voson' => 0],
        test => {
            requires => ['Test::More' => 0],
        },
    };
}

sub _deparse_deps {
    my $nest_level = shift;
    my $nest = $nest_level > 0 ? join('', map{' '} 1 .. $nest_level*4) : '';
    my %val = @_;
    my $data = "";
    for my $key (keys %val) {
        my $v = $val{$key};
        if (ref($v) eq 'ARRAY') {
            my @mods = @$v;
            while (@mods) {
                my $name    = shift(@mods);
                my $version = shift(@mods);
                $data .= "$nest$key '$name' => $version;\n";
            }
        }
        elsif (ref($v) eq 'HASH') {
            $data .= "on '$key' => sub {\n";
            $data .= &_deparse_deps($nest_level + 1, %$v);
            $data .= "};\n";
        }
    }
    return $data;
}

sub appname {
    my $self = shift;
    return $self->{appname};
}

sub approot {
    my $self = shift;
    return ref($self->{approot}) eq 'ARRAY' ? @{$self->{approot}} : ( $self->{approot} );
}

sub classfile {
    my $self = shift;
    return @{$self->{classfile}};
}

sub action_chain {
    my $self = shift;
    return wantarray ? $self->{action_chain}->as_array : $self->{action_chain};
}

sub deps {
    my $self = shift;
    return $self->{deps};
}

sub meta_tmpl {
    my $self = shift;
    return $self->{meta_tmpl};
}

sub makepath {
    my ($self, @in_path) = @_;
    my $path = File::Spec->catdir($self->approot, @in_path);
    my $level = 0;
    while ( ! -d $path ) {
        my $_path = File::Spec->catdir($self->approot, @in_path[0..$level]);
        unless (-d $_path) {
            $self->diag("Create directory %s", $_path);
            mkdir $_path or $self->stop("could not create path %s - %s", $path, $!);
        }
        $level++;
    }
}

sub spew {
    my $self     = shift;
    my $data     = pop;
    my $filename = pop;
    my @in_path  = @_;
    my $path     = File::Spec->catfile($self->approot, @in_path, $filename);
    $self->makepath( @in_path );
    if (-e $path) {
        return;
    }
    $self->diag('Create file %s', $path);
    open my $fh, '>', $path or $self->stop("could not open file %s - %s", $path, $!);
    print $fh $data;
    close $fh;
}

sub process_template {
    my ($self, $data) = @_;
    my $c = $self;                 ### for template
    local $NEXT = '\{\{$NEXT\}\}'; ### for minilla friendly
    while (my ($code) = $data =~ /\{\{(.*?)\}\}/) {
        my $replace = eval "$code";
        $self->stop($@) if $@;
        $data =~ s/\{\{(.*?)\}\}/$replace/x;
    }
    $data =~ s/\\\{/{/g;
    $data =~ s/\\\}/}/g;
    $data =~ s/\:\:\:/=/g;
    return $data;
}

sub do_task {
    my $self = shift;
    $self->diag("\033[44m\033[1;36mBegin to setup %s\033[0m", $self->appname);
    my $context = Voson::Context->new(
        data_section => sub { Data::Section::Simple->new($_[0]) },
    );
    $self->{nest}++;
    for my $action ( $self->action_chain ) {
        my $name = ref($action);
        $self->diag("\033[1;34m[Action]\033[0m \033[0;35m%s\033[0m - provided by \033[0;32m%s\033[0m", $name, $self->action_chain->from($name));
        $self->{nest}++;
        $context = $action->($self, $context);
        $self->{nest}--;
        $self->diag("Done.");
    }
    $self->{nest}--;
    $self->diag("\033[44m\033[1;36mSetup finished.\033[0m");
}

sub diag {
    my ($self, $str, @params) = @_;
    my $spaces = $self->_spaces_for_nest;
    printf STDERR $spaces.$str."\n", @params;
}

sub stop {
    my ($self, $str, @params) = @_;
    my $spaces = $self->_spaces_for_nest;
    croak( sprintf($spaces."\033[41m\033[1;33m[! SETUP STOPPED !]\033[0m \033[1;31m".$str."\033[0m", @params) );
}

sub _spaces_for_nest {
    my $self = shift;
    my $spaces = '';
    if ($self->{nest}) {
        $spaces .= ' ' for 1 .. $self->{nest} * 2;
    }
    return $spaces;
}

sub _load_plugins {
    my $self = shift;
    for my $plugin_name ( @{$self->{plugins}} ) {
        $self->_load_plugin($plugin_name);
    }
}

sub _load_plugin {
    my ($self, $plugin_name) = @_;
    my $plugin_class = $self->_plugin_name_normalize($plugin_name);
    Module::Load::load($plugin_class);
    my $plugin = $plugin_class->new(setup => $self);
    $plugin->fix_setup;
    for my $bundle ($plugin->bundle) {
        $self->diag("\033[1;36m[bundle]\033[0m \033[0;35m%s\033[0m for \033[0;32m%s\033[0m", $self->_plugin_name_normalize($bundle), $plugin_class);
        $self->_load_plugin($bundle);
    }
    return $plugin;
}

sub _plugin_name_normalize {
    my ($self, $plugin_name) = @_;
    my $plugin_class = $plugin_name =~ /^Voson::Setup::Plugin::/ ? $plugin_name : 'Voson::Setup::Plugin::'.$plugin_name;
    return $plugin_class;
}

sub cpanfile {
    my $self = shift;
    &_deparse_deps(0, %{$self->deps});
}

sub assets {
    my ($self, $url, @in_path) = @_;
    my $path = File::Spec->catfile($self->approot, @in_path);
    unless ( -e $path ) {
        $self->diag('Fetching content from url %s', $url);
        my $fetcher = File::Fetch->new( uri => $url );
        my $content ;
        $fetcher->fetch(to => \$content) or $self->stop('Could not fetch url %s : %s', $url, $!);
        $self->spew(@in_path, $content);
    }
}

sub assets_archive {
    my ($self, $url, @in_path) = @_;
    my $path = File::Spec->catdir($self->approot, @in_path);
    unless ( -d $path ) {
        local $Carp::CarpLevel = $Carp::CarpLevel + 1;

        my ($filename) = fileparse( URI->new($url)->path );
        $self->assets( $url, $filename );
        my $archive_file = File::Spec->catfile($self->approot, $filename);

        $self->makepath( @in_path );

        $self->diag('Extract Archive %s into %s', $archive_file, $path);
        my $archive = Archive::Extract->new(archive => $archive_file);
        $archive->extract(to => $path);

        $self->diag('Cleanup Archive %s', $archive_file);
        unlink $archive_file;
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Voson::Setup - Base class of setup tool

=head1 DESCRIPTION

This class is used in setup tool internally.

=head1 SYNOPSIS

    my $setup = Voson::Setup->new(
        appname => 'YourApp::Web',
        plugins => ['Normal'],
    );
    $setup->do_task;

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

