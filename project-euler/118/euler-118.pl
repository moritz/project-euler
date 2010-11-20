#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw(all);

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
            # count and made of.
            $s => { c => 1, m => [{ n => $p },],};
        } qw(2 3 5 7),
    };

foreach my $rank (2 .. 8)
{
    my $sets = {};
    # Make out sets of sub sets.
    foreach my $sub_rank (1 .. int($rank/2))
    {
        my $other_sub_rank = $rank-$sub_rank;

        my $sub_sets = $sets[$sub_rank];
        my $other_sub_sets = $sets[$other_sub_rank];

        my $compose = sub {
            my ($sub_vec, $other_sub_vec) = @_;
            # Check if the sets are mutually exclusive so they can be
            # composed.
            if (($sub_vec & $other_sub_vec) eq '')
            {
                my $total_vec = ($sub_vec|$other_sub_vec);

                my $record = ($sets{$total_vec} ||= {c => 0, m => []});

                $record->{c} += 
                    ($sub_sets{$sub_vec}->{c} * 
                        $other_sub_sets{$other_sub_vec}->{c}
                    );

                push @{ $record->{'m'} }, +{s => [$sub_vec, $other_sub_vec]};
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
            foreach my $sub_vec (keys(%$sub_sets)
            {
                foreach my $other_sub_vec (keys (%$other_sub_sets))
                {
                    $compose->($sub_vec, $other_sub_vec);
                }
            }
        }
    }
}
