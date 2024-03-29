#!/usr/bin/perl

use strict;
use warnings;

=head1 DESCRIPTION

A number consisting entirely of ones is called a repunit. We shall define R(k)
to be a repunit of length k; for example, R(6) = 111111.

Given that n is a positive integer and GCD(n, 10) = 1, it can be shown that
there always exists a value, k, for which R(k) is divisible by n, and let A(n)
be the least such value of k; for example, A(7) = 6 and A(41) = 5.

The least value of n for which A(n) first exceeds ten is 17.

Find the least value of n for which A(n) first exceeds one-million.

=head1 ANALYSIS

A(n) < n because otherwise for R(1) .. R(n-1) there will be two identical
non-zero modulos. Let's say they are 'a' and 'b' where b > a, so
R(b) % n = R(a) % n. In that case (R(b)-R(a)) % n = 0, but then
(R(b-a) * 10^R(a)) % n = 0, and since the modulo of a power of 10 with n
cannot be 0 (because GCD(n, 10) = 1), then R(b-a) % n = 0, which demonstrates
that A(n) < n (reduction ad absurdum.).

=cut

sub calc_A
{
    my ($n) = @_;

    my $mod = 1;
    my $len = 1;

    while ($mod)
    {
        $mod = (($mod * 10 + 1) % $n);
        $len++;
    }

    return $len;
}

print "A(7) = ", calc_A(7), "\n";
print "A(41) = ", calc_A(41), "\n";

my $n = 1_000_001;

N_loop:
while (1)
{
    if ($n % 5 == 0)
    {
        next N_loop;
    }
    my $A = calc_A($n);
    print "N = $n ; A($n) = $A\n";
    if ($A > 1_000_000)
    {
        print "Found n - $n\n";
        exit(0);
    }
}
continue
{
    $n += 2;
}
