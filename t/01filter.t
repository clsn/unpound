#!/usr/bin/env perl -w

use Test::More "no_plan";
use strict;

is(qx"$^X samplecode.pl",
   <<'EEOOFF', "no unpounding.");
Begin.
Always.
Text with #line# and #inline# stuff.
Maybe dangerous with #danger58> in v5.8
All Done.
EEOOFF
;



is(qx"$^X -MFilter::Unpound=line samplecode.pl",
   <<'EEOOFF', "unpound line");
Begin.
. 'line'
. Auto-print > 'line'

. Auto-print #> 'line'; (var)

Always.
Text with #line# and #inline# stuff.
. For 'line' _or_ 'inline'
Maybe dangerous with #danger58> in v5.8
All Done.
EEOOFF
    ;


is(qx"$^X -MFilter::Unpound=inline samplecode.pl",
   <<'EEOOFF', "unpound inline");
Begin.
Always.
. 'inline'
Text with #line# and #inline# stuff.
. For 'line' _or_ 'inline'
Maybe dangerous with #danger58> in v5.8
All Done.
EEOOFF
    ;


is(qx"$^X -MFilter::Unpound=line,inline samplecode.pl",
   <<'EEOOFF', "unpound line and inline");
Begin.
. 'line'
. Auto-print > 'line'

. Auto-print #> 'line'; (var)

Always.
. 'inline'
Text with #line# and #inline# stuff.
. For 'line' _or_ 'inline'
. For 'line' _and_ 'inline'
Maybe dangerous with #danger58> in v5.8
All Done.
EEOOFF
    ;



is(qx"$^X -MFilter::Unpound=multi samplecode.pl",
   <<'EEOOFF', "unpound multi");
Begin.
Always.
Text with #line# and #inline# stuff.
Maybe dangerous with #danger58> in v5.8
.. Multi-line, 'multi'
.. Treatment of ( #multi# ) depends on version.
All Done.
EEOOFF
;


is(qx"$^X -MFilter::Unpound=unmulti samplecode.pl",
   <<'EEOOFF', 'unpound unmulti');
Begin.
Always.
Text with #line# and #inline# stuff.
Maybe dangerous with #danger58> in v5.8

.. Multi-line, 'unmulti'
.. variable declared


.. Multi-line, 'unmulti'; undeclared.
All Done.
EEOOFF
    ;
