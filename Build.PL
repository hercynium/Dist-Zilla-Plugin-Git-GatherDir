
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "uses git ls-files to decide what to gather for the build",
  "dist_author" => [
    "Stephen R. Scaffidi <sscaffid\@akamai.com>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Git-GatherDir",
  "dist_version" => "0.0.1_001",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Git::GatherDir",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Dumper" => 0,
    "Dist::Zilla::Plugin::GatherDir" => 0,
    "Dist::Zilla::Role::Git::Repo" => 0,
    "File::Find::Rule" => 0,
    "File::HomeDir" => 0,
    "File::Spec" => 0,
    "Git::Wrapper" => 0,
    "Moose" => 0,
    "Moose::Autobox" => 0,
    "MooseX::Types::Path::Class" => 0,
    "Path::Class" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
