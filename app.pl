
use Mojolicious::Lite;

plugin "AssetPack";

app->asset( 'app.css' => '/sass/x/y/z/main.scss' );

get "/" => "index";
app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html>

%= asset "app.css"

