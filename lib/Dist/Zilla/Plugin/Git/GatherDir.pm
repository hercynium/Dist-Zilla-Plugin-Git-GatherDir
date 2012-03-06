use strict;
use warnings;
package Dist::Zilla::Plugin::Git::GatherDir;
# ABSTRACT: uses git ls-files to decide what to gather for the build


use Moose;
use Moose::Autobox;
use MooseX::Types::Path::Class qw(Dir File);
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::Git::Repo';

use ExtUtils::Manifest;
use Git::Wrapper;

use File::Find::Rule;
use File::HomeDir;
use File::Spec;
use Path::Class;

use namespace::autoclean;

has root => (
    is   => 'ro',
    isa  => Dir,
    lazy => 1,
    coerce   => 1,
    required => 1,
    default  => sub { shift->zilla->root },
);

has prefix => (
    is  => 'ro',
    isa => 'Str',
    default => '',
);


sub gather_files {
    my ($self) = @_;

    my $git  = Git::Wrapper->new( $self->repo_root );
    my @filepaths = $git->ls_files();
print Dumper \@filepaths; exit;
    my @files;
    FILE: for my $filename (@filepaths) {
        push @files, $self->_file_from_filename($filename);
    }

    my $root = "" . $self->root;
    $root =~ s{^~([\\/])}{File::HomeDir->my_home . $1}ex;
    $root = Path::Class::dir($root);

    for my $file (@files) {
        (my $newname = $file->name) =~ s{\A\Q$root\E[\\/]}{}gx;
        $newname = File::Spec->catdir($self->prefix, $newname) if $self->prefix;
        $newname = Path::Class::dir($newname)->as_foreign('Unix')->stringify;

        $file->name($newname);
        $self->add_file($file);
    }

    return;
}

sub _file_from_filename {
    my ($self, $filename) = @_;

    unless (-f $filename) {
        $self->log_fatal("Cannot read file from manifest: ", $filename);
    }

    return Dist::Zilla::File::OnDisk->new({
        name => $filename,
        mode => (stat $filename)[2] & oct(755), # kill world-writeability
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__
