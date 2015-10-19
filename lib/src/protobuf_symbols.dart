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
library immutables.protobuf_symbols;

import 'package:protobuf/protobuf.dart';

Type getNormalizedMessageType(value) =>
    value is GeneratedMessage ? GeneratedMessage : null;

/// Returns true iff value is an immutable object from the protobuf library
/// (e.g. an enum value).
bool isDeeplyImmutableProtobufObject(value) => value is ProtobufEnum;

/// Predicate to detect non-mutating method invocations on [GeneratedMessage]
/// from the protobuf library.
bool isNonMutatingGeneratedMessageMethod(t, Invocation i) =>
    t is GeneratedMessage &&
        !_messageMutatingMethodSymbols.contains(i.memberName);

/// Note: [GeneratedMessage._toMap] calls other instances' private `_toMap`
/// method, which we cannot detect with symbol recording / comparison. This is
/// why we blacklist mutating methods instead of whitelisting non-mutating
/// methods, as we do for collections. This is slightly fragile (a future
/// version of the protobuf package may introduce other mutating methods, which
/// we should blacklist here), but there is no other known workaround: your
/// contribution is welcome!
final Set<Symbol> _messageMutatingMethodSymbols = new Set<Symbol>()
  ..addAll([
    #clear,
    #mergeFromCodedBufferReader,
    #mergeFromBuffer,
    #mergeFromJson,
    #addExtension,
    #clearExtension,
    #clearField,
    #mergeFromMessage,
    #mergeUnknownFields,
    #setExtension,
    #setField,
  ]);
