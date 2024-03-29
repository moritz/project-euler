#!/usr/bin/perl

use strict;
use warnings;
use IO::Handle;

no warnings 'recursion';

use 5.010;

use List::Util qw(sum min);
# use Math::BigInt (":constant", lib => 'GMP');
use integer;

STDOUT->autoflush(1);

my @p;

sub p_k_n
{
    my ($k, $n) = @_;

    if ($k > $n)
    {
        return 0;
    }
    elsif ($k == $n)
    {
        return 1;
    }
    else
    {
        return ($p[$n][$k] //= ((p_k_n($k+1, $n) + p_k_n($k,$n-$k)) % 1_000_000));
    }
}

my $n = 2;
N_LOOP:
while (1)
{
    my $p = p_k_n(1, $n);
    print "N = $n ; V = $p\n";
    if ($p % 1000 == 0)
    {
        last N_LOOP;
    }
}
continue
{
    $n++;
}

# For % 1,000 == 449
# For % 100 = 74
# For % 10 = 9
