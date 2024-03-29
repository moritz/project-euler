#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use Euler91;

# TEST
is (get_num_O_right_angle_triangles(2,2), 4, "2*2 O triangles");

# TEST
is (get_num_other_triangles(2,2), 10, "2*2 O triangles");

print get_num_O_right_angle_triangles(50,50)+get_num_other_triangles(50,50), "\n";
