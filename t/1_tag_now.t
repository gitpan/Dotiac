use Test::More tests=>6;
chdir "t";
no warnings;
BEGIN {
	*CORE::GLOBAL::time = sub { return 1294484984 };
	*CORE::GLOBAL::localtime = sub { return(gmtime($_[0])) };
}

require Dtest;
use warnings;
use strict;

dtest("tag_now.html","p.m.PMjan08Sat11:09January1111 1111of098Saturday001Jan1Jan.+000011:09 p.m.Sat, 1 Jan 2011 11:9:44 +000044th30w011120117\n",{});
