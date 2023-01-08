package llvm

/*
#include "llvm-c/IRReader.h"
#include "llvm-c/Core.h"
#include <stdlib.h>
*/
import "C"
import (
	"errors"
	"unsafe"
)

// ParseIRInContext parses the LLVM IR ) in the buffer, and returns a new LLVM module.
func ParseIRInContext(ctx Context, buf MemoryBuffer) (Module, error) {
	var m Module
	var errmsg *C.char
	if C.LLVMParseIRInContext(ctx.C, buf.C, &m.C, &errmsg) == 0 {
		return m, nil
	}

	err := errors.New(C.GoString(errmsg))
	C.free(unsafe.Pointer(errmsg))
	return Module{}, err
}
