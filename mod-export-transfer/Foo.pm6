use Bar;
use Meow;

module Foo { sub foo is export { say "foo" } }

sub EXPORT {
    Map.new: (
        | Bar::EXPORT::DEFAULT::,
        |Meow::EXPORT::DEFAULT::,
        | Foo::EXPORT::DEFAULT::
    )
}
