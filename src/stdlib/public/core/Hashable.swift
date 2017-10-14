
//===----------------------------------------------------------------------===//
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

public protocol Hashable : Equatable  {
  /// The hash value.
  ///
  /// Hash values are not guaranteed to be equal across different executions of
  /// your program. Do not save hash values to use during a future execution.
  var hashValue: Int { get }
}

public enum _RuntimeHelpers {}

extension _RuntimeHelpers {
  @_inlineable // FIXME(sil-serialize-all)
  @_silgen_name("swift_stdlib_Hashable_isEqual_indirect")
  public static func Hashable_isEqual_indirect<T : Hashable>(
    _ lhs: UnsafePointer<T>,
    _ rhs: UnsafePointer<T>
  ) -> Bool {
    return lhs.pointee == rhs.pointee
  }

  @_inlineable // FIXME(sil-serialize-all)
  @_silgen_name("swift_stdlib_Hashable_hashValue_indirect")
  public static func Hashable_hashValue_indirect<T : Hashable>(
    _ value: UnsafePointer<T>
  ) -> Int {
    return value.pointee.hashValue
  }
}
