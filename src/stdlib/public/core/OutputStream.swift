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

public protocol TextOutputStream {
  mutating func _lock()
  mutating func _unlock()

  /// Appends the given string to the stream.
  mutating func write(_ string: String)
}

extension TextOutputStream {
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func _lock() {}
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func _unlock() {}
}

public protocol TextOutputStreamable {
  /// Writes a textual representation of this instance into the given output
  /// stream.
  func write<Target : TextOutputStream>(to target: inout Target)
}

public protocol CustomStringConvertible {
  /// A textual representation of this instance.
  ///
  /// Instead of accessing this property directly, convert an instance of any
  /// type to a string by using the `String(describing:)` initializer. For
  /// example:
  ///
  ///     struct Point: CustomStringConvertible {
  ///         let x: Int, y: Int
  ///
  ///         var description: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  ///
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(describing: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  ///
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `description` property.
  var description: String { get }
}


/// A type that can be represented as a string in a lossless, unambiguous way.
///
/// For example, the integer value 1050 can be represented in its entirety as
/// the string "1050".
///
/// The description property of a conforming type must be a value-preserving
/// representation of the original value. As such, it should be possible to
/// re-create an instance from its string representation.
public protocol LosslessStringConvertible : CustomStringConvertible {
  /// Instantiates an instance of the conforming type from a string
  /// representation.
  init?(_ description: String)
}

public protocol CustomDebugStringConvertible {
  /// A textual representation of this instance, suitable for debugging.
  var debugDescription: String { get }
}

//===----------------------------------------------------------------------===//
// Default (ad-hoc) printing
//===----------------------------------------------------------------------===//


