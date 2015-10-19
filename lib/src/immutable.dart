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
library immutables.immutable;

import 'flags.dart';
import 'immutables.dart';
import 'mirrors.dart';

/// Wrapper that makes its proxied target unmodifiable / immutable, by only
/// forwarding calls to getters / non-mutating methods, and returning wrapped
/// instances from these getters and methods (propagating immutability).
///
/// The exact logic of which calls / return values are wrapped / mutating is
/// delegated to an [Immutables] instance.
class Immutable {
  final _target;
  final Immutables _immutables;
  final _ImmutableMembersCache _membersCache = new _ImmutableMembersCache();

  Immutable(target, Immutables immutables)
      : this._target = target,
        this._immutables = immutables {
    if (_target == null) throw new ArgumentError.notNull("target");
    if (_immutables == null) throw new ArgumentError.notNull("immutables");
  }

  /// Proxies non-mutating invocations to [_target], and throws
  /// [UnsupportedMutationError] on potentially-mutating invocations.
  noSuchMethod(Invocation i) {
    if (_immutables.isNonMutatingInvocation(_target, i)) {
      _wrapValueIfNeeded(value) {
        // Values like null, primitives and alike should be returned here.
        if (!_immutables.needsWrapping(value) ||
            _immutables.isBreakoutInvocation(_target, i)) {
          return value;
        }

        final isIndexed = _immutables.isIndexedAccessInvocation(_target, i);

        // Only cache wrappers of getters and indexed accesses (operator[]).
        if (!i.isGetter && !isIndexed) return _immutables.wrap(value);

        return _membersCache.getImmutable(value, _immutables.wrap, i.memberName,
            isIndexed, isIndexed ? i.positionalArguments.single : null);
      }

      if (i.isGetter) {
        final fieldValue =
            immutableWrappersDisabled ? null : getField(_target, i.memberName);
        return _wrapValueIfNeeded(fieldValue);
      } else if (i.isMethod) {
        final returnValue =
            immutableWrappersDisabled ? null : invokeMethod(_target, i);
        return _wrapValueIfNeeded(returnValue);
      }
    }
    throw new UnsupportedMutationError(_target, i);
  }

  @override
  String toString() => _target.toString();

  @override
  int get hashCode => _target.hashCode;

  @override
  bool operator ==(o) {
    if (o is Immutable) return o._target == _target;
    return _target == o;
  }
}

class _ImmutableMembersCache {
  Map<Symbol, Immutable> _cachedImmutableFieldWrappers;
  Map<Symbol, Map<dynamic, Immutable>> _cachedImmutableIndexedFieldWrappers;

  Immutable getImmutable(
      value, Immutable wrapper(dynamic), Symbol symbol, bool isIndexed, index) {

    // Cache field values' immutable wrappers to as to return stable values.
    // This fixes Angular digests, which otherwise never stabilize.
    Immutable immutableValue;

    if (isIndexed) {
      if (_cachedImmutableIndexedFieldWrappers == null) {
        _cachedImmutableIndexedFieldWrappers =
            <Symbol, Map<dynamic, Immutable>>{};
      }
      immutableValue = _cachedImmutableIndexedFieldWrappers.putIfAbsent(
          symbol, () => <dynamic, Immutable>{})[index];
    } else {
      if (_cachedImmutableFieldWrappers == null) {
        _cachedImmutableFieldWrappers = <Symbol, Immutable>{};
      }
      immutableValue = _cachedImmutableFieldWrappers[symbol];
    }

    if (immutableValue == null || !identical(immutableValue._target, value)) {
      immutableValue = wrapper(value);
      assert(immutableValue is Immutable);

      if (isIndexed) {
        _cachedImmutableIndexedFieldWrappers[symbol][index] = immutableValue;
      } else {
        _cachedImmutableFieldWrappers[symbol] = immutableValue;
      }
    }
    return immutableValue;
  }
}

/// Error thrown when a potentially mutating invocation was attempted on an
/// immutable wrapper.
class UnsupportedMutationError extends NoSuchMethodError {
  UnsupportedMutationError(target, Invocation i)
      : super(target, i.memberName, i.positionalArguments, i.namedArguments);
  @override
  String toString() => "UnsupportedMutationError: ${super.toString()}";
}

/// Unwrap immutable wrappers: gives direct access to the original
/// potentially-mutable object that was wrapped by [Immutables.wrap].
///
/// If [o] is not [Immutable], it is returned unchanged.
///
/// This is deprecated because it breaks the immutable encapsulation contract
/// of [Immutable]. It should only be used as a workaround for specific cases
/// (JS interop, for instance), and might be removed in the future.
@deprecated
dynamic unsafeUnwrapImmutable(o) => o is Immutable ? o._target : o;
