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
library immutables.immutable_list.test;

import 'package:immutables/immutables.dart';
import 'package:immutables/src/default_immutable_wrappers.dart';
import 'package:test/test.dart';

class Foo {
  int bar;
  operator ==(o) => o is Foo && bar == o.bar;
}

final throwsAnUnsupportedMutationError =
    throwsA(new isInstanceOf<UnsupportedMutationError>());

main() {
  group('ImmutableIterable', () {
    Iterable iterable;
    dynamic immutable;

    setUp(() {
      iterable = [new Foo()..bar = 1].where((v) => v != null);
      immutable = new Immutables().wrap(iterable);
    });

    test('is bound by default', () {
      expect(immutable.runtimeType, ImmutableIterable);
    });
    test('calls underlying getters', () {
      expect(immutable.isEmpty, false);
    });
    test('refuses unknown methods', () {
      expect(() => immutable.add(1), throwsAnUnsupportedMutationError);
      expect(() => immutable.clear(), throwsAnUnsupportedMutationError);
    });
    test('accepts known methods', () {
      expect(immutable.any((_) => true), true);
      expect(immutable.toList(), [new Foo()..bar = 1]);
    });
    test('wraps its return values', () {
      expect(immutable.first, new isInstanceOf<Immutable>());
      expect(immutable.toList(), new isInstanceOf<ImmutableList>());
    });
    test('passes iterators through', () {
      expect(immutable.iterator is Immutable, false);
    });
  });
}
