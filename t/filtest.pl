$\="\n";
$a="(stuff in a variable)";
print "Beginning, outside all.";
#line# print ".Protected by keyword 'line'";
# Auto-prints have extra newlines, since they add a newline in addition
# to the setting of $\.  I'm not sure I consider that a bug.
#line> .Auto-print, protected by keyword 'line', no closing #.
#line#> .Auto-print, protected by 'line', closing #, \$a has $a.

print "Print this always.";	#inline# print ".But this only with 'inline'";
print "Print always, talk about #line# and #inline# stuff.";
print "(that should look different in different versions)";

print "Always, but dangerous in v5.8 with #line> which can be a syntax error!";

#danger1> This could also be dangerous, with #danger1> in it.
#danger2# print "And what about printing with #danger2> in the line?"

{ no warnings;
;<<'multi'
    print "..Multi-line comment, protected by 'multi'";
    print "..Words like #multi# *may* be affected.";
multi
    ;
};

;my $__UNPOUND = <<'unmulti'
    print "\n..More multi-line, this time shoved into \$__UNPOUND\n";
    print "..so as to avoid warnings.\n";
unmulti
    ;

; $__UNPOUND=<<'unmulti'
    print "\n..Last, same as above, but undeclared.\n"
unmulti
    ;

#line#inline# print ".For 'line' _or_ 'inline'";
#line# #inline# print ".For 'line' _and_ 'inline'";

print "All Done.";
