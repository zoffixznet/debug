
use Mojolicious::Lite;

use File::Spec::Functions qw/curdir rel2abs catdir updir/;
$ENV{SASS_PATH} = catdir rel2abs(updir), qw{public2 sass};

push @{ app->static->paths }, '../public2';

plugin "bootstrap3";
# plugin "AssetPack";

app->asset( 'app.css' => '/sass/main.scss' );

get "/" => "index";
app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html>

%= asset "bootstrap.css"
%= asset "app.css"

<p class="well">First</p>

<p class="two">Second</p>