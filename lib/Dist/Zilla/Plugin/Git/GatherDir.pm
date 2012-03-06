use strict;
use warnings;
package Dist::Zilla::Plugin::Git::GatherDir;
# ABSTRACT: uses git ls-files to decide what to gather for the build


use Moose;
use Moose::Autobox;
use MooseX::Types::Path::Class qw(Dir File);
#with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::Git::Repo';
extends 'Dist::Zilla::Plugin::GatherDir';
use Git::Wrapper;
use Data::Dumper;
use File::Find::Rule;
use File::HomeDir;
use File::Spec;
use Path::Class;

use namespace::autoclean;

override gather_files => sub {
  my ($self) = @_;

  my $root = "" . $self->root;
  $root =~ s{^~([\\/])}{File::HomeDir->my_home . $1}e;
  $root = Path::Class::dir($root);

  my @files;
  my $git  = Git::Wrapper->new( $self->repo_root );
  FILE: for my $filename ($git->ls_files()) {
    my $file = file($filename)->relative($root);

    unless ($self->include_dotfiles) {
      next FILE if $file->basename =~ qr/^\./;
      next FILE if grep { /^\.[^.]/ } $file->dir->dir_list;
    }

    my $exclude_regex = qr/\000/;
    $exclude_regex = qr/$exclude_regex|$_/
      for ($self->exclude_match->flatten);
    # \b\Q$_\E\b should also handle the `eq` check
    $exclude_regex = qr/$exclude_regex|\b\Q$_\E\b/
      for ($self->exclude_filename->flatten);
    next if $file =~ $exclude_regex;

    push @files, $self->_file_from_filename($filename);
  }

  for my $file (@files) {
    (my $newname = $file->name) =~ s{\A\Q$root\E[\\/]}{}g;
    $newname = File::Spec->catdir($self->prefix, $newname) if $self->prefix;
    $newname = Path::Class::dir($newname)->as_foreign('Unix')->stringify;

    $file->name($newname);
    $self->add_file($file);
  }

  return;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__
