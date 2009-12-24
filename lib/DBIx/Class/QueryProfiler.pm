package DBIx::Class::QueryProfiler;

=head1 NAME

DBIx::Class::QueryProfiler - DBIx::Class profiler

=head1 DESCRIPTION

Profiler for DBIx::Class. Also it provides more usable output or queries.

=head1 SYNOPSYS

    use DBIx::Class::QueryProfiler;

    sub connection {
        my $self = shift;
        my $response = $self->next::method(@_);
        $response->storage->auto_savepoint(1);
        $response->storage->debugobj(DBIx::Class::QueryProfiler->new);
        return $response;
    }

=head1 METHODS

=cut

use utf8;
use strict;
use warnings;
use 5.8.9;


use Carp qw(carp cluck);
use Term::ANSIColor;
use parent 'DBIx::Class::Storage::Statistics';

use Time::HiRes qw(time);

our $start;
our $VERSION = 0.01;
our $N = 0;
our %Q;
our %colormap = ( 'SELECT' => 'magenta', 'INSERT' => 'bold yellow', 'UPDATE' => 'bold blue', DELETE => 'bold red' );

sub _c {
    my $self = shift;
    if ( -t STDERR ) {
        return color( @_ );
    } else {
        return '';
    }
}

=head2 query_start

=cut

sub query_start {
    my $self = shift();
    my $sql = shift();
    my $n = $Q{$sql} ||= ++$N;
    my @params = @_;
    $sql =~ s{\?}{ shift(@params) }sge;
    my ($type) = ( $sql =~ m/^(\w+)/);
    $self->print("Q$n. Executing < ".$self->_c( $colormap{$type}||'magenta' ).$sql.$self->_c('reset')." >".( @params ? ' +['.join(', ', @params).']' : ''));
    $start = time();
}

=head2 query_end

=cut

sub query_end {
    my $self = shift();
    my $sql = shift();
    my $n = delete $Q{$sql} || '-.0';
    my @params = @_;

    my $elapsed = sprintf("%0.4f", time() - $start);
    my $prefix = '';
    my $suffix = '';
    if ( -t STDERR ) {
        if ( $elapsed < 0.01 ) {
            $prefix = color 'green';
        } elsif ( $elapsed < 0.1 ) {
            $prefix = color 'yellow', 'bold';
        } else {
            $prefix = color 'red'
        }
        $suffix = color 'reset';
    }    
    $self->print("Q$n. Execution took $prefix$elapsed$suffix seconds.");
    $start = undef;
}

=head2 print

Prints data to STDERR

=cut

sub print {
    my $self = shift;
    my $i = 0;
    my @c;
    while (@c = caller(++$i)) {
        next if $c[0] =~ m{^(?:DBIx::Class|Catalyst)};
        last;
    }
    @c = caller(1) unless @c;
    return print STDERR "@_ at $c[1] line $c[2].\n";
}

1;

        

=head1 BUGS

No bugs. Found? Report please :-)

=head1 AUTHOR

Andrey Kostenko <andrey@kostenko.name>, Mons Anderson <mons@cpan.org>

=head1 COMPANY

Rambler Internet Holding

=head1 CREATED

15.04.2009 19:28:45 MSD

=cut

