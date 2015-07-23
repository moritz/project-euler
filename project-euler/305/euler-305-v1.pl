#!/usr/bin/perl

use strict;
use warnings;

use integer;
use bytes;

use Math::BigInt lib => 'GMP', ':constant';

use List::Util qw(sum);
use List::MoreUtils qw();

STDOUT->autoflush(1);

package Nexter;

sub new
{
    my ($class, $args) = @_;
    return bless $args, shift;
}

sub next
{
    my $self = shift;

    my $skip_all_zeros = $self->[2];

    my $ret;

    do
    {
        $ret = sprintf("%0" . $self->[0] . 'd', ($self->[1]++));

        if ($self->[1] == 10 ** $self->[0])
        {
            $self->[0]++;
            $self->[1] = 0;
        }
    } while($skip_all_zeros && $ret !~ /[1-9]/);

    return $ret;
}

package main;

sub test_nexter
{
    my ($num_digits, $base, $ret1, $ret2) = @_;

    my $obj = Nexter->new([$num_digits, $base]);

    if ($obj->next ne $ret1)
    {
        die "Nexter ret1: @_";
    }
    if ($obj->next ne $ret2)
    {
        die "Nexter ret2: @_";
    }

    return;
}

test_nexter(1,9, '9', '00');
test_nexter(1,0, '0', '1');
test_nexter(2, 0, '00', '01');
test_nexter(2, 99, '99', '000');

my $n = shift(@ARGV);

my $next_mins = 1;
my @mins = ({ s => '', strs => {next => Nexter->new([1,1,1]), s => '',}});

my %mm = (map { $_ => +{ next => Nexter->new([0,0,0]), s => '' } } 1 .. length($n)-1);

sub start_10
{
    my $l = shift;
    if ($l == 1)
    {
        return 1;
    }
    else
    {
        return +($l-1) * (9 * 10 ** ($l-2)) + start_10($l-1);
    }
}

sub calc_start
{
    my $needle = shift;

    my $len = length($needle);

    return start_10($len) + ($needle - (10 ** ($len-1))) * $len;
}

sub test_calc_start
{
    my ($needle, $want_pos) = @_;

    my $have_pos = calc_start($needle);
    if ($have_pos != $want_pos)
    {
        die "For needle=$needle got $have_pos instead of $want_pos";
    }
}

test_calc_start(1, 1);
test_calc_start(2, 2);
test_calc_start(10, 10);
test_calc_start(11, 12);
test_calc_start(99, 10+(99-10)*2);
test_calc_start(100, 10+(100-10)*2);
test_calc_start(200, 10+(100-10)*2+(200-100)*3);
test_calc_start(1000, 10+(100-10)*2+(1000-100)*3);

my $last_pos;
my $count = 1;
while (1)
{
    my $min;
    # For within a number containing the full number:

    my $last_i;
    my $which = '';
    while (my ($i, $rec) = each@mins)
    {
        my $prefix = $rec->{'s'};
        my $suffix = $rec->{strs}->{'s'};

        my $needle = $prefix.$n.$suffix;

        my $pos = calc_start($needle) + length($prefix);
        if (!defined($min) || $pos < $min)
        {
            $last_i = $i;
            $min = $pos;
            $which = 'contained';
        }
    }
    if ($last_i == $#mins)
    {
        push @mins, +{ s => ($next_mins++), strs => {next => Nexter->new([1,1,1]), s => ''} };
    }

    my $last_s;
    for my $start_new_pos (1 .. length($n)-1)
    {
        my $prefix = substr($n, $start_new_pos);
        my $middle = $mm{$start_new_pos}{'s'};
        my $suffix = substr($n, 0, $start_new_pos);

        my $needle = $prefix.$middle.$suffix;

        my $pos = calc_start($needle) + length($prefix)+length($middle);

        if (!defined($min) || $pos < $min)
        {
            $last_s = $start_new_pos;
            $which = 'mid';
            $min = $pos;
        }
    }

    my $rec;
    if ($which eq 'mid')
    {
        $rec = $mm{$last_s};
    }
    else
    {
        $rec = $mins[$last_i]{'strs'};
    }
    $rec->{'s'} = $rec->{'next'}->next;
    print $count++, " $min\n";
}
