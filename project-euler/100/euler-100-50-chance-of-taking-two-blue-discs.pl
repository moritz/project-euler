#!/usr/bin/perl

use strict;
use warnings;

use Math::BigInt lib => "GMP", ":constant";

=head1 Problem 100

If a box contains twenty-one coloured discs, composed of fifteen blue discs
and six red discs, and two discs were taken at random, it can be seen that the
probability of taking two blue discs, P(BB) = (15/21)×(14/20) = 1/2.

The next such arrangement, for which there is exactly 50% chance of taking two
blue discs at random, is a box containing eighty-five blue discs and
thirty-five red discs.

By finding the first arrangement to contain over 10^(12) = 1,000,000,000,000
discs in total, determine the number of blue discs that the box would contain.

=head1 Analysis

For $N , there should be $L < $N so that $L*($L-1) == ($N*($N-1))/2 :

$L^2 - $L - ($N*($N-1))/2 = 0

a = 1
b = -1
c = -N*(N-1)/2

L = [1 +/- sqrt ( 1 + 4*N*(N-1)/2)] / 2 = [1 +/- sqrt (1 + 2 * N * (N-1))] / 2
= [1 +/- sqrt ( 2*N^2 - 2*N + 1 )] / 2

2*N^2 - 2 * N + 1 = N^2 + (N-1)^2

(N+1)^2 = N^2 + 2N + 1

(N+2)^2 = (N+1)^2 + 2(N+1)+1

K^2 = N^2 + (N-1)^2

a^2 + b^2 = [ (a+b)^2 + (a-b)^2 ] / 2

N^2 + (N-1)^2 = [(2N-1)^2 + 1^2 ] / 2 = K^2

2K^2 = (2N-1)^2 + 1^2

=cut

sub find_blue_discs_num
{
    my $num_discs = shift;

    my $bottom = ($num_discs >> 1);
    my $top = $num_discs;

    my $divide_by = $num_discs * ($num_discs-1);

    my $wanted_product = ($divide_by >> 1);

    while ($top >= $bottom)
    {
        my $mid = (($bottom + $top) >> 1);

        my $product = $mid * ($mid-1);
        if ($product == $wanted_product)
        {
            return $mid;
        }
        elsif ($product < $wanted_product)
        {
            $bottom = $mid + 1;
        }
        else
        {
            $top = $mid - 1;
        }
    }
    return;
}

print "P(BB)[22] = ", find_blue_discs_num(21), "\n";
print "P(BB)[120] = ", find_blue_discs_num(120), "\n";

my $n = 1_000_000_000_000 + 1;

while (1)
{
    print "N = $n\n";
    my $v = find_blue_discs_num($n);
    if (defined($v))
    {
        print "P(BB)[$n] = $v\n";
        exit(0);
    }
}
continue
{
    $n++;
}
