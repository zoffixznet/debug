unit class Foo;

my %h;
method c($name, |c) {
    CATCH {
        when $_.message ~~ m/
        ^ "Cannot locate native library "
        ( "'" <-[ ' ]> * "'" )
        / {
            say "here";
        }
        default {
            say "there";
            .throw;
        };
    }
    self.x: $name, |c;
    %h{$name}.y: |c;
}
method x($name, |c) {
    %h{$name} //= do {
        my \M = (require ::($name));
    }
}
