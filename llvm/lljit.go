package llvm

/*
#include "llvm-c/Core.h"
#include "llvm-c/LLJIT.h"
#include "llvm-c/Orc.h"
#include <stdlib.h>

#include "./JitEngines.h"
*/
import "C"
import (
	"errors"
	"unsafe"
)

type LLJitEngine struct {
	C C.LLVMOrcLLJITRef
}

type OrcExecutorAddress struct {
	C C.LLVMOrcExecutorAddress
}

type OrcJITDylib struct {
	C C.LLVMOrcJITDylibRef
}

type OrcThreadSafeContext struct {
	C C.LLVMOrcThreadSafeContextRef
}

type LLVMOrcThreadSafeModule struct {
	C C.LLVMOrcThreadSafeModuleRef
}

func CreateLLJITFromCppImpl(ctx Context) (ee LLJitEngine, err error) {
	cerr := C.LLVMCreateOrcLLJITCppImpl(&ee.C, ctx.C)
	if cerr != nil {
		cmsg := C.LLVMGetErrorMessage(cerr)
		err = errors.New(C.GoString(cmsg))
		C.LLVMDisposeMessage(cmsg)
	}
	return
}

func CreateLLJITForHost() (ee LLJitEngine, err error) {
	var jtmb C.LLVMOrcJITTargetMachineBuilderRef
	cerr := C.LLVMOrcJITTargetMachineBuilderDetectHost(&jtmb)
	if cerr != nil {
		cmsg := C.LLVMGetErrorMessage(cerr)
		err = errors.New(C.GoString(cmsg))
		C.LLVMDisposeMessage(cmsg)
		return
	}
	builder := C.LLVMOrcCreateLLJITBuilder()
	C.LLVMOrcLLJITBuilderSetJITTargetMachineBuilder(builder, jtmb)
	cerr = C.LLVMOrcCreateLLJIT(&ee.C, builder)
	if cerr != nil {
		cmsg := C.LLVMGetErrorMessage(cerr)
		err = errors.New(C.GoString(cmsg))
		C.LLVMDisposeMessage(cmsg)
		return
	}
	return
}

func CreateLLJITFromTM(tm TargetMachine) (ee LLJitEngine, err error) {
	jtmb := C.LLVMOrcJITTargetMachineBuilderCreateFromTargetMachine(tm.C)
	builder := C.LLVMOrcCreateLLJITBuilder()
	C.LLVMOrcLLJITBuilderSetJITTargetMachineBuilder(builder, jtmb)
	cerr := C.LLVMOrcCreateLLJIT(&ee.C, builder)
	if cerr != nil {
		cmsg := C.LLVMGetErrorMessage(cerr)
		err = errors.New(C.GoString(cmsg))
		C.LLVMDisposeMessage(cmsg)
	}
	return
}

func (ee LLJitEngine) Lookup(name string) (addr OrcExecutorAddress, err error) {
	cname := C.CString(name)
	defer C.free(unsafe.Pointer(cname))
	cerr := C.LLVMOrcLLJITLookup(ee.C, &addr.C, cname)
	if cerr != nil {
		cmsg := C.LLVMGetErrorMessage(cerr)
		err = errors.New(C.GoString(cmsg))
		C.LLVMDisposeMessage(cmsg)
	}
	return
}

func (ee LLJitEngine) AddModule(m Module) {
	lib := ee.GetMainJITDylib()
	M := OrcThreadSafModuleWrap(m)
	C.LLVMOrcLLJITAddLLVMIRModule(ee.C, lib.C, M.C)
}

func OrcThreadSafModuleWrap(m Module) (M LLVMOrcThreadSafeModule) {
	tctx := C.LLVMOrcCreateNewThreadSafeContext()
	M.C = C.LLVMOrcCreateNewThreadSafeModule(m.C, tctx)
	return
}

func (ee LLJitEngine) GetMainJITDylib() (lib OrcJITDylib) {
	lib.C = C.LLVMOrcLLJITGetMainJITDylib(ee.C)
	return
}

func (ee LLJitEngine) RunFunctionAddressWithArgPtrs(fa OrcExecutorAddress, args ...unsafe.Pointer) uint64 {
	var res C.ulonglong
	if len(args) == 1 {
		res = C.LLVMRunFunctionAddress1Arg(fa.C, args[0])
	} else if len(args) == 2 {
		res = C.LLVMRunFunctionAddress2Arg(fa.C, args[0], args[1])
	} else {
		panic("TODO: unsupported variable size of argument")
	}
	return uint64(res)
}
