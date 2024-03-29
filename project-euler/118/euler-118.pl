#!/usr/bin/perl

use strict;
use warnings;

use bytes;

use List::MoreUtils qw(all);
use List::Util qw(sum);

=head1 DESCRIPTION

Using all of the digits 1 through 9 and concatenating them freely to form
decimal integers, different sets can be formed. Interestingly with the set
{2,5,47,89,631}, all of the elements belonging to it are prime.

How many distinct sets containing each of the digits one through nine exactly
once contain only prime elements?

=cut

sub is_prime
{
    my $n = shift;

    return all { $n % $_ } (2 .. int(sqrt($n)));
}

# print "is_prime(2963) = ", is_prime(2963), "\n";
# print "is_prime(2962) = ", is_prime(2962), "\n";

my @sets_by_rank;

push @sets_by_rank, undef();
push @sets_by_rank,
    {
        map {
            my $p = $_;
            my $s = '';
            vec($s, $p, 1) = 1;
            $s => { $p => 1 };
        } qw(2 3 5 7),
    };

RANK_LOOP:
foreach my $rank (2 .. 9)
{
    print "Reached rank $rank\n";

    my $sets = {};
    push @sets_by_rank, $sets;

    # Make out sets of sub sets.
    foreach my $sub_rank (1 .. int($rank/2))
    {
        my $other_sub_rank = $rank-$sub_rank;

        my $sub_sets = $sets_by_rank[$sub_rank];
        my $other_sub_sets = $sets_by_rank[$other_sub_rank];

        my $compose = sub {
            my ($sub_vec, $other_sub_vec) = @_;
            # Check if the sets are mutually exclusive so they can be
            # composed.
            if (($sub_vec & $other_sub_vec) !~ m{[^\0]})
            {
                my $total_vec = ($sub_vec|$other_sub_vec);

                my $record = ($sets->{$total_vec} ||= {});

                foreach my $sub_k (keys(%{$sub_sets->{$sub_vec}}))
                {
                    foreach my $o_k (keys(%{$other_sub_sets->{$other_sub_vec}}))
                    {
                        my $signature =
                            join(",", sort { $a <=> $b }
                                split(",", "$sub_k,$o_k")
                            );
                        $record->{$signature} = 1;
                    }
                }
            }

            return;
        };

        if ($sub_rank == $other_sub_rank)
        {
            my @sub_keys = keys(%$sub_sets);
            foreach my $idx (0 .. $#sub_keys-1)
            {
                foreach my $other_idx ($idx+1 .. $#sub_keys)
                {
                    $compose->(@sub_keys[$idx,$other_idx]);
                }
            }
        }
        else
        {
            foreach my $sub_vec (keys(%$sub_sets))
            {
                foreach my $other_sub_vec (keys (%$other_sub_sets))
                {
                    $compose->($sub_vec, $other_sub_vec);
                }
            }
        }
    }

    # 1+2+3+4+5+6+7+8+9 is evenly divisible by 3 and so numbers which are
    # composed of them as digits can never be prime, so there's no reason
    # to check.
    if ($rank == 9)
    {
        next RANK_LOOP;
    }

    # Now let's find the complete numbers with $rank digits out of [1..9].

    # The ending digit cannot be even or 5 because then the number won't
    # be prime.
    foreach my $ending_digit (qw(1 3 7 9))
    {

        my $recurse;

        $recurse = sub {
            my ($num_so_far, $vec) = @_;

            if (length($num_so_far) == $rank)
            {
                if (is_prime($num_so_far))
                {
                    $sets->{$vec}->{$num_so_far} = 1;
                }
            }
            else
            {
                foreach my $digit (1 .. 9)
                {
                    if (! vec($vec, $digit, 1))
                    {
                        my $new_vec = $vec;
                        vec($new_vec, $digit, 1) = 1;
                        $recurse->( $digit.$num_so_far, $new_vec );
                    }
                }
            }

            return;
        };

        my $init_vec = '';
        vec($init_vec, $ending_digit, 1) = 1;

        $recurse->($ending_digit, $init_vec);
    }

}

print "Num sets == ",
    sum (map { scalar keys(%$_) } values(%{$sets_by_rank[-1]})),
    "\n";
