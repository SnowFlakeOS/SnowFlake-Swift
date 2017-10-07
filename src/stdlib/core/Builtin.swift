
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

@_inlineable // FIXME(sil-serialize-all)
@_versioned
@inline(__always)
internal func _roundUpImpl(_ offset: UInt, toAlignment alignment: Int) -> UInt {
  _sanityCheck(alignment > 0)
  _sanityCheck(_isPowerOf2(alignment))
  // Note, given that offset is >= 0, and alignment > 0, we don't
  // need to underflow check the -1, as it can never underflow.
  let x = offset + UInt(bitPattern: alignment) &- 1
  // Note, as alignment is a power of 2, we'll use masking to efficiently
  // get the aligned value
  return x & ~(UInt(bitPattern: alignment) &- 1)
}

@_inlineable // FIXME(sil-serialize-all)
@_versioned
internal func _roundUp(_ offset: UInt, toAlignment alignment: Int) -> UInt {
  return _roundUpImpl(offset, toAlignment: alignment)
}

@_inlineable // FIXME(sil-serialize-all)
@_versioned
internal func _roundUp(_ offset: Int, toAlignment alignment: Int) -> Int {
  _sanityCheck(offset >= 0)
  return Int(_roundUpImpl(UInt(bitPattern: offset), toAlignment: alignment))
}

/// Returns a tri-state of 0 = no, 1 = yes, 2 = maybe.
@_inlineable // FIXME(sil-serialize-all)
@_transparent
public // @testable
func _canBeClass<T>(_: T.Type) -> Int8 {
  return Int8(Builtin.canBeClass(T.self))
}
