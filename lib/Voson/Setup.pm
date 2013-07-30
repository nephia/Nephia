package Voson::Setup;
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use Data::Section::Simple;
use Carp;

sub new {
    my ($class, %opts) = @_;
    $opts{approot}   ||= $class->_resolve_approot($opts{appname});
    $opts{classfile} ||= $class->_resolve_classfile($opts{appname});
    bless {%opts}, $class;
}

sub _resolve_approot {
    my ($class, $appname) = @_;
    return File::Spec->catdir('.', $class->_normalize_appname($appname));
}

sub _normalize_appname {
    my ($class, $appname) = @_;
    my $rtn = $appname;
    $rtn =~ s|\:\:|\-|g;
    return $rtn;
}

sub _resolve_classfile {
    my ($class, $appname) = @_;
    my $approot = $class->_resolve_approot($appname);
    return File::Spec->catdir($approot, 'lib', split('::', $appname.'.pm'));
}

sub appname {
    my $self = shift;
    return $self->{appname};
}

sub approot {
    my $self = shift;
    return $self->{approot};
}

sub classfile {
    my $self = shift;
    return $self->{classfile};
}

sub makepath {
    my ($self, @in_path) = @_;
    my $path = File::Spec->catdir($self->approot, @in_path);
    my $level = 0;
    while ( ! -d $path ) {
        my $_path = File::Spec->catdir($self->approot, @path[0..$level]);
        mkdir $_path unless -d $_path;
    }
}

sub spew {
    my ($self, @in_path) = @_;
    my $path = File::Spec->catfile($self->approot, $section_path);
    my $data = $self->data_section(@path);
    $self->makepath( dirname($path) );
    open my $fh, '>', $path or croak $!;
    print $fh $data;
    close $fh;
}

sub data_section {
    my ($self, @in_path) = @_;
    my $path = File::Spec->catfile(@in_path);
    my @classes = @{mro::get_linear_isa(ref($self))};
    for my $class (@classes) {
        my $reader = Data::Section::Simple->new($class);
        my $data = $reader->get_data_section($path);
        return $data if $data;
    }
}


1;
