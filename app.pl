
use Mojolicious::Lite;

plugin "AssetPack";

app->asset( 'app.css' => 'sprites:///sprite' );

get "/" => "index";
app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html>

%= asset "app.css"

<p>
    <i class="sprite WebService_GitHub"></i>
    <i class="sprite panda"></i>
</p>
