//===--- ManglingMacros.h - Macros for Swift symbol mangling ----*- C++ -*-===//
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

#ifndef SWIFT_BASIC_MANGLING_MACROS_H
#define SWIFT_BASIC_MANGLING_MACROS_H

// The following macro enables the "new" mangling, which has an _S prefix rather
// then the original _T prefix.
// TODO: When we get rid of the old mangling, the term "new mangling" should
// just be renamed to "mangling".

//#define USE_NEW_MANGLING

#define STRINGIFY_MANGLING(M) #M
#define MANGLE_AS_STRING(M) STRINGIFY_MANGLING(M)

/// The mangling prefix for the new mangling.
#define MANGLING_PREFIX _T0

#define MANGLING_PREFIX_STR MANGLE_AS_STRING(MANGLING_PREFIX)

// The following macros help to create symbol manglings. They can be used
// if a mangled name is needed at compile-time, e.g. for variable names in the
// swift runtime libraries.

#define MANGLING_CONCAT2_IMPL(a, b) a##b
#define MANGLING_CONCAT3_IMPL(a, b, c) a##b##c

#ifdef USE_NEW_MANGLING

#define MANGLING_CONCAT2(a, b) MANGLING_CONCAT2_IMPL(a, b)
#define MANGLING_CONCAT3(a, b, c) MANGLING_CONCAT3_IMPL(a, b, c)
#define MANGLE_SYM(Ops) MANGLING_CONCAT2(MANGLING_PREFIX, Ops)
#define SELECT_MANGLING(Old, New) MANGLE_SYM(New)
#define METADATA_MANGLING N
#define METATYPE_MANGLING m
#define EMPTY_TUPLE_MANGLING yt
#define NO_ARGS_MANGLING yy
#define FUNC_TYPE_MANGLING c
#define OBJC_PARTIAL_APPLY_THUNK_MANGLING Ta
#define OPTIONAL_MANGLING(Ty) MANGLING_CONCAT2_IMPL(Ty, Sg)

#else

#define MANGLING_CONCAT2(a, b) MANGLING_CONCAT2_IMPL(b, a)
#define MANGLING_CONCAT3(a, b, c) MANGLING_CONCAT3_IMPL(c, b, a)
#define MANGLE_SYM(Ops) MANGLING_CONCAT2_IMPL(_T, Ops)
#define SELECT_MANGLING(Old, New) MANGLE_SYM(Old)
#define METADATA_MANGLING M
#define METATYPE_MANGLING M
#define EMPTY_TUPLE_MANGLING T_
#define NO_ARGS_MANGLING T_T_
#define FUNC_TYPE_MANGLING F
#define OBJC_PARTIAL_APPLY_THUNK_MANGLING PAo
#define OPTIONAL_MANGLING(Ty) MANGLING_CONCAT3_IMPL(GSq, Ty, _)

#endif

#define FUNCTION_MANGLING \
          MANGLING_CONCAT2(NO_ARGS_MANGLING, FUNC_TYPE_MANGLING)

#define THIN_FUNCTION_MANGLING \
          MANGLING_CONCAT2(NO_ARGS_MANGLING, Xf)

#define METADATA_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT2(Ty, METADATA_MANGLING))

#define STRUCT_METADATA_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, V, METADATA_MANGLING))

#define CLASS_METADATA_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, C, METADATA_MANGLING))

#define STRUCT_MD_ACCESSOR_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, V, Ma))

#define VALUE_WITNESS_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT2(Ty, WV))

#define UNOWNED_VALUE_WITNESS_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, Xo, WV))

#define WEAK_VALUE_WITNESS_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(OPTIONAL_MANGLING(Ty), Xw, WV))

#define METATYPE_VALUE_WITNESS_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, METATYPE_MANGLING, WV))

#define NOMINAL_TYPE_DESCR_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT2(Ty, Mn))

#define STRUCT_TYPE_DESCR_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT3(Ty, V, Mn))

#define PROTOCOL_DESCR_SYM(Ty) \
          MANGLE_SYM(MANGLING_CONCAT2(Ty, Mp))

#define OBJC_PARTIAL_APPLY_THUNK_SYM \
          MANGLE_SYM(OBJC_PARTIAL_APPLY_THUNK_MANGLING)

#endif // SWIFT_BASIC_MANGLING_MACROS_H

