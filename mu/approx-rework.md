# Rework of `is-approx` subroutine offered by `Test.pm6` module

This document describes the changes to be made by Zoffix Znet to `is-approx`
subroutine. The changes will improve usability and fix issues.

## Identified Issues to be Resolved by This Work

### Bug Fixes

This work will fix these bugs:

* [RT#128063](https://rt.perl.org/Ticket/Display.html?id=128063) *[BUG] is-approx multi that takes just two numbers never called*
* [RT#128282](https://rt.perl.org/Ticket/Display.html?id=128282) *[RFC] Use kebab case for named parameters in Test.pm6*
* [RT#128303](https://rt.perl.org/Ticket/Display.html?id=128303) *[BUG] is-approx calculates relative tolerance, instead of absolute*

### Usability Changes

* It will now be possible to use `rel-tol` or `abs-tol` separately
* The naming of `rel-tol` and `abs-tol` now uses kebob-case, for consistency
with other methods and named args in Perl&nbsp;6
* On failures, the errors will be more descriptive and include tolerances

## Non-backwards compatible changes

To the best of the knowledge, the affected interface is not specced, not
in the roast, not even documented, and is half-broken. Thus, if anyone is
affected by the changes, it's only because they relied on Rakudo's source code
to figure out parameters, and it's safe to assume the amount of affected code is near or is zero. The new implementation will be closer to the specced
and documented behaviour.

The changes are:

* `rel-tol` named parameter will not have a default, to allow for standalone use of `abs-tol`
* `abs-tol` named parameter will not have a default, to allow for standalone use of `rel-tol`. **The old default is invalid anyway and is rejected by the subroutine.**
* positional tolerance argument will **always** be taken as absolute tolerance and will default to `1-e5`. This is contrary to current implementation that takes it as relative tolerance set to `1-e6`. Justification for this change:
    * Older implementation used absolute `1-e5` for tiny values and relative `1-e6` for large values (buggy conditional??)
    * The [speculation](https://design.perl6.org/S24.html#is-approx%28%29) declares the tolerance to be absolute with value of `1-e5`
    * The [documentation](http://docs.perl6.org/language/testing#By_approximate_numeric_comparison) declares the tolerance to be absolute with value of `1-e5`
* The old version uses a different algorithm for relative tolerance calculation in named-arg version vs. positional arg version—possibly giving different results as well. In new version, only the named arg version
allow for relative tolerance calculation, ridding the code of this issue.

## Deprecations

* Use of `is_approx` will now trigger a deprecation warning. It was deprecated
for awhile, back when all other subs were renamed to kebob-case, but no
warning was generated nor was it removed from code.
* Use of `rel_tol` and `abs_tol` named parameters will now trigger a deprecation warning. They are to be renamed to kebob-case.

## New additions

* `rel_tol` and `abs_tol` are now named `rel-tol` and `abs-tol` to maintain naming convention for method/sub/params with the rest of the codebase
* `rel-tol` and `abs-tol` can be used independently of another (use of both at the same time is still valid)

## Description of behaviour

This description mostly details the behaviour already present before the
change and is merely an attempt to thoroughly document it.
The differences from it are described in the preceeding sections.

------

The subroutine can be called in numerous ways.
`$rel-tol` is relative tolerance and `$abs-tol` is absolute tolerance:

    my Numeric ($got, $expected, $abs-tol, $rel-tol) = ...

    is-approx $got, $expected;
    is-approx $got, $expected, 'test description';

    is-approx $got, $expected, $abs-tol;
    is-approx $got, $expected, $abs-tol, 'test description';

    is-approx $got, $expected, :$rel-tol;
    is-approx $got, $expected, :$rel-tol, 'test description';

    is-approx $got, $expected, :$abs-tol;
    is-approx $got, $expected, :$abs-tol, 'test description';

    is-approx $got, $expected, :$abs-tol, :$rel-tol;
    is-approx $got, $expected, :$abs-tol, :$rel-tol, 'test description';

### No tolerance specified

If no tolerance is provided, it's assumed to be set as absolute tolerance
of `1e-5`

### Absolute tolerance specified

When absolute tolerance is set, it's used as the actual maximum value by
which the `$got` and `$expected` differ. For example:

    is-approx 3, 4, 2; # success
    is-approx 3, 6, 2; # success

    is-approx 300, 302, 2; # success
    is-approx 300, 400, 2; # fail
    is-approx 300, 600, 2; # fail

Regardless of values given, the difference between them cannot be more
than `2`

### Relative tolerance specified

When relative tolerance is set, the test checks relative difference between
values, regardless of their magnitude. The larger the numbers given, the larger
the number they can differ by can be.

For example:

    is-approx 10, 10.5, :rel-tol<0.1>; # success
    is-approx 10, 11.5, :rel-tol<0.1>; # fail

    is-approx 100, 105, :rel-tol<0.1>; # success
    is-approx 100, 115, :rel-tol<0.1>; # fail

Both versions use `0.1` for relative tolerance, yet the first can differ
by about `1` while the second can differ by about `10`. The function used
to calculate the difference is:

                  |got - expected|
    rel-diff = ──────────────────────
               max(|got|, |expected|)

And the test will fail if `rel-diff` is higher than `$rel-tol`

### Both absolute and relative tolerance specified

When both absolute and relative tolerances are specified, each will be
tested independently, and the `is-approx` test will succeed only if both pass.

------

