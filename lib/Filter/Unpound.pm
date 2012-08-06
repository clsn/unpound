package Filter::Unpound;
# Simplest version, just this line:
# use Filter::Simple sub { s/^\s*#!#//gsm; };
use strict;

my @keywords;
my $CmtRE;
my ($code,$all);
our $VERSION=1.0;

sub import {
    my $thispack=shift;
    @keywords=@_;
    @keywords=(grep !/[^A-Za-z0-9_]/, @keywords); # Only single words, no metachars, ok?
    $CmtRE=join q(|),@keywords;
    # Only filter if things are specified, otherwise we'll remove way too
    # many comments.
    if ($CmtRE) {
	$code=sub {	    
	    # Shorthand for print
	    s/#[A-Za-z0-9_#]*\b(?:${CmtRE})\b[A-Za-z0-9_#]*>\s+(.*)$/print <<fFilLTereD\n$1\nfFilLTereD\n;/gm;
	    s/#[A-Za-z0-9_#]*\b(?:${CmtRE})\b[A-Za-z0-9_#]*#\s+//g;
	};
	
	$all=sub {
	    s/^(?:${CmtRE})$//gms;
	    s/^\s*;\s*(?:(?:my\s+)?\$__UNPOUND\s*=)?\s*<<\s*'(?:${CmtRE})'//gms;
	}
    }
    else {
	$code=sub { ; };
	$all=sub { ; };
    }
}
# Allow access to keywords, commentre...
sub keywords { return @keywords; }
sub CmtRE { return $CmtRE; }

use Filter::Simple;

# As I discovered with pain, since I was working on a v5.8
# installation, Filter::Simple has a bug in FILTER_ONLY in v5.8, but
# not in v5.10 (I don't know about v5.9).  So versions below v5.10
# will get a plain FILTER.

if ($] >= 5.010) {    
    FILTER_ONLY
	code => sub { &$code },
	all => sub { &$all };
}
else {
    FILTER {
	&$code;
	&$all;
    }
}
1;
__END__

=head1 NAME

Unpound - Simple "uncomment" debugging.

=head1 SYNOPSIS

    # Some code executing...
    #trace# print "Entered subroutine.\n";
    $foo=&bar();
    #debug# print "\$foo: $foo\n";
    $rv=$foo/17;    #debug# print "Inline comment: \$rv is $rv\n";
    #debug#trace# print "About to return $rv\n";

=head1 DESCRIPTION

An even more simplified source filter, based on Filter::Simple and somewhat
like Filter::Uncomment, but with a different syntax that might be easier to
work with.

Anything commented out by a comment in the form #word# can be uncommented
by including this package with suitable arguments.  Essentially, if you
execute

    perl -MFilter::Unpound=word script.pl

then the string "#word#" is removed wherever it may appear in the code--
which may then expose some previously commented-out instructions.  You can
have several different "uncomment" tags and use them selectively.  A line
tagged with more than one, as above, is activated if I<any> one is
activated.  You can make it have to have I<all> the tags this way:

   #foo#bar# print "This line prints with either foo or bar.\n";
   #foo# #bar# print "This line prints only with both.\n";

You would have to say C<perl -MFilter::Unpound=foo,bar> to get the second
line to print, whereas either C<perl -MFilter::Unpound=foo> or C<perl
-MFilter::Unpound=bar> will suffice for the first.

You can also uncomment multi-line pieces of code which are ordinarily
commented out by wrapping them in a special "string comment" using Perl
here-strings.

    ;<<'foo'
    print "This code is normally ignored, just shoved into a string.\n";
    foo
    ;

    ;my $__UNPOUND=<<'bar'
    print "Also ignored code.\n";
    print "The special UNPOUND dummy variable is for avoiding warnings\n";
    bar
    ;

    ;$__UNPOUND=<<'lastly'
    print "Same as above... ";
    print "(except didn't declare $UNPOUND again.)\n";
    lastly
    ;

The string comment header must appear just as shown: on its own line,
with the keyword surrounded by single quotes, and the << must be
preceded by a semicolon (just in case you have some code that uses a
here-string that starts on its own line; the semicolon makes the
string unusable for anything, so it can't be purposeful in your code.)
Note that this will cause "void" warnings (during ordinary, not
Unpounded, execution) if you have those enabled.  You can optionally
assign to a variable called $__UNPOUND (you have to use that name) if
you want to avoid the warnings.  You can also optionally declare
$__UNPOUND with "my" on the line as shown above.  When "foo" is
selected, Unpound will delete lines that look like ";<<'foo'" and
lines that have only "foo" on them, so this code will be uncommented.

=head2 One or the Other

You can even use this to set up code to be B<commented>, so you can
have code that acts one way when debugging is off and does I<something
else> (not just more things) when debugging is on.  Consider:

    #debug# print "Doing debugging things.\n";
    
    #debug# ;<<'XxXxXx';
    print "Doing normal things, which will NOT be done when debugging.\n";
    #debug# XxXxXx
    #debug# ;

The "normal" code is eaten into the dummy string when debug is
selected.  Make sure there is no whitespace after your string
terminator (Unpound will eat the whitespace before it)

=head2 Print Shorthand

Since most of the time debugging statements are print statements, you can
save the hassle of typing "print" (or even "say") all the time by ending
your single-line tag with '>'.  The rest of the line (after whitespace)
will be taken as a double-quoted string to be printed, followed by a
newline.  The line is quoted as a here-string, so there shouldn't be any
problems with accidental end-quoting.

This feature is not available for multi-line uncomments.

=head1 LIMITATIONS

=over 4

=item -

The tags used must be simple ASCII words, consisting only of letters,
numbers, and underscores.

=item -

Although you can use your keywords inside quotes in ordinary code without
their being affected by deletion, they will be affected in quotes inside
code that becomes uncommented.  That is:

    print "This line will print #foo# and #bar# properly no matter what.\n";
    #foo# print "But when uncommented, this (#foo#) will be empty.\n";
    #foo# print "If foo and bar are both selected, (#bar#) is empty too.\n";
    #foo# print "But this only affects the words when surrounded by #s.\n";

Basically, giving X as a parameter will cause C<#X#> to disappear
everywhere in the I<code>, but not in strings.  However, strings that were
commented out I<before> the filtering count as code too.

This can produce some some unfortunate issues.  Consider:

     #keyword# print "This is a string with #keyword> in it.";

Since the auto-print feature does more than just delete its keyword, also
eating the rest of the line, this will expand to:

    print "This is a string with a print<<fFilLTereD
    in it.";
    fFilLTereD
    ;

Which naturally is not going to sit well with the rest of the parser.
Moral of the story: avoid keywords that might occur inside strings with
#-signs in front of/around them.

=over 4

=item NOTE

The above applies to Perl versions 5.10 and above.  Due to a bug in
Filter::Simple in lower versions of Perl, filtering only the code can
produce bizarre and unexpected bugs in the presence of things like
here-strings or formats, so Unpound will filter code, strings, and all on
those versions (Ref. L<http://www.perlmonks.org/?node_id=513511>).  That
means that the above-referenced problem with C<#keyword> can happen even in
non-unpounded strings on lower versions of perl.

=back

=item -

To use Unpound inside a module which is going to be included via
C<use> from somewhere else, you have to get sneaky.  Orinarily, the
filters that apply to the base program don't reach into included
libraries, which makes sense, since those libraries might have been
written by anyone.  But sometimes you want to debug a library I<in
situ>, where it's being used by another program already.  For that,
you have to do some work at the top of the module to explicitly
"inherit" Unpound.  Even though this is flagged with BEGIN, it won't
apply to stuff before it in your file, presumably because all import
stuff is in BEGIN anyway.  So put this at the B<top> of your file.

    # For use with Unpound for debugging
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

Unfortunately, this code doesn't disappear into harmless comments when
there's no Unpound in use (though it does disappear into harmless
code).

=item -

Tricks like multi-line comments have to be used between statements,
not within them, so you can't do stuff like uncommenting part of a
list with them.

=back

=cut
