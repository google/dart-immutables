# Immutables [![Build Status](https://travis-ci.org/google/dart-immutables.svg?branch=master)](https://travis-ci.org/google/dart-immutables)

An experiment on wrapping arbitrary values to make them *recursively* immutable.

_Disclaimer_: This is not an official Google product.

Immutable wrappers proxy every getter & non-mutating method call to their
wrapped value, and the return values from these calls are recursively wrapped.

Users can bind wrappers that implement the interface of their wrapped class
(to play nice with checked mode). Support for explicitly whitelisting methods
as being non-mutating is being considered.

## What is immutable?

This library assumes a couple of invocations are not mutating their targets:

* Getters: in general, should not mutate the target. Note that common usage
allows getters to cache their results and still be considered non-mutating.

* `operator[]`: indexed access (on `List`, `Map`...) is generally considered to
be non-mutating, but this might not be true for LRU caches, etc.

* Many common `Iterable` operations (`where`, `map`, etc...) are expected to be
non-mutating.

## Note on mirror usage

This library does not require any symbol to be preserved, but does need some
way to call getters / methods by symbol (not by name). This is currently done
with the [smoke](https://pub.dartlang.org/packages/smoke) library, but since I
haven't written the required transformer yet the whole immutable library is just
disabled when compiling with dart2js.

## Usage

For instance, if you have a class `Foo` that you want to expose as immutable:

    import 'package:di/di.dart';
    import 'package:immutables/immutables.dart';
    import 'package:unittest/unittest.dart';

    class Foo {
      int bar = 0;
      List baz;
      increment() { bar++; }
    }

    /// Make sure wrapped immutable [Foo] instances implement [Foo]
    /// (useful in checked mode).
    class _Foo extends Immutable implements Foo {
      _Foo(target, immutables) : super(target, immutables);
      noSuchMethod(i) => super.noSuchMethod(i);
    }

    main() {
      test('example', () {
        final injector = new ModuleInjector([
          new ImmutablesModule()..bindWrappers({
            Foo: (t, i) => new _Foo(t, i),
          }),
        ]);
        final immutables = injector.get(Immutables);

        // Note: `final immutables = new Immutables();` uses a module with
        // default configuration.

        final foo = immutables.wrap(new Foo()..bar = 1..baz = [2, 3]);

        expect(foo.bar, 1);
        expect(() => foo.bar = 10, throws);

        expect(foo.baz, [2, 3]);
        expect(foo.baz.where((v) => v % 2 == 0).toList(), [2]);
        expect(() => foo.baz = [], throws);
        expect(() => foo.baz.clear(), throws);
      });
    }

# Elidable

Immutable wrappers can be removed completely from your production binary.

In your pubspec / transformers section, just add (last transformers entry):

```
transformers:
- $$dart2js:
    minify: true
    environment:
        immutables.immutableWrappersDisabled: true
```

# Known issues

## Interaction with Angular

Avoid returning new `Immutable` instances from getters called by Angular
templates: this will confuse Angular's digest mechanism (it will think the
digest doesn't stabilize). Instead, store the obtained `Immutable` instance.

## When all else fails

The deprecated `unsafeUnwrapImmutable` can be used to unwrap immutable values.

TODO(ochafik): allow customization of `DefaultImmutables` (registering new
`normalizedTypeGetters`, `nonMutatingMethodPredicates`, `breakoutPredicates`).
