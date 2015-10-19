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
library immutables.flags;

const immutableWrappersDisabled = const bool.fromEnvironment(
    "immutables.immutableWrappersDisabled",
    defaultValue: false);

const immutableDebuggingDisabled = const bool.fromEnvironment(
    "immutables.immutableDebuggingDisabled",
    defaultValue: false);

bool _isCheckedMode;

/// Returns true iff Dart runs in checked mode.
bool isCheckedMode() {
  if (_isCheckedMode == null) {
    try {
      // Deliberately assign a value of the wrong type to the bool variable
      // to trigger an exception if we're in checked mode.
      _isCheckedMode = "" as dynamic;
      _isCheckedMode = false;
    } catch (e) {
      _isCheckedMode = true;
    }
  }
  return _isCheckedMode;
}

/// Hack to detect whether we're running on the Dart VM or in compiled dart2js
/// output.
///
/// In JavaScript 1 and 1.0 are represented with the same `number` (double)
/// value, while in Dart `1` is an `int` and `1.0` a `num`.
bool isDartVM() => identical(1, 1.0) == false;

/// TODO(ochafik): Detect non-minified dart2js mode.
/// TODO(ochafik): Add a smoke transformer that makes immutables work with
/// dart2js.
bool isSafeToUseImmutables() => isDartVM();

/// Returns the current [StackTrace].
StackTrace getStackTrace() {
  try {
    throw new Error();
  } catch (_, s) {
    return s;
  }
}
