package inner2;

BEGIN { 
    no strict;
    if (exists($INC{'Filter/Unpound.pm'})) {
	my @z=Filter::Unpound::keywords;
	# watch for bareword interpretation...
	if (@z && $z[0] ne 'Filter::Unpound::keywords') {
	    # Import throws away the first argument.
	    Filter::Unpound::import("Dummy", @z);
	    # print "about to use with ".(Filter::Unpound::CmtRE)."\n";
	}
    }
}

sub run {
    print "This is the inner2 package\n";
    #debug# print "INNER2: With debugging enabled\n";
}

1;
