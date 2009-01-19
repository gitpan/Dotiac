use Test::More tests=>6;
chdir "t";
require Dtest;
use Dotiac::DTL::Addon::unparsed;
dtest("special_unparsed_noload.html","A{{ X }}A{% unparsed %}{{ X }}{% endunparsed %}A{{ Z }}\n",{});
