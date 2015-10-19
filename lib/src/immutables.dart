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
library immutables.immutables;

import 'package:di/di.dart';
import 'package:logging/logging.dart';

import 'collection_symbols.dart';
import 'flags.dart';
import 'immutable.dart';
import 'module.dart';
import 'protobuf_symbols.dart';

part 'default_immutables.dart';
part 'pass_through_immutables.dart';

/// Helper that can wrap any [Object] as an immutable object.
/// Depending on implementations, its [wrap] method may return [Immutable]
/// instances that proxy every public call to the original wrapped object and
/// ensure that no mutable object escapes.
///
/// [Immutable] wrapping can be disabled for production builds:
///
///    - $$dart2js:
///        minify: true
///        environment:
///            immutables.immutableWrappersDisabled: true
///
@Injectable()
abstract class Immutables {
  factory Immutables([Injector injector]) {
    if (immutableWrappersDisabled || !isSafeToUseImmutables()) {
      return new _PassThroughImmutables();
    }
    if (injector == null) {
      injector = new ModuleInjector([new ImmutablesModule()]);
    }
    return new _DefaultImmutables(injector);
  }

  /// Private base constructor: only allow our own subclasses.
  Immutables._();

  /// Wrap a value in an [Immutable] if needed. The concrete [Immutable] class
  /// used to wrap [value] may depend on its type, for instance
  /// [List] values may be wrapped in [ImmutableList] instances. Some values
  /// may be returned unwrapped depending on the [Immutables] implementation.
  dynamic wrap(value);

  /// Returns true iff [value] needs to be wrapped.
  /// This is typically false for primitives and [Immutable] instances.
  ///
  /// It is expected that if `!needsWrapping(x)` then `wrap(x) is! Immutable`.
  bool needsWrapping(value);

  /// Returns true iff return values of [i] invocations should not be wrapped.
  /// (e.g. [Iterable.iterator] returns a mutable iterator that cannot mutate
  /// its original collection).
  bool isBreakoutInvocation(target, Invocation i);

  /// Returns true iff [i] is a square bracket operator invocation.
  /// This is used to determine whether [Immutable] instances can be memoized
  /// for the invocation on a specific index.
  bool isIndexedAccessInvocation(target, Invocation i);

  /// Returns true iff [i] is known to not be mutating its target instance
  /// (e.g. [Iterable.where], [List.operator[]]...).
  bool isNonMutatingInvocation(target, Invocation i);
}
