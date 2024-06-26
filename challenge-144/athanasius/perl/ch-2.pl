#!perl

###############################################################################
=comment

Perl Weekly Challenge 144
=========================

TASK #2
-------
*Ulam Sequence*

Submitted by: Mohammad S Anwar

You are given two positive numbers, $u and $v.

Write a script to generate Ulam Sequence having at least 10 Ulam numbers where
$u and $v are the first 2 Ulam numbers.

For more information about Ulam Sequence, please checkout the
[ https://en.wikipedia.org/wiki/Ulam_number |website].

    The standard Ulam sequence (the (1, 2)-Ulam sequence) starts with U1 = 1
    and U2 = 2. Then for n > 2, Un is defined to be the smallest integer that
    is the sum of two distinct earlier terms in exactly one way and larger than
    all earlier terms.

Example 1

 Input: $u = 1, $v = 2
 Output: 1, 2, 3, 4, 6, 8, 11, 13, 16, 18

Example 2

 Input: $u = 2, $v = 3
 Output: 2, 3, 5, 7, 8, 9, 13, 14, 18, 19

Example 3

 Input: $u = 2, $v = 5
 Output: 2, 5, 7, 9, 11, 12, 13, 15, 19, 23

=cut
###############################################################################

#--------------------------------------#
# Copyright © 2021 PerlMonk Athanasius #
#--------------------------------------#

#==============================================================================
=comment

Algorithm
---------
@ulams is an array containing Ulam numbers in the order of their discovery.
%sums  is a hash matching each sum of two distinct Ulam numbers to a count of
       the number of different ways in which that sum can be produced.

The main loop generates one new Ulam number per iteration, as follows:
    - New sums are generated by adding the latest (i.e. last found) Ulam number
      $last to each of the previously-known Ulam numbers.
    - The next Ulam number is the smallest key in %sums which (1) is greater
      than $last and (2) has a count of 1.

Note that %sums is pruned on each iteration of the main loop by deleting all
the sums less than or equal to $last. This is not strictly necessary (a
different logic could be used), but has two advantages:
    1. It simplifies the logic, as the smallest candidate Ulam number is
       guaranteed to be greater than $last.
    2. It prevents %sums from becoming unnecessarily large in memory. (This is
       not a consideration when $TARGET = 10, but could become significant for
       large values of $TARGET.)

Performance
-----------
On my machine, the first 10,000 Ulam numbers for $u = 1, $v = 2 (see
https://oeis.org/A002858/b002858.txt) are generated in around 15 min 33 sec.

Note that each Ulam number is displayed as it is found. This allows the user to
monitor progress when using large values of $TARGET.

=cut
#==============================================================================

use strict;
use warnings;
use Const::Fast;
use List::Util     qw( min );
use Regexp::Common qw( number );
use constant TIMER =>  0;               # Compile-time constant

const my $TARGET   => 10;               # Run-time constants
const my $USAGE    =>
"Usage:
  perl $0 <u> <v>

    <u>    A positive integer
    <v>    A positive integer > u\n";

#------------------------------------------------------------------------------
BEGIN
#------------------------------------------------------------------------------
{
    $| = 1;
    print "\nChallenge 144, Task #2: Ulam Sequence (Perl)\n\n";
}

#==============================================================================
MAIN:
#==============================================================================
{
    use if TIMER, 'Time::HiRes' => qw( gettimeofday tv_interval );

    my $t0    = [gettimeofday] if TIMER;
    my @ulams = parse_command_line();
    my $last  = $ulams[ 1 ];
    my %sums;

    printf "Input:  \$u = %d, \$v = %d\nOutput: %d, %d", @ulams, @ulams;

    while (scalar @ulams < $TARGET)
    {
        ++$sums{ $_ + $last } for @ulams[ 0 .. $#ulams - 1 ];

        $last = min grep { $sums{ $_ } == 1 } keys %sums;

        push @ulams, $last;
        print ", $last";

        $_ <= $last && delete $sums{ $_ } for keys %sums;
    }

    print "\n";
    my $t = tv_interval( $t0 ) if TIMER;
    print "\n$t seconds\n"     if TIMER;
}

#------------------------------------------------------------------------------
sub parse_command_line
#------------------------------------------------------------------------------
{
    my $args = scalar @ARGV;
       $args == 2 or error( "Expected 2 command line arguments, found $args" );

    for (@ARGV)
    {
        / ^ $RE{num}{int} $ /x
                  or error( qq["$_" is not a valid integer] );

        $_ > 0    or error( "$_ is not positive" );
    }

    my ($u, $v) = @ARGV;

    $v > $u       or error( "$v is not greater than $u" );

    return ($u, $v);
}

#------------------------------------------------------------------------------
sub error
#------------------------------------------------------------------------------
{
    my ($message) = @_;

    die "ERROR: $message\n$USAGE";
}

###############################################################################
