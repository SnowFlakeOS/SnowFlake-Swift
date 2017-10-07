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
// Intrinsic protocols shared with the compiler
//===----------------------------------------------------------------------===//

public protocol RawRepresentable {
  /// The raw type that can be used to represent all values of the conforming
  /// type.
  ///
  /// Every distinct value of the conforming type has a corresponding unique
  /// value of the `RawValue` type, but there may be values of the `RawValue`
  /// type that don't have a corresponding value of the conforming type.
  associatedtype RawValue

  /// Creates a new instance with the specified raw value.
  ///
  /// If there is no value of the type that corresponds with the specified raw
  /// value, this initializer returns `nil`. For example:
  ///
  ///     enum PaperSize: String {
  ///         case A4, A5, Letter, Legal
  ///     }
  ///
  ///     print(PaperSize(rawValue: "Legal"))
  ///     // Prints "Optional("PaperSize.Legal")"
  ///
  ///     print(PaperSize(rawValue: "Tabloid"))
  ///     // Prints "nil"
  ///
  /// - Parameter rawValue: The raw value to use for the new instance.
  init?(rawValue: RawValue)

  /// The corresponding value of the raw type.
  ///
  /// A new instance initialized with `rawValue` will be equivalent to this
  /// instance. For example:
  ///
  ///     enum PaperSize: String {
  ///         case A4, A5, Letter, Legal
  ///     }
  ///
  ///     let selectedSize = PaperSize.Letter
  ///     print(selectedSize.rawValue)
  ///     // Prints "Letter"
  ///
  ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
  ///     // Prints "true"
  var rawValue: RawValue { get }
}