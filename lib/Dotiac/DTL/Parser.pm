###############################################################################
#Parser.pm
#Last Change: 2009-01-19
#Copyright (c) 2009 Marc-Seabstian "Maluku" Lucksch
#Version 0.5
####################
#This file is part of the Dotiac::DTL project. 
#http://search.cpan.org/perldoc?Dotiac::DTL
#
#Parser.pm is published under the terms of the MIT license, which basically 
#means "Do with it whatever you want". For more information, see the 
#license.txt file that should be enclosed with libsofu distributions. A copy of
#the license is (at the time of writing) also available at
#http://www.opensource.org/licenses/mit-license.php .
###############################################################################

package Dotiac::DTL::Parser;
require Dotiac::DTL::Tag;
require Dotiac::DTL::Filter;
require Dotiac::DTL::Variable;
require Dotiac::DTL::Comment;

use strict;
use warnings;

sub new {
	my $class=shift;
	my $self={};
	bless $self,$class;
	return $self;
}

sub unparsed {
	my $self=shift;
	my $template=shift;
	my $pos=shift;
	my $start=$$pos;
	my @end = @_;
	my $found;
	my $starttag;
	$found=shift @end if @end;
	$starttag=shift @end if @end;
	my @starttag;
	@starttag = ($starttag) if $starttag and not ref $starttag;
	@starttag = @{$starttag} if $starttag and ref $starttag eq "ARRAY";
	my $text;
	local $_;
	while (1) {
		my $p = index($$template,"{",$$pos);
		if ($p >=0) {
			$$pos=$p+1;
			my $n = substr $$template,$$pos,1;
			if ($n eq "%") {
				my $text .= substr $$template,$start,$$pos-$start-1;
				my $npos = index($$template,"%}",++$$pos);
				die "Missing closing %} at char $$pos" if $npos < 0;
				my $cont=substr $$template,$$pos,$npos-$$pos;
				$$pos=$npos+2;
				my $c=$cont;
				$cont=~s/^\s+//;
				$cont=~s/\s+$//;
				my ($tagname,$param) = split /\s+/,$cont,2;
				$tagname=lc $tagname;
				$$found = $c and return $text if $found and grep {$_ eq $tagname} @end;
				$text .= "{\%$c\%}";
				$text .= $self->unparsed($template,$pos,@_) if $found and grep {$_ eq $tagname} @starttag;
				$text .="{\%$$found\%}";
				$$found="";				
			}
		}
		else {
			$$pos=length $$template;
			return $text
		}
	}
}


sub parse {
	my $self=shift;
	my $template=shift;
	my $pos=shift;
	my $start=$$pos;
	my @end = @_;
	my $found;
	$found=shift @end if @end;
	local $_;
	while (1) {
		my $p = index($$template,"{",$$pos);
		if ($p >=0) {
			$$pos=$p+1;
			my $n = substr $$template,$$pos,1;
			if ($n eq "%") {
				my $pre = substr $$template,$start,$$pos-$start-1;
				my $npos = index($$template,"%}",++$$pos);
				die "Missing closing %} at char $$pos" if $npos < 0;
				my $cont=substr $$template,$$pos,$npos-$$pos;
				$$pos=$npos+2;
				$cont=~s/^\s+//;
				$cont=~s/\s+$//;
				my ($tagname,$param) = split /\s+/,$cont,2;
				$tagname=lc $tagname;
				$$found = $tagname and return Dotiac::DTL::Tag->new($pre) if $found and grep {$_ eq $tagname} @end;
				my $r;
				eval {$r="Dotiac::DTL::Tag::$tagname"->new($pre,$param,$self,$template,$pos);};
				if ($@) {
					die "Error while loading Tag '$tagname' from Dotiac::DTL::Tag::$tagname. If this is an endtag (like endif) then your template is unbalanced\n$@";
				}
				#print "\n\nold: $npos, new $$pos, lenght=".length $$template and die if $tagname eq "extends";
				#warn $$pos," ",length $$template,"\n";
				if ($$pos >= length $$template) {
					$r->next(Dotiac::DTL::Tag->new(""));
				}
				else {
					$r->next($self->parse($template,$pos,@_));
				}
				return $r;
				
			}
			elsif ($n eq "{") {
				my $pre = substr $$template,$start,$$pos-$start-1;
				my $npos = index($$template,"}}",++$$pos);
				die "Missing closing }} at char $$pos" if $npos < 0;
				my $cont=substr $$template,$$pos,$npos-$$pos;
				$$pos=$npos+2;
				return Dotiac::DTL::Variable->new($pre,$cont,$self->parse($template,$pos,@_));
			}
			elsif ($n eq "#") {
				my $pre = substr $$template,$start,$$pos-$start-1;
				my $npos = index($$template,"#}",++$$pos);
				die "Missing closing #} at char $$pos" if $npos < 0;
				my $cont=substr $$template,$$pos,$npos-$$pos;
				$$pos=$npos+2;
				return Dotiac::DTL::Comment->new($pre,$cont,$self->parse($template,$pos,@_));
			}
		}
		else {
			$$pos=length $$template;
			return Dotiac::DTL::Tag->new(substr $$template,$start);
		}
	}
}

1;
__END__
=head1 NAME

Dotiac::DTL::Template - A Dotiac/Django template.

=head1 SYNOPSIS

	require Dotiac::DTL;
	$t=Dotiac::DTL->new("file.html")
	$t->print();

=head2 Static methods

=head3 new(FILE) or new(FILE,COMPILE)

Creates a new empty Dotiac::DTL::Template, don't use this, use Dotiac::DTL->new(FILE,COMPILE).

=head2 Methods

=head3 param(NAME, VALUE)

Works like HTML::Templates param() method, will set a param that will be used for output generation.

	my $t=Dotiac::DTL->new("file.html");
	$t->param(FOO=>"bar");
	$t->print();
	#Its the same as:
	my $t=Dotiac::DTL->new("file.html");
	$t->print({FOO=>"bar"});

=over

=item NAME

Name of the parameter.

=item VALUE

Value to set the parameter to.

=back

Returns the value of the param NAME if VALUE is skipped.

=head3 string(HASHREF)

Returns the templates output.

=over

=item HASHREF

Parameters to give to the template. See Variables below.

=back

=head3 output(HASHREF) and render(HASHREF)

Same as string(HASHREF) just for HTML::Template and Django syntax.

=head3 print(HASHREF) 

You can think of these two being equal:

	print $t->string(HASHREF);
	$t->print(HASHREF);

But string() can cause a lot of memory to be used (on large templates), so print() will print to the default output handle as soon as it has some data, which uses a lot less memory.

=head1 SEE ALSO

L<http://www.djangoproject.com>, L<Dotiac::DTL>

=head1 BUGS

If you find a bug, please report it.

=head1 LEGAL

Dotiac::DTL was built according to http://docs.djangoproject.com/en/dev/ref/templates/builtins/.

=head1 AUTHOR

Marc-Sebastian Lucksch

perl@marc-s.de

=cut
