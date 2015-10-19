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
library immutables.mirrors;

import 'package:smoke/smoke.dart' as smoke;

///
/// Reflection methods, implemented using the `smoke` package.
///
/// Note: mirrors could be used, but won't play well when your app has other
/// [MirrorsUsed] annotations:
///
///     @MirrorsUsed(targets: const[], metaTargets: const[], symbols: const[])
///     import 'dart:mirrors';
///
///     getField(target, Symbol name) =>
///         reflect(target).getField(name).reflectee;
///
///     invokeMethod(target, Invocation i) =>
///         reflect(target)
///         .invoke(i.memberName, i.positionalArguments, i.namedArguments)
///         .reflectee;
///

getField(target, Symbol name) => smoke.read(target, name);

invokeMethod(target, Invocation i) => smoke.invoke(
    target, i.memberName, i.positionalArguments, namedArgs: i.namedArguments);
