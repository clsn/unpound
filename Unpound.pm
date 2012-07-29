package Filter::Unpound;
# Simplest version, just this line:
# use Filter::Simple sub { s/^\s*#!#//gsm; };
use strict;

my @keywords;
my $CmtRE;
sub import {
    print Dumper \@_;
    my $thispack=shift;
    @keywords=@_;
    @keywords=(grep !/[^A-Za-z0-9_]/, @keywords); # Only single words, no metachars, ok?
    $CmtRE=join q(|),@keywords;
    print Dumper $CmtRE
}

use Filter::Simple;

FILTER_ONLY 
    code => sub {
	s/#[A-Za-z0-9_#]*\b(?:${CmtRE})\b[A-Za-z0-9_#]*#//aag;	
},
    all => sub {
	s/^\s*${CmtRE}\s*$//aagms;
	s/^\s*;\s*<<\s*'${CmtRE}\s*;'//aagms;
};
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

    ;<<'foo';
    print "This code is normally ignored, just shoved into a string.\n";
    foo
    

The string comment header must appear just as shown: on its own line, with
the keyword surrounded by single quotes and followed by a semicolon, and
the << must be preceded by a semicolon (just in case you have some code
that uses a here-string that starts on its own line; the semicolon makes
the string unusable for anything, so it can't be purposeful in your code).

=head1 LIMITATIONS

=over 4

=item -

The tags used must be simple ASCII words, consisting only of letters,
numbers, and underscores.

=item -

Although you can use your keywords inside quotes in ordinary code without
their being affected by deletion, they will be affected in quotes inside
uncommented code.  That is:

    print "This line will print #foo# and #bar# properly no matter what.\n";
    #foo# print "But when uncommented, this (#foo#) will be empty.\n";
    #foo# print "If foo and bar are both selected, (#bar#) is empty too.\n";
    #foo# print "But this only affects the words when surrounded by #s.\n";

Basically, giving X as a parameter will cause C<#X#> to disappear
everywhere in the I<code>, but not in strings.  However, strings that were
commented out I<before> the filtering count as code too.

=back

=cut
