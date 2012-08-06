#!/usr/bin/env perl -w
use Test::More "no_plan";
use strict;

is(qx"$^X oneorother.pl",
   <<'EEOOFF', "no debug");
Start
Debugging is OFF
Multi-line debugging... ... is OFF
EEOOFF
    ;


is(qx"$^X -MFilter::Unpound=debug oneorother.pl",
   <<'EEOOFF', "debug enabled");
Start
. Debugging is ON
But multi-line debugging... ... is ON
EEOOFF
    ;

