package Row;

use strict;
use warnings;
use autodie;

use MooX qw/late/;

has 'idx' => (isa => 'Int', is => 'ro', required => 1,);

has 'start' => (isa => 'Int', is => 'ro', lazy => 1, default => sub {
        my $self = shift;
        my $n = $self->idx - 1;
        return ((($n * ($n+1)) >> 1) + 1);
    }
);

has 'end' => (isa => 'Int', is => 'ro', lazy => 1, default => sub {
        my $self = shift;
        return $self->start + $self->idx - 1;
    }
);

has '_next' => (is => 'ro', lazy => 1, default => sub {
        my $self = shift;
        return Row->new({idx => ($self->idx+1)});
    }
);

has '_prev' => (is => 'ro', lazy => 1, default => sub {
        my $self = shift;
        return Row->new({idx => ($self->idx-1)});
    }
);

has 'buf' => (is => 'rw', default => sub { my $buf = ''; return (\$buf); },);

has '_found' => (is => 'ro', default => sub { return +{}; });

has '_here' => (is => 'rw', isa => 'Bool', default => 0,);

sub mark_primes
{
    my ($self) = @_;

    my $top = $self->_next->_next->end;
    my $top_prime = int(sqrt($top));

    my @rows = ($self->_prev->_prev, $self->_prev, $self, $self->_next, $self->_next->_next);

    open my $primes_fh, "primes 2 '$top_prime'|";
    while (my $p = <$primes_fh>)
    {
        chomp($p);
        my $i = $rows[0]->start;
        my $m = $i % $p;
        if ($m != 0)
        {
            $i += $p-$m;
        }

        foreach my $row (@rows)
        {
            my $s = $row->start;
            my $e = $row->end;
            my $buf = $row->buf;

            for(; $i<=$e ; $i += $p)
            {
                vec ($$buf, $i-$s, 1) = 1;
            }
        }
    }
    close($primes_fh);

    return;
}

# Requires mark_primes to be called first.
sub is_prime
{
    my ($self, $col) = @_;

    return (vec(${$self->buf}, $col, 1) == 0);
}

sub calc_S
{
    my ($self) = @_;

    $self->_here(1);

    my @rows = ($self->_prev->_prev, $self->_prev, $self, $self->_next, $self->_next->_next);

    for my $row_idx (1 .. 3)
    {
        my $row = $rows[$row_idx];
        for my $col (0 .. $row->idx - 1)
        {
            if ($row->is_prime($col))
            {
                my @to_check =
                (grep
                    {
                        my ($y, $x) = @$_;
                        $x >= 0 and $x < $y->idx
                    }
                    map
                    {
                        my $y = $_;
                        map { [$y, $col+$_] } ((-1) .. 1)
                    }
                    @rows[($row_idx-1) .. ($row_idx+1)]
                );

                my @primes = (grep { $_->[0]->is_prime($_->[1]) } @to_check);

                if (@primes >= 3)
                {
                    for my $p (@primes)
                    {
                        my ($y, $x) = @$p;

                        if ($y->_here)
                        {
                            $y->_found->{$x} = 1;
                        }
                    }
                }
            }
        }
    }

    # Just for safety.
    $self->_here(0);

    my $ret_S = 0;
    my $s = $self->start;
    for my $col (keys ( %{ $self->_found } ))
    {
        $ret_S += $s + $col;
    }

    return $ret_S;
}

1;

