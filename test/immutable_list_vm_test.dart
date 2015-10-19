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
  group('ImmutableList', () {
    List list;
    dynamic immutable;

    setUp(() {
      list = [new Foo()..bar = 1];
      immutable = new Immutables().wrap(list);
    });

    test('is bound by default', () {
      expect(immutable.runtimeType, ImmutableList);
    });
    test('calls underlying getters', () {
      expect(immutable.isEmpty, false);
      list.clear();
      expect(immutable.isEmpty, true);
    });
    test('refuses unknown methods', () {
      expect(() => immutable.add(1), throwsAnUnsupportedMutationError);
      expect(() => immutable.clear(), throwsAnUnsupportedMutationError);
      expect(() => immutable[0] = 10, throwsAnUnsupportedMutationError);
    });
    test('accepts known methods', () {
      expect(immutable[0].bar, 1);
    });
    test('wraps its return values', () {
      expect(immutable[0], new isInstanceOf<Immutable>());
    });
    test('passes iterators through', () {
      expect(immutable.iterator is Immutable, false);
    });
  });
}
