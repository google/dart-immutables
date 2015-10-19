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
library immutables.immutable.test;

import 'package:immutables/immutables.dart';
import 'package:mock/mock.dart';
import 'package:test/test.dart';

class Foo {
  int bar;
  describe() => "a foo";
  toList() => [];

  @override operator ==(o) => o is Foo && o.bar == bar;
}

class ImmutableFoo<T> extends Immutable implements Foo {
  ImmutableFoo(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockImmutables extends Mock implements Immutables {
  noSuchMethod(i) => super.noSuchMethod(i);
}

final throwsAnUnsupportedMutationError =
    throwsA(new isInstanceOf<UnsupportedMutationError>());

main() {
  group('Immutable', () {
    Foo foo;
    MockImmutables immutables;
    dynamic immutable;

    setUp(() {
      foo = new Foo();
      immutables = new MockImmutables();
      immutable = new ImmutableFoo(foo, immutables);
    });

    test('calls immutables to check if methods are safe', () {
      immutables.when(callsTo('isNonMutatingInvocation')).alwaysReturn(false);
      expect(() => immutable.describe(), throwsAnUnsupportedMutationError);
      expect(() => immutable.bar = 10, throwsAnUnsupportedMutationError);
      expect(() => immutable.toList(), throwsAnUnsupportedMutationError);
    });
  });
  group('Immutable with DefaultImmutables', () {
    Foo foo;
    dynamic immutable;

    setUp(() {
      foo = new Foo();
      final immutables = new Immutables();
      immutable = new ImmutableFoo(foo, immutables);
    });

    test('propagates equals, hashcode, toString', () {
      expect(immutable == foo, true);
      expect(immutable == new Foo(), true);
      expect(immutable == null, false);
      expect(immutable.hashCode, foo.hashCode);
      expect(immutable.toString(), foo.toString());
    });

    test('has mostly symmetrical operator==', () {
      expect(new Foo() == immutable, true);
      expect((new Foo()..bar = 1) != immutable, true);
      expect(immutable != (new Foo()..bar = 1), true);
      expect(immutable == immutable, true);
      expect(immutable != null, true);
    });
  });
}
