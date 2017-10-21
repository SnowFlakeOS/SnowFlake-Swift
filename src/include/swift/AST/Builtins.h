//===--- Builtins.h - Swift Builtin Functions -------------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file defines the interface to builtin functions.
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_AST_BUILTINS_H
#define SWIFT_AST_BUILTINS_H

namespace swift {
  class ASTContext;
  class Identifier;
  class ValueDecl;

/// OverloadedBuiltinKind - Whether and how a builtin is overloaded.
enum class OverloadedBuiltinKind : unsigned char {
  /// The builtin is not overloaded.
  None,

  /// The builtin is overloaded over all integer types.
  Integer,

  /// The builtin is overloaded over all integer types and vectors of integers.
  IntegerOrVector,

  /// The builtin is overloaded over all integer types and the raw pointer type.
  IntegerOrRawPointer,

  /// The builtin is overloaded over all integer types, the raw pointer type,
  /// and vectors of integers.
  IntegerOrRawPointerOrVector,

  /// The builtin is overloaded over all floating-point types.
  Float,

  /// The builtin is overloaded over all floating-point types and vectors of
  /// floating-point types.
  FloatOrVector,

  /// The builtin has custom processing.
  Special
};

/// BuiltinValueKind - The set of (possibly overloaded) builtin functions.
enum class BuiltinValueKind {
  None = 0,
#define BUILTIN(Id, Name, Attrs) Id,
#include "swift/AST/Builtins.def"
};
}

#endif
