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
library immutables;

/// The immutable library.
///
/// Wraps objects to make them immutable, propagating immutability
/// through values they return from their getters and non-mutating methods.
///
/// Returned values are wrapped using known default [Immutable] subclasses
/// (for instance [ImmutableList] for [List] return values), but this can be
/// customized by binding custom lightweight wrappers (see [ImmutablesModule]).
///

export 'src/default_immutable_wrappers.dart';
export 'src/immutable.dart';
export 'src/immutables.dart';
export 'src/module.dart';
