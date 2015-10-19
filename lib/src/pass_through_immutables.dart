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

/// [Immutables] instance that never wraps any value in [Immutable] wrappers.
/// This can be useful in production builds for performance reasons, once
/// tests have proved that no illegal mutations occur in development mode.
class _PassThroughImmutables extends Immutables {
  _PassThroughImmutables() : super._();

  @override
  dynamic wrap(value) => value;

  @override
  bool isIndexedAccessInvocation(target, Invocation i) => false;

  @override
  bool needsWrapping(value) => false;

  @override
  bool isBreakoutInvocation(target, Invocation i) => true;

  @override
  bool isNonMutatingInvocation(target, Invocation i) => true;
}
