// Copyright 2015 Google Inc. All Rights Reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
library immutables.default_immutables.test;

import 'package:immutables/immutables.dart';
import 'package:immutables/src/default_immutable_wrappers.dart';
import 'package:di/di.dart';
import 'package:unittest/unittest.dart';

class Foo {
  int bar;
  List baz;
  List<Foo> subs;
  describe() => "a foo";
  toList() => [];
}
class Bar {}

class ImmutableFoo<T> extends Immutable implements Foo {
  static int nextId = 0;
  int id;
  ImmutableFoo(target, immutables) : super(target, immutables) {
    id = nextId++;
  }
  noSuchMethod(i) => super.noSuchMethod(i);
}

main() {
  group('DefaultImmutables.wrap', () {
    Immutables immutables;
    setUp(() {
      final injector = new ModuleInjector([
        new ImmutablesModule()
          ..bindWrappers({Foo: (f, s) => new ImmutableFoo(f, s)})
      ]);
      immutables = new Immutables(injector);
    });

    test('wraps known collection types', () {
      expect(immutables.wrap([]), new isInstanceOf<ImmutableList>());
      expect(immutables.wrap(new Set()), new isInstanceOf<ImmutableSet>());
      expect(immutables.wrap({}), new isInstanceOf<ImmutableMap>());
      expect(immutables.wrap([1].where((_) => false)),
          new isInstanceOf<ImmutableIterable>());
    });
    test('lets simple types go through', () {
      expect(immutables.wrap(1), new isInstanceOf<int>());
      expect(immutables.wrap(1.0), new isInstanceOf<double>());
      expect(immutables.wrap(true), new isInstanceOf<bool>());
      expect(immutables.wrap(""), new isInstanceOf<String>());
      expect(immutables.wrap(() => null), new isInstanceOf<Function>());
    });
    test('wraps registered Foo', () {
      final wrapped = immutables.wrap(new Foo());
      expect(wrapped, new isInstanceOf<Immutable>());
      expect(wrapped, new isInstanceOf<ImmutableFoo>());
      expect(wrapped, new isInstanceOf<Foo>());
    });
    test('wraps unregistered Bar', () {
      final wrapped = immutables.wrap(new Bar());
      expect(wrapped.runtimeType, Immutable);
      expect(wrapped is Bar, false);
    });
    test('propagates simple getters', () {
      final wrapped = immutables.wrap(new Foo()..bar = 10);
      expect(wrapped.bar, new isInstanceOf<int>());
      expect(wrapped.bar, 10);
    });
    test('propagates complex getters', () {
      final wrapped = immutables.wrap(new Foo()..baz = [1, 2]);
      final baz = wrapped.baz;
      expect(baz, new isInstanceOf<List>());
      expect(baz, new isInstanceOf<ImmutableList>());
      expect(baz.length, 2);
      expect(baz, [1, 2]);
    });
    test('caches fields', () {
      final Foo wrapped =
          immutables.wrap(new Foo()..subs = [new Foo()..bar = 10]);
      expect(identical(wrapped.subs, wrapped.subs), true);
      expect(identical(wrapped.subs[0], wrapped.subs[0]), true);
      getSubId() => (wrapped.subs[0] as dynamic).id;
      expect(getSubId(), getSubId());
    });
  });
}
