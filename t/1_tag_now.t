use Test::More tests=>6;
chdir "t";
no warnings;
BEGIN {
	*CORE::GLOBAL::time = sub { return 1294484984 };
}

require Dtest;
use warnings;
use strict;

dtest("tag_now.html","a.m.AMjan08Sat12:09January1212 1212of098Saturday001Jan1Jan.+010012:09 a.m.Sat, 1 Jan 2011 12:9:44 +010044th30w011120117\n",{});
