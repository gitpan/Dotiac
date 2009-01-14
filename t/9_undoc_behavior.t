use Test::More tests=>6;
chdir "t";

require Dtest;

dtest("undoc_cycle.html","ABACABA\n",{});
