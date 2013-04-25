#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  setup_repo.pl
#
#        USAGE:  ./setup_repo.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gautam Dey (gdey), gautam@tealium.com
#      COMPANY:  Tealium Inc.
#      VERSION:  1.0
#      CREATED:  04/24/2013 16:57:33
#     REVISION:  ---
#===============================================================================

use v5.12.0;
use warnings;
package GIT;

use Git::Repository;

sub new {
   my ($self, @options) = @_;
   my $class = ref($self) || $self;
   my $this = { options => \@options, git => Git::Repository->new(@options) };
   return bless {}, $class;
}

sub git { $_[0]->{git} //= Git::Repository->new(@{$_[0]->{options}}) }
sub run { my $s = shift; say "command: ",join(' ',@_); $s->git->run( @_ ) };
sub dir { $_[0]->run( 'rev-parse' =>  qw( --git-dir ) ) }
sub add_remote {
   my ( $self, $remote, $url ) = @_;
   $self->run( remote => add => $remote , $url )
}
sub fetch {
   my ( $self, $remote ) = @_;
   $self->run( fetch => $remote , {quiet => 1})
}

sub chk_new_branch {
   my ( $self, $branch_name, $source ) = @_;
   $self->run( checkout => '-b', $branch_name, $source  )
}

sub checkout {
   my ($self, $branch_name ) = @_;
   $self->run( checkout => $branch_name, {quiet =>  1} )
}

sub read_tree {
   my ($self, $dir_path, $branch_name ) = @_;
   $self->run( 'read-tree', "--prefix=$dir_path", "-u", $branch_name );
}

sub remotes {
   my ($self, %args) = @_;
   my @options = ();
   push @options, '-v' if( $args{verbose} );
   $self->run( remote => @options );
}

package MAIN;
use JSON;
use File::Slurp;
use Data::Dumper;

use FindBin;
my $cookbook_file = "$FindBin::Bin/cookbooks.json";
my $git = GIT->new;
say "Git Dir:".$git->dir;

my $cookbooks = from_json( read_file( $cookbook_file ) => { relaxed => 1 }  );

my $remotes = {
map {
   # First we want to get all the prefixes
   my $prefix = $_;
   my $subcookbooks = $cookbooks->{$prefix};
   map {
      # now we want to alter all the hashes inside. 
      my $module = $_;
      "${prefix}_${module}" => $subcookbooks->{$module}
   } keys %$subcookbooks;

} keys %$cookbooks
};
say Dumper( $remotes );

sub add_remote {
   my ($key, $url, $path) = @_;
   my $remote_name = $key.'_remote';
   my $branch_name = $key.'_branch';
}
for my $key ( keys %$remotes ) {
   my $remote_name = $key.'_remote';
   my $branch_name = $key.'_branch';
   my $dir = $git->dir;
   my $path = $remotes->{$key}->{path};

   #$git->add_remote( $remote_name, $remotes->{$key}->{url} );
   #$git->fetch( $remote_name );
   #$git->chk_new_branch( $branch_name, "$remote_name/master" );
   #$git->checkout('master');

   unless(  -e "$dir/../$path" ) {
      $git->read_tree( $path, $branch_name );
   }
   say Dumper( $git->remotes );
}


