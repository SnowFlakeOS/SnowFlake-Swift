//===--- Integers.swift.gyb -----------------------------------*- swift -*-===//
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

@available(swift, obsoleted: 4.0, renamed: "Int64")
public typealias IntMax = Int64
/// The largest native unsigned integer type.
@available(swift, obsoleted: 4.0, renamed: "UInt64")
public typealias UIntMax = UInt64

//===----------------------------------------------------------------------===//
//===--- Bits for the Stdlib ----------------------------------------------===//
//===----------------------------------------------------------------------===//

// FIXME(integers): This should go in the stdlib separately, probably.
extension ExpressibleByIntegerLiteral
  where Self : _ExpressibleByBuiltinIntegerLiteral {
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  public init(integerLiteral value: Self) {
    self = value
  }
}

//===----------------------------------------------------------------------===//
//===--- Operator Documentation -------------------------------------------===//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
//===--- Numeric ----------------------------------------------------------===//
//===----------------------------------------------------------------------===//

public protocol Numeric : Equatable, ExpressibleByIntegerLiteral { }
public protocol SignedNumeric : Numeric { }
extension SignedNumeric { }
extension Numeric { }

//===----------------------------------------------------------------------===//
//===--- BinaryInteger ----------------------------------------------------===//
//===----------------------------------------------------------------------===//

public protocol BinaryInteger :
  Hashable, Numeric/*, CustomStringConvertible, Strideable
  where Magnitude : BinaryInteger, Magnitude.Magnitude == Magnitude*/

{ 
  static var isSigned: Bool { get }

  init?<T : BinaryFloatingPoint>(exactly source: T)

  init<T : BinaryFloatingPoint>(_ source: T)

  init<T : BinaryInteger>(_ source: T)

  init<T : BinaryInteger>(truncatingIfNeeded source: T)

  init<T : BinaryInteger>(clamping source: T)

  var _lowWord: UInt { get }

  var bitWidth : Int { get }

  var trailingZeroBitCount: Int { get }

  static func /(_ lhs: Self, _ rhs: Self) -> Self

  static func /=(_ lhs: inout Self, _ rhs: Self)

  static func %(_ lhs: Self, _ rhs: Self) -> Self

  static func %=(_ lhs: inout Self, _ rhs: Self)

  static func +(_ lhs: Self, _ rhs: Self) -> Self

  static func -(_ lhs: Self, _ rhs: Self) -> Self

  static func -=(_ lhs: inout Self, _ rhs: Self)

  static func *(_ lhs: Self, _ rhs: Self) -> Self

  static func *=(_ lhs: inout Self, _ rhs: Self)

  static prefix func ~ (_ x: Self) -> Self

  static func &(_ lhs: Self, _ rhs: Self) -> Self

  static func &=(_ lhs: inout Self, _ rhs: Self)

  static func |(_ lhs: Self, _ rhs: Self) -> Self

  static func |=(_ lhs: inout Self, _ rhs: Self)

  static func ^(_ lhs: Self, _ rhs: Self) -> Self

  static func ^=(_ lhs: inout Self, _ rhs: Self)

  static func >><RHS: BinaryInteger>(
    _ lhs: Self, _ rhs: RHS
  ) -> Self

  static func >>=<RHS: BinaryInteger>(
    _ lhs: inout Self, _ rhs: RHS)

  static func <<<RHS: BinaryInteger>(
    _ lhs: Self, _ rhs: RHS
  ) -> Self

  static func <<=<RHS: BinaryInteger>(
    _ lhs: inout Self, _ rhs: RHS)

  func quotientAndRemainder(dividingBy rhs: Self)
    -> (quotient: Self, remainder: Self)

  func signum() -> Self
}

extension Int {
  // FIXME(ABI): using Int as the return type is wrong.
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  public func distance(to other: Int) -> Int {
    return other - self
  }

  // FIXME(ABI): using Int as the parameter type is wrong.
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  public func advanced(by n: Int) -> Int {
    return self + n
  }
 }

//===----------------------------------------------------------------------===//
//===--- Heterogeneous comparison -----------------------------------------===//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
//===--- Ambiguity breakers -----------------------------------------------===//
// These two versions of the operators are not ordered with respect to one
// another, but the compiler choses the second one, and that results in infinite
// recursion.
//
//     <T : Comparable>(T, T) -> Bool
//     <T : BinaryInteger, U : BinaryInteger>(T, U) -> Bool
//
// so we define:
//
//     <T : BinaryInteger>(T, T) -> Bool
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
//===--- FixedWidthInteger ------------------------------------------------===//
//===----------------------------------------------------------------------===//

public protocol FixedWidthInteger  :
  BinaryInteger, LosslessStringConvertible/*, _BitwiseOperations
  where Magnitude : FixedWidthInteger*/
{ 
  static var bitWidth : Int { get }

  static var max: Self { get }

  static var min: Self { get }

  func addingReportingOverflow(
    _ rhs: Self
  ) -> (partialValue: Self, overflow: Bool)

  func subtractingReportingOverflow(
    _ rhs: Self
  ) -> (partialValue: Self, overflow: Bool)

  func multipliedReportingOverflow(
    by rhs: Self
  ) -> (partialValue: Self, overflow: Bool)

  func dividedReportingOverflow(
    by rhs: Self
  ) -> (partialValue: Self, overflow: Bool)

  func remainderReportingOverflow(
    dividingBy rhs: Self
  ) -> (partialValue: Self, overflow: Bool)

  /*func multipliedFullWidth(by other: Self) -> (high: Self, low: Self.Magnitude)*/

  /*func dividingFullWidth(_ dividend: (high: Self, low: Self.Magnitude))
    -> (quotient: Self, remainder: Self)*/

  init(_truncatingBits bits: UInt)

  var nonzeroBitCount: Int { get }
}

extension FixedWidthInteger { }

//===----------------------------------------------------------------------===//
//===--- Operators on FixedWidthInteger -----------------------------------===//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
//===--- Concrete FixedWidthIntegers --------------------------------------===//
//===----------------------------------------------------------------------===//

extension UInt16 {
  init(_: UInt8) {
    self.init()
  }
}