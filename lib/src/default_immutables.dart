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
part of immutables.immutables;

typedef bool _InvocationPredicate(target, Invocation i);

typedef Type _NormalizedTypeGetter(type);

/// Default implementation of [Immutables], with built-in support for
/// [List], [Map], [Set], [Iterable].
class _DefaultImmutables extends Immutables {
  static Logger _logger = new Logger("ads.adsense.fe.shared.immutables");

  final Injector _injector;
  _DefaultImmutables(this._injector) : super._();

  final List<_NormalizedTypeGetter> normalizedTypeGetters =
      <_NormalizedTypeGetter>[
    getNormalizedCollectionType,
    getNormalizedMessageType
  ];

  final List<_InvocationPredicate> nonMutatingMethodPredicates =
      <_InvocationPredicate>[
    isNonMutatingCollectionMethod,
    isNonMutatingGeneratedMessageMethod
  ];

  final List<_InvocationPredicate> breakoutPredicates =
      <_InvocationPredicate>[isCollectionBreakoutInvocation];

  @override
  bool isNonMutatingInvocation(target, Invocation i) => i.isGetter ||
      i.isMethod && nonMutatingMethodPredicates.any((p) => p(target, i));

  @override
  bool isIndexedAccessInvocation(target, Invocation i) =>
      isSquareBracketInvocation(i);

  @override
  bool isBreakoutInvocation(target, Invocation i) =>
      breakoutPredicates.any((p) => p(target, i));

  @override
  bool needsWrapping(value) => value != null &&
      value is! Immutable &&
      value is! num &&
      value is! bool &&
      value is! String &&
      value is! Function &&
      !isDeeplyImmutableProtobufObject(value);

  /// Attempt to normalize [target]'s type (for instance, `PbList<int>` can be
  /// normalized to `List`), or return null if no known normalization is
  /// applicable.
  Type getNormalizedType(target) {
    for (final normalizer in normalizedTypeGetters) {
      Type t = normalizer(target);
      if (t != null) return t;
    }
    return target.runtimeType;
  }

  @override
  dynamic wrap(value) {
    if (!needsWrapping(value)) return value;

    var wrapper = getImmutableWrapperFactory(_injector, value.runtimeType);
    if (wrapper == null) {
      wrapper = getImmutableWrapperFactory(_injector, getNormalizedType(value));
    }
    if (wrapper != null) return wrapper(value, this);
    _warnAboutRawImmutables(value.runtimeType);
    return new Immutable(value, this);
  }

  static var _rawImmutablesWarnedAbout;
  static _warnAboutRawImmutables(Type type) {
    if (immutableDebuggingDisabled) return;
    if (!isCheckedMode()) return;

    if (_rawImmutablesWarnedAbout == null) {
      _rawImmutablesWarnedAbout = new Set<Type>();
    }
    if (!_rawImmutablesWarnedAbout.add(type)) return;

    _logger.info("""Raw immutable $type may cause issues in checked mode.
You can register a typed immutable wrapper in your ImmutablesModule with:

  class _$type extends Immutable implements $type {
    _$type(t, i): super(t, i);
    noSuchMethod(i) => noSuchMethod(i);
  }

  new ImmutablesModule()..bindWrappers({
    $type: (t, s) => new _$type(t, s),
    ...
  });""");
  }
}
