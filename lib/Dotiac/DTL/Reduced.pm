###############################################################################
#Reduced.pm
#Last Change: 2008-12-15
#Copyright (c) 2006 Marc-Seabstian "Maluku" Lucksch
#Version 0.1
####################
#This file is part of the Dotiac::DTL project. 
#http://search.cpan.org/perldoc?Dotiac::DTL
#
#Reduced.pm is published under the terms of the MIT license, which basically 
#means "Do with it whatever you want". For more information, see the 
#license.txt file that should be enclosed with libsofu distributions. A copy of
#the license is (at the time of writing) also available at
#http://www.opensource.org/licenses/mit-license.php .
###############################################################################

package Dotiac::DTL::Reduced;
BEGIN {
	require Dotiac::DTL::Filter;
	require Dotiac::DTL::Compiled;
	require Dotiac::DTL::Core;
};
use Exporter;
require File::Spec;

our @EXPORT=();
our @EXPORT_OK=qw/Context Template/;
sub Template {
	my $file=shift;
	if (-e $file) {
	}
	elsif (-e "$file.html") {
		$file="$file.html" 
	}
	elsif (-e "$file.txt") {
		$file="$file.txt" ;
	}
	else {
		foreach my $dir (@Dotiac::DTL::TEMPLATE_DIRS) {
			$file=File::Spec->catfile($dir,"$file.html") and last if -e File::Spec->catfile($dir,"$file.html");
			$file=File::Spec->catfile($dir,"$file.txt") and last if -e File::Spec->catfile($dir,"$file.txt");
			$file=File::Spec->catfile($dir,$file) and last if -e File::Spec->catfile($dir,$file);
		}
	}
	return Dotiac::DTL->new($file,@_) if -e $file;
	return Dotiac::DTL->new(\$file,@_);
}

sub Context {
	return $_[0];
}
1;

__END__

=head1 NAME

Dotiac::DTL::Reduced - Dotiac::DTL without the parser.

=head1 SYNOPSIS

	require Dotiac::DTL::Reduced;
	$t=Dotiac::DTL->new("compiled.html") #Works only with compiled templates
	$t->print();

=head1 DESCRIPTION

Dotiac::DTL::Reduced is a version of Dotiac::DTL that contains everything needed to run compiled templates. The other stuff, i.e. parser and Tags are not loaded, so it should save some memory.

I recon it makes almost no difference at all with mod_perl or FastCGI, but having all the tag modules parsed for nothing will impact normal CGI performance.

See L<Dotiac::DTL::Compiled> for pros and cons of compiled templates.

B<Note> This will only run compiled templates, if your compiled template includes a normal template, it will die.

It will also create a warning when the template is outdated and needs to be recompiled.

=head2 Compiling templates

Since Dotiac::DTL::Reduced will only work with compiled templates, you can use this litte script to compile all templates in the current folder:

	require Dotiac::DTL; #Not Reduced here, we need the parser for this.
	Dotiac::DTL->newandcompile($_) foreach (<*.html>); #You might have to change this to whatever file extension you are using.

But see L<Dotiac::DTL::Compiled> before you do this to read up on compiled template pros and cons.

You will also have to recompile everytime you change something. The above script will only compile the changed files in that case.

=head2 Changes from the normal Dotiac::DTL

Everything discriped in L<Dotiac::DTL> and L<Dotiac::DTL::Core> still applies here except:

=head3 new(FILENAME)

Creates a template from a compiled version or loads it from the cache.

=over

=item FILENAME

The filename of the compiled template to open. If you give it a scalarref it will die.

	require Dotiac::DTL::Reduced;
	$t=Dotiac::DTL->new("file.html"); #Will load "file.html.pm" or die.

=item COMPILE

The COMPILE parameter from L<Dotiac::DTL>->new() is ignored. It wouldn't work anyway

=back

Returns a Template object.

=head2 And what about my own compiled templates?

This works like it should: (See L<Dotiac::DTL::Compiled>)

	package MyTemplate;
	sub print {
		my ($vars,$escape)=(shift(),shift());
		print "There are ".keys(%$vars)." parameters registered and x is $vars->{x}\n";
	}
	sub string {
		my ($vars,$escape)=(shift(),shift());
		return "There are ".keys(%$vars)." parameters registered and x is $vars->{x}\n";
	}
	sub eval {
		#nothing for now.
	}
	package main;
	require Dotiac::DTL;
	my $mytemplate=Dotiac::DTL->compiled("MyTemplate");

=head1 BUGS

If you find a bug, please report it.

=head1 SEE ALSO

L<http://www.djangoproject.com>, L<Dotiac::DTL>

=head1 LEGAL

Dotiac::DTL was built according to http://docs.djangoproject.com/en/dev/ref/templates/builtins/.

=head1 AUTHOR

Marc-Sebastian Lucksch

perl@marc-s.de

=cut