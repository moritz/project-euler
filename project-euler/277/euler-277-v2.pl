#!/usr/bin/perl

use strict;
use warnings;

use integer;
use bytes;

# use Math::BigInt lib => 'GMP', ':constant';

use Math::GMP;

use List::Util qw(sum);
use List::MoreUtils qw();

STDOUT->autoflush(1);

sub base3
{
    my $i = shift;

    if ($i == 0)
    {
        return '';
    }

    return base3($i / 3) . ($i % 3);
}

my $a1 = Math::GMP->new('1000000000000003');
my @SEQ = map { {U => 1, D => 0, d => 2}->{$_} } split//,'UDDDUdddDDUDDddDdDddDDUDDdUUDd';
my $max_i = -1;
my $max_i__a1 = $a1 + 0;

sub get_len
{
    my $x = shift;

    for my $i (keys(@SEQ))
    {
        my $move = $SEQ[$i];
        my $m = $x % 3;
        if ($move == $m)
        {
            if ($i > $max_i)
            {
                print "Reached $i at $a1 [delta=" . base3($a1 - $max_i__a1) . "]\n";
                $max_i = $i;
                $max_i__a1 = $a1 + 0;
            }
            $x = ($move == 0) ? ($x/3) : ($move == 1) ? (4*$x+2)/3 : (2*$x-1)/3;
        }
        else
        {
            return ($i - 1);
        }
    }
    return scalar@SEQ;
}

MAIN:
while (1)
{
    my $x = $a1 + 0;

    my $l = get_len($x + 0);

    if ($l == @SEQ)
    {
        print "Result == $x\n";
        last MAIN;
    }
    my $next_a1 = sub {
        for my $pow3 (1 .. 200)
        {
            for my $d (1 .. 2)
            {
                my $pivot = $x + $d * Math::GMP->new('3') ** $pow3;
                if (get_len($pivot) > $l)
                {
                    return $pivot;
                }
            }
        }
    }->();

    $a1 = $next_a1;
}
