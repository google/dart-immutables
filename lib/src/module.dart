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
library immutables.module;

import 'package:di/di.dart';
import 'package:protobuf/protobuf.dart';

import 'default_immutable_wrappers.dart';
import 'immutables.dart';
import 'flags.dart';

typedef Immutable ImmutableWrapperFactory(dynamic, Immutables system);

/// Module that binds [Immutable] and some common [ImmutableWrapperFactory]
/// factories that create use [Immutable] subclasses for [List]s, [Set]s,
/// [Map]s, [Iterable]s, [GeneratedMessage]s and [PbList]s (from the protobuf
/// package).
///
/// Additional bindings can be setup with [bindWrappers].
class ImmutablesModule extends Module {
  ImmutablesModule() {
    bind(Immutables);
    bindWrappers({
      List: (v, s) => new ImmutableList(v, s),
      Map: (v, s) => new ImmutableMap(v, s),
      Set: (v, s) => new ImmutableSet(v, s),
      Iterable: (v, s) => new ImmutableIterable(v, s),
      GeneratedMessage: (v, s) => new ImmutableGeneratedMessage(v, s),
      PbList: (v, s) => new ImmutablePbList(v, s),
    });
  }

  /// Binds wrapper factories to their wrapped type.
  bindWrappers(Map<Type, ImmutableWrapperFactory> wrapperFactories) {
    if (immutableWrappersDisabled) return;
    wrapperFactories.forEach((wrappedType, wrapperFactory) {
      bindImmutableWrapper(this, wrappedType, wrapperFactory);
    });
  }
}

/// Bind [wrapper] in [module] as a factory to create [Immutable] instances for
/// values of type [wrappedType].
bindImmutableWrapper(
    Module module, Type wrappedType, ImmutableWrapperFactory factory) {
  if (immutableWrappersDisabled) return;
  _checkWrapperFactory(factory);
  module.bindByKey(new Key(wrappedType, const _ImmutableWrapper()),
      toValue: factory);
}

/// Returns the [ImmutableWrapperFactory] bound in [injector] as a factory to
/// create [Immutable] instances for values of type [wrappedType], or returns
/// null if there is no such binding.
ImmutableWrapperFactory getImmutableWrapperFactory(
    Injector injector, Type wrappedType) {
  try {
    return _checkWrapperFactory(
        injector.getByKey(new Key(wrappedType, const _ImmutableWrapper())));
  } on NoProviderError catch (e) {
    return null;
  }
}

/// Annotation used internally as injection key.
class _ImmutableWrapper {
  const _ImmutableWrapper();
}

ImmutableWrapperFactory _checkWrapperFactory(wrapper) {
  if (wrapper is! ImmutableWrapperFactory) {
    throw new ArgumentError("Wrapper is not a function: $wrapper");
  }
  return wrapper;
}
