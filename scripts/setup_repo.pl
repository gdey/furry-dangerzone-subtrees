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
use File::Basename;

sub new {
   my ($self, @options) = @_;
   my $class = ref($self) || $self;
   my $this = { options => \@options, git => Git::Repository->new(@options) };
   return bless {}, $class;
}

sub git { $_[0]->{git} //= Git::Repository->new(@{$_[0]->{options}}) }
sub run { my $s = shift; say "command: ",join(' ',@_); $s->git->run( @_ ) };
sub dir { $_[0]->run( 'rev-parse' =>  qw( --git-dir ) ) }
sub repo_dir{ dirname($_[0]->dir) }
sub file_hash { $_[0]->run( 'hash-object', $_[1] ) }
sub add_remote {
   my ( $self, $remote, $url ) = @_;
   $self->run( remote => add => $remote , $url )
}
sub fetch {
   my ( $self, $remote ) = @_;
   $self->run( fetch => $remote , {quiet => 1})
}

sub branch {
   my ($self, %args ) = @_;
   my $branch_name = $args{name};
   
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
use File::Basename;
my $cookbook_file = "$FindBin::Bin/cookbooks.json";
my $git = GIT->new;

say "Git Dir:". $git->repo_dir;

my $readme_file = $git->repo_dir.'/README.md';
my $readme = read_file( $readme_file );
my $cookbooks = from_json( read_file( $cookbook_file ) => { relaxed => 1 }  );
my $cookbook_hash = $git->file_hash( $cookbook_file );
say $cookbook_hash;
my $tok = '<!-- %%cookbooks.json';
my $start =  index( $readme, $tok);
my $starting_pos = $start + length($tok) + 1;  # Starting position
my $ending_pos   = index( $readme, '%%', $starting_pos );
my $hash = substr($readme, $starting_pos, $starting_pos-$ending_pos);
say "Start: $starting_pos, END: $ending_pos HASH: $hash";
my $send = index( $readme, ' %% --!>', $start+1 ) + 8;
my $end  = index( $readme, $tok, $start+1 );

substr( $readme, $send,($end - $send), '<!-- snipped --!>');
say "Start: $start, END: $end HASH: $hash";
say $readme;
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

sub add_remote {
   my ($key, $url, $path) = @_;
   my $remote_name = $key.'_remote';
   my $branch_name = $key.'_branch';
}
my $dir = $git->dir;
for my $key ( keys %$remotes ) {
   my $remote_name = $key.'_remote';
   my $branch_name = $key.'_branch';
   my $path = $remotes->{$key}->{path};
   my $description = $remotes->{$key}->{description};
   my $url = $remotes->{$key}->{url};

   #$git->add_remote( $remote_name, $remotes->{$key}->{url} );
   #$git->fetch( $remote_name );
   #$git->chk_new_branch( $branch_name, "$remote_name/master" );
   #$git->checkout('master');
   say " * $description : $url ( $remote_name ) : $path ( $branch_name ) ";

   unless(  -e "$dir/../$path" ) {
      $git->read_tree( $path, $branch_name );
   }
   say Dumper( $git->remotes );
}


