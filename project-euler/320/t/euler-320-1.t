#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 11;

use Euler320 qw(factorial_factor_exp find_exp_factorial);

{
    # TEST
    is (
        factorial_factor_exp(5, 5),
        1,
        "f 5,5 ==> 1",
    );

    # TEST
    is (
        factorial_factor_exp(10, 5),
        2,
        "f 10,5 ==> 2",
    );

    # TEST
    is (
        factorial_factor_exp(1000, 5),
        (1000/5+1000/25+int(1000/125)+int(1000/625)),
        "f 1000,5 ==> correct",
    );

    # TEST
    is (
        factorial_factor_exp(16, 2),
        (8+4+2+1),
        "f 16,2 ==> correct",
    );

    # TEST
    is (
        factorial_factor_exp(17, 2),
        (8+4+2+1),
        "f 17,2 ==> correct",
    );

    # TEST
    is (
        factorial_factor_exp(18, 2),
        (8+4+2+1+1),
        "f 18,2 ==> correct",
    );
}

{
    # TEST
    is (
        find_exp_factorial(5,
            (1000/5+1000/25+int(1000/125)+int(1000/625)),
            1,
            10
        ),
        1000,
        "find_exp 5 ==> 1,000",
    );

    # TEST
    is (
        find_exp_factorial(
            5,
            1,
            1,
            2,
        ),
        5,
        "find_exp 5,1 ==> 5",
    );

    # TEST
    is (
        find_exp_factorial(
            5,
            1,
            1,
            100,
        ),
        5,
        "find_exp 5,1 [1-100] ==> 5",
    );

    # TEST
    is (
        find_exp_factorial(
            5,
            6,
            1,
            100,
        ),
        25,
        "find_exp 5,6 [1-100] ==> 25",
    );

    # TEST
    is (
        find_exp_factorial(
            5,
            5,
            1,
            100,
        ),
        25,
        "find_exp 5,5 [skipping 5, 1-100] ==> 25",
    );
}
