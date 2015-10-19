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
library immutables.default_immutable_wrappers;

import 'package:protobuf/protobuf.dart';

import 'immutable.dart';

class ImmutableMap<K, V> extends Immutable implements Map<K, V> {
  ImmutableMap(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class ImmutableIterable<T> extends Immutable implements Iterable<T> {
  ImmutableIterable(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class ImmutableList<T> extends ImmutableIterable<T> implements List<T> {
  ImmutableList(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class ImmutableSet<T> extends ImmutableIterable<T> implements Set<T> {
  ImmutableSet(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class ImmutableGeneratedMessage extends Immutable implements GeneratedMessage {
  ImmutableGeneratedMessage(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}

class ImmutablePbList<T> extends Immutable implements PbList {
  ImmutablePbList(target, immutables) : super(target, immutables);
  noSuchMethod(i) => super.noSuchMethod(i);
}
