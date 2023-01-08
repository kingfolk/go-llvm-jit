//===- transforms_scalar.go - Bindings for scalaropts ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines bindings for the scalaropts component.
//
//===----------------------------------------------------------------------===//

package llvm

/*
#include "llvm-c/Transforms/Vectorize.h"
*/
import "C"

func (pm PassManager) AddLoopVectorizePass() { C.LLVMAddLoopVectorizePass(pm.C) }
func (pm PassManager) AddSLPVectorizePass()  { C.LLVMAddSLPVectorizePass(pm.C) }
