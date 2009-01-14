use Test::More tests=>12;
chdir "t";
require Dtest;
#require Dotiac::DTL::Addon::unparsed;
dtest("special_unparsed.html","A{{ X }}A{% unparsed %}{{ X }}{% endunparsed %}A{{ Z }}\n",{});
dtest("dir/subinc.html","ABACAB\nA\n",{});
