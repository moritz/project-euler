#!/usr/bin/perl

use strict;
use warnings;

use Math::BigRat try => 'GMP';

use List::Util qw();


=head1 PROBLEM

If we are presented with the first k terms of a sequence it is impossible to say with certainty the value of the next term, as there are infinitely many polynomial functions that can model the sequence.

As an example, let us consider the sequence of cube numbers. This is defined by the generating function,
un = n3: 1, 8, 27, 64, 125, 216, ...

Suppose we were only given the first two terms of this sequence. Working on the principle that "simple is best" we should assume a linear relationship and predict the next term to be 15 (common difference 7). Even if we were presented with the first three terms, by the same principle of simplicity, a quadratic relationship should be assumed.

We shall define OP(k, n) to be the nth term of the optimum polynomial generating function for the first k terms of a sequence. It should be clear that OP(k, n) will accurately generate the terms of the sequence for n ≤ k, and potentially the first incorrect term (FIT) will be OP(k, k+1); in which case we shall call it a bad OP (BOP).

As a basis, if we were only given the first term of sequence, it would be most sensible to assume constancy; that is, for n ≥ 2, OP(1, n) = u1.

Hence we obtain the following OPs for the cubic sequence:
OP(1, n) = 1 	1, 1, 1, 1, ...
OP(2, n) = 7n−6 	1, 8, 15, ...
OP(3, n) = 6n2−11n+6      	1, 8, 27, 58, ...
OP(4, n) = n3 	1, 8, 27, 64, 125, ...

Clearly no BOPs exist for k ≥ 4.

By considering the sum of FITs generated by the BOPs (indicated in red above), we obtain 1 + 15 + 58 = 74.

Consider the following tenth degree polynomial generating function:

un = 1 − n + n2 − n3 + n4 − n5 + n6 − n7 + n8 − n9 + n10

Find the sum of FITs for the BOPs.

=head1 Planning.

Suppose we have n terms for which the polynomial yields (a1, a2, a3 ... an).
Then we can have:

c_0 + c_1 * 1 + c_2 * 1 ** 2 ... + c_n-1 * 1 ** n-1 = a_1
c_0 + c_1 * 2 + c_2 * 2 ** 2 ... + c_n-1 * 2 ** n-1 = a_2
c_0 + c_1 * 3 + c_2 * 3 ** 2 ... + c_n-1 * 3 ** n-1 = a_3

So we can find c_0 ... c_n-1 by solving the co-efficients problem.

/1 1 1 1 1 1 1 ......\           (c_0)
|1 2 4 8 16 32                   (c_1)
|1 3 9 27                      (c_2)
|1 4                                (c_3)
\

A_mat * C_vec = a_vec

C_vec = A_mat^-1 * a_vec

=cut

package Row;

use Moose;

has 'elems' => (isa => 'ArrayRef[Math::BigRat]', is => 'rw');

sub multiply_by
{
    my ($self, $x) = @_;

    foreach my $e (@{$self->elems})
    {
        $e *= $x;
    }

    return;
}

sub as_string
{
    my $self = shift;

    return join(", ", map { $_ . "" } @{$self->elems()});
}

package Matrix;

use Moose;

has 'rows' => (isa => 'ArrayRef[Row]', is => 'rw');

sub size
{
    my ($self) = @_;

    return scalar(@{$self->rows});
}

sub eye
{
    my $package = shift;
    my $size = shift;

    return $package->new(
        {
            rows =>
            [
                map
                {
                    my $r = $_;
                    Row->new(
                        {
                            elems =>
                            [
                                map
                                {
                                    ($_ == $r
                                        ? Math::BigRat->new(1)
                                        : Math::BigRat->new(0)
                                    )
                                }
                                (0 .. $size-1)
                            ]
                        }
                    )
                } (0 .. $size-1)
            ]
        }
    );
}

sub _swap_rows
{
    my ($self, $i, $j) = @_;

    my $rows = $self->rows();

    @{$rows}[$i,$j] = @{$rows}[$j,$i];

    return;
}

sub _multiply_row_by
{
    my ($self, $row, $x) = @_;

    $self->rows->[$row]->multiply_by($x);

    return;
}

sub _add_row_product_to_row
{
    my ($self, $row_idx, $other_row, $multiplier) = @_;

    foreach my $i (0 .. $self->size()-1)
    {
        $self->_set_elem(
            $row_idx, $i,
            $self->_elem($row_idx, $i)
                + ($multiplier * $self->_elem($other_row, $i))
        );
    }

    return;
}

sub _elem
{
    my ($self, $r, $c) = @_;

    return $self->rows->[$r]->elems->[$c];
}

sub _set_elem
{
    my ($self, $r, $c, $v) = @_;

    $self->rows->[$r]->elems->[$c] = $v;

    return;
}

sub inv
{
    my ($self) = @_;

    my $inverted = Matrix->eye($self->size());

    my $simultaneous = sub {
        my $callback = shift;

        foreach ($self, $inverted)
        {
            $callback->($_);
        }
    };

    foreach my $col_to_stair (0 .. $self->size()-1)
    {
        my $found_row_idx =
            List::Util::first
            {
                ! $self->_elem($_, $col_to_stair)->is_zero()
            }
            ($col_to_stair .. $self->size() - 1)
            ;

        if ($found_row_idx != $col_to_stair)
        {
            $simultaneous->(sub {
                $_->_swap_rows($col_to_stair, $found_row_idx);
                }
            );
        }

        {
            my $n = $self->_elem($col_to_stair, $col_to_stair);
            if (!$n->is_one())
            {
                $simultaneous->(
                    sub {
                        $_->_multiply_row_by($col_to_stair, 1/$n);
                    }
                );
            }
        }

        ROW_IDX:
        foreach my $row_idx (0 .. $self->size()-1)
        {
            if ($row_idx == $col_to_stair)
            {
                next ROW_IDX;
            }

            my $x = $self->_elem($row_idx, $col_to_stair);

            if (! $x->is_zero())
            {
                $simultaneous->(
                    sub {
                        $_->_add_row_product_to_row(
                            $row_idx, $col_to_stair, -$x
                        );
                    }
                );
            }
        }
    }

    return $inverted;
}

sub as_string
{
    my $self = shift;

    return join( "", map { $_->as_string() . "\n" } @{$self->rows()});
}

package main;

use Data::Dumper;


my @u_coeffs = (map { (-1) ** $_ } (0 .. 10));

sub calc_u_result_vec
{
    my $x = shift;

    return [map { (Math::BigRat->new($x) ** $_) * $u_coeffs[$_] } (0 .. $#u_coeffs)];
}

sub mysum
{
    my $s = Math::BigRat->new(0);

    foreach my $i (@_)
    {
        $s += $i;
    }

    return $s;
}

sub calc_u_result
{
    my $x = shift;
    return List::Util::sum (@{calc_u_result_vec($x)});
}

my @u_results = (map { calc_u_result($_) } (1 .. scalar(@u_coeffs)));

sub _row
{
    my $elems = shift;

    return Row->new({ elems => [ map { Math::BigRat->new($_) } @{$elems}]});
}

=begin Foo
my $mat = Matrix->new(
    {
    rows =>
    [
        _row([2,3,0]),
        _row([0,1,0]),
        _row([0,0,5]),
    ]
    }
);

print $mat->inv->as_string();

=end Foo

=cut

my $total_sum = 0;
foreach my $idx (1 .. 10)
{
    my $gen_mat = sub { return Matrix->new(
        {
            rows =>
            [
                map {
                    my $base = $_;
                    _row([
                        map {
                            my $power = $_;
                            Math::BigRat->new($base) ** $power
                        }
                        (0 .. $idx-1)
                    ]);
                }
                (1 .. $idx)
            ],
        }
    ) };

    my $mat = $gen_mat->();
    print $mat->as_string();

    my $inv = $mat->inv();

    my @coeffs;

    foreach my $c_idx (0 .. $idx-1)
    {
        my $sum = Math::BigRat->new(0);

        foreach my $x (0 .. $idx-1)
        {
            $sum += $inv->_elem($c_idx, $x) * $u_results[$x];
        }

        push @coeffs, $sum;
    }

    my $get_coeff_val = sub {
        my $x = shift;

        my $bop = Math::BigRat->new(0);
        foreach my $exp (0 .. $idx-1)
        {
            $bop += $coeffs[$exp] * ($x ** $exp);
        }

        return $bop;
    };

    foreach my $prev_idx (1 .. $idx)
    {
        if ($get_coeff_val->($prev_idx) != $u_results[$prev_idx-1])
        {
            die "Foo ($idx, $prev_idx)!" ;
        }
    }

    my $check = $idx;
    CHECK_LOOP:
    while (1)
    {
        my $val_of_idx = $get_coeff_val->($check);
        print "$val_of_idx\n";
        if ($val_of_idx != calc_u_result($check))
        {
            $total_sum += $val_of_idx;
            last CHECK_LOOP;
        }
    }
    continue
    {
        $check++;
    }
}

print "Total Sum = $total_sum\n";
