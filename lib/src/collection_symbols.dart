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
library immutables.collection_symbols;

import 'dart:async';
import 'dart:collection';

/// Attempt to normalize collection types.
/// For instance, `PbList<int>` can be normalized to `List` if no wrapper was
/// bound to `PbList`.
Type getNormalizedCollectionType(value) {
  if (value is List) return List;
  if (value is Set) return Set;
  if (value is Map) return Map;
  if (value is Iterable) return Iterable;
  return null;
}

/// Returns true iff [i] is a square-brackets indexed access invocation.
bool isSquareBracketInvocation(Invocation i) => i.memberName == #[];

/// Returns true iff [i] is a non-mutating method call on a collection.
bool isNonMutatingCollectionMethod(t, Invocation i) {
  final name = i.memberName;
  return (t is Iterable && _iterableNonMutatingMethods.contains(name)) ||
      (t is List && _listNonMutatingMethods.contains(name)) ||
      (t is Map && _mapNonMutatingMethods.contains(name)) ||
      ((t is SplayTreeMap || t is HashMap) && name == #[]) ||
      (t is Future);
}

/// Returns true iff the result of [i] should never be wrapped in an immutable
/// wrapper.
bool isCollectionBreakoutInvocation(t, Invocation i) =>
    t is Iterable && _iterableBreakoutSymbols.contains(i.memberName);

/// Records symbols of [List] methods known not to mutate their instance.
final Set<Symbol> _listNonMutatingMethods = new Set<Symbol>()
  ..addAll([#[], #indexOf, #lastIndexOf, #sublist, #getRange, #asMap,]);

/// Records symbols of [Iterable] methods known not to mutate their instance.
final Set<Symbol> _iterableNonMutatingMethods = new Set<Symbol>()
  ..addAll([
    #map,
    #where,
    #expand,
    #contains,
    #forEach,
    #reduce,
    #fold,
    #every,
    #join,
    #any,
    #toList,
    #toSet,
    #take,
    #takeWhile,
    #skip,
    #skipWhile,
    #firstWhere,
    #lastWhere,
    #singleWhere,
    #elementAt,
  ]);

/// Records symbols of [Iterable] methods that return values that should not
/// be wrapped in [Immutable] wrappers (e.g. [Iterable.iterator], which returns
/// values that must be mutable but are not expected to mutate the original
/// iterable).
final Set<Symbol> _iterableBreakoutSymbols = new Set<Symbol>()
  ..addAll([#iterator,]);

/// Records symbols of [Map] methods known not to mutate their instance.
///
/// Note: `#[]` is absent from this list on purpose, since some [Map]
/// implementations like Quiver's LruMap may somehow mutate the collection upon
/// lookup. We whitelist `#[]` only on select known [Map] implementations.
final Set<Symbol> _mapNonMutatingMethods = new Set<Symbol>()
  ..addAll([#containsValue, #containsKey, #forEach,]);
