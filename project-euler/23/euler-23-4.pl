#!/usr/bin/perl
# Adapted by Shlomi Fish.
#
# Solution for:
#
# http://projecteuler.net/problem=23
#
# A perfect number is a number for which the sum of its proper divisors
# is exactly equal to the number. For example, the sum of the proper
# divisors of 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28
# is a perfect number.
#
# A number n is called deficient if the sum of its proper divisors is
# less than n and it is called abundant if this sum exceeds n.
#
# As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16, the
# smallest number that can be written as the sum of two abundant numbers
# is 24. By mathematical analysis, it can be shown that all integers
# greater than 28123 can be written as the sum of two abundant numbers.
# However, this upper limit cannot be reduced any further by analysis
# even though it is known that the greatest number that cannot be
# expressed as the sum of two abundant numbers is less than this limit.
#
# Find the sum of all the positive integers which cannot be written as
# the sum of two abundant numbers.
#

use strict;
use warnings;

use feature qw/say/;

my @divisors_sums;
$divisors_sums[1] = 0;

my $MAX = 28_123;
foreach my $div (1 .. ($MAX >> 1))
{
    my $prod = ($div<<1);
    while ($prod <= $MAX)
    {
        $divisors_sums[$prod] += $div;
    }
    continue
    {
        $prod += $div;
    }
}

# Memoized.
#
my $is_abundant_sum = '';

my @abundants;
my $total = 0;
foreach my $num (1 .. $MAX)
{
    if ($divisors_sums[$num] > $num)
    {
        push @abundants, $num;
        INNER:
        foreach my $i (@abundants)
        {
            my $s = $i+$num;
            if ($s > $MAX)
            {
                last INNER;
            }
            if (! vec($is_abundant_sum, $s, 1))
            {
                $total += $s;
                vec($is_abundant_sum, $s, 1) = 1;
            }
        }
    }
}

say "Sum == ", ((((1 + $MAX) * $MAX) >> 1)-$total);
