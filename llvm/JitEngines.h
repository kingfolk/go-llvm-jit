#ifndef LLVM_C_JITENGINE_H
#define LLVM_C_JITENGINE_H

#include "llvm-c/Core.h"
#include "llvm-c/ExecutionEngine.h"
#include "llvm-c/LLJIT.h"

#ifdef __cplusplus
extern "C" {
#endif

LLVMBool LLVMCreateMCJITCompilerWithTMForModule(LLVMExecutionEngineRef *OutJIT,
                                                LLVMModuleRef M,
                                                LLVMTargetMachineRef TM,
                                                const char **OutError);

LLVMErrorRef LLVMCreateOrcLLJITCppImpl(LLVMOrcLLJITRef *OutJIT, LLVMContextRef C);

LLVMBool LLVMMCJITEmitMCObject(LLVMExecutionEngineRef EE,
                               LLVMModuleRef M,
                               LLVMMemoryBufferRef *OutMemBuf);

LLVMBool LLVMTMEmitMCObject(LLVMTargetMachineRef TM,
                            LLVMModuleRef M,
                            LLVMMemoryBufferRef *OutMemBuf);

// LLVMGenericValueToVoidPointer kundb jit specific api. convert Datum(uintptr) to char*
char* LLVMGenericValueToString(LLVMGenericValueRef GenValRef);

// LLVMGenericValueToVoidPointer kundb jit specific api. convert Datum(uintptr) to void*
void* LLVMGenericValueToVoidPointer(LLVMGenericValueRef GenValRef);

uint64_t LLVMRunFunctionAddress(uint64_t addr);

uint64_t LLVMRunFunctionAddress1Arg(uint64_t addr, void* arg);

uint64_t LLVMRunFunctionAddress2Arg(uint64_t addr, void* arg1, void* arg2);

void LLVMLoadLibraryPermanentlyNull();

#ifdef __cplusplus
}
#endif

#endif

