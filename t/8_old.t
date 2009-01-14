use Test::More tests=>6;
chdir "t";
require Dtest;

dtest("old_cycle.html","ABACABA\n",{loop=>[1 .. 4]});
