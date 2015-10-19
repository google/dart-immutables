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
library immutables.immutable_map.test;

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
  group('ImmutableMap', () {
    Map map;
    dynamic immutable;

    setUp(() {
      map = <int, Foo>{1: new Foo()..bar = 1, 2: new Foo()..bar = 2};
      immutable = new Immutables().wrap(map);
    });

    test('is bound by default', () {
      expect(immutable.runtimeType, ImmutableMap);
    });
    test('calls underlying getters', () {
      expect(immutable.isEmpty, false);
      map.clear();
      expect(immutable.isEmpty, true);
    });
    test('refuses unknown methods', () {
      expect(() => immutable.remove(1), throwsAnUnsupportedMutationError);
      expect(() => immutable.clear(), throwsAnUnsupportedMutationError);
      expect(() => immutable[0] = new Foo(), throwsAnUnsupportedMutationError);
    });
    test('accepts known methods', () {
      expect(immutable[1].bar, 1);
      expect(immutable.containsKey(0), false);
      expect(immutable.containsKey(1), true);
      expect(immutable.containsValue(new Foo()..bar = 1), true);
      expect(immutable.forEach((k, v) {}), null);
    });
    test('wraps its return values', () {
      expect(immutable[2], new isInstanceOf<Immutable>());
      expect(immutable.keys, new isInstanceOf<ImmutableIterable>());
    });
    test('passes iterators through', () {
      expect(immutable.keys.iterator is Immutable, false);
    });
  });
}
