package jit

import (
	"fmt"
	"testing"
	"unsafe"

	"github.com/kingfolk/llvm-vectorization/llvm"
)

// var debugMode bool
var debugMode bool = true
var VecSize = 102400

func debugIR(modified bool, module llvm.Module, targetMachine llvm.TargetMachine) {
	if !debugMode {
		return
	}
	if modified {
		fmt.Println("********** pass manager optimized **********")
		module.Dump()
		fmt.Println("********** pass manager end **********")
	}
	lbuf, err := targetMachine.EmitToMemoryBuffer(module, llvm.AssemblyFile)
	if err != nil {
		panic(err)
	}
	fmt.Println("********** asm **********")
	fmt.Println(string(lbuf.Bytes()))
	fmt.Println("********** asm end **********")
}

func BenchmarkJitSumInt(b *testing.B) {
	var buf []int64
	for i := 0; i < VecSize; i++ {
		buf = append(buf, int64(i))
	}
	data := unsafe.Pointer(&buf[0])

	llvm.InitializeNativeTarget()
	llvm.InitializeNativeAsmPrinter()
	triple := llvm.DefaultTargetTriple()
	cpu := "skylake"
	target, err := llvm.GetTargetFromTriple(triple)
	if err != nil {
		panic(err)
	}
	targetMachine := target.CreateTargetMachine(triple, cpu, "+avx2", 2, 0, 0)

	module := CodegenSumInt64()
	module.SetTarget(targetMachine.Triple())
	module.SetDataLayout(targetMachine.CreateTargetData().String())
	if debugMode {
		module.Dump()
	}

	execEngine, err := llvm.CreateLLJITFromTM(targetMachine)
	// execEngine, err := llvm.CreateLLJITForHost()
	// execEngine, err := llvm.CreateLLJITFromCppImpl(llvm.GlobalContext())
	if err != nil {
		panic(err)
	}

	passmgr := llvm.NewPassManager()
	pmb := initPassManagerBuilder()
	// CreateLLJITFromTM会dispose TargetMachine，此处需要额外创建
	targetMachine = target.CreateTargetMachine(triple, cpu, "+avx2", 2, 0, 0)
	targetMachine.AddAnalysisPasses(passmgr)
	pmb.Populate(passmgr)

	modified := passmgr.Run(module)
	debugIR(modified, module, targetMachine)

	var expected int64
	b.Run("go", func(b *testing.B) {
		b.ResetTimer()
		for i := 0; i < b.N; i++ {
			expected = 0
			for j := 0; j < VecSize; j++ {
				expected += buf[j]
			}
		}
	})

	execEngine.AddModule(module)
	addr, err := execEngine.Lookup("sum_int64")
	if err != nil {
		panic(err)
	}

	vecsize := unsafe.Pointer(&VecSize)
	var actual uint64
	actual = execEngine.RunFunctionAddressWithArgPtrs(addr, vecsize, data)
	b.Run("jit", func(b *testing.B) {
		b.ResetTimer()
		for i := 0; i < b.N; i++ {
			actual = execEngine.RunFunctionAddressWithArgPtrs(addr, vecsize, data)
		}
	})

	if expected != int64(actual) {
		panic("jit fail")
	}
}

func BenchmarkJitSumDouble(b *testing.B) {
	var buf []float64
	for i := 0; i < VecSize; i++ {
		buf = append(buf, float64(i))
	}
	data := unsafe.Pointer(&buf[0])

	llvm.InitializeNativeTarget()
	llvm.InitializeNativeAsmPrinter()
	triple := llvm.DefaultTargetTriple()
	cpu := "skylake"
	target, err := llvm.GetTargetFromTriple(triple)
	if err != nil {
		panic(err)
	}
	targetMachine := target.CreateTargetMachine(triple, cpu, "+avx2", 2, 0, 0)

	module := CodegenSumFloat64()
	module.SetTarget(targetMachine.Triple())
	module.SetDataLayout(targetMachine.CreateTargetData().String())
	if debugMode {
		module.Dump()
	}

	execEngine, err := llvm.CreateLLJITFromTM(targetMachine)
	// execEngine, err := llvm.CreateLLJITForHost()
	// execEngine, err := llvm.CreateLLJITFromCppImpl(llvm.GlobalContext())
	if err != nil {
		panic(err)
	}

	passmgr := llvm.NewPassManager()
	pmb := initPassManagerBuilder()
	// CreateLLJITFromTM会dispose TargetMachine，此处需要额外创建
	targetMachine = target.CreateTargetMachine(triple, cpu, "+avx2", 2, 0, 0)
	targetMachine.AddAnalysisPasses(passmgr)
	pmb.Populate(passmgr)

	modified := passmgr.Run(module)
	debugIR(modified, module, targetMachine)

	var expected float64
	b.Run("go", func(b *testing.B) {
		b.ResetTimer()
		for i := 0; i < b.N; i++ {
			expected = 0
			for j := 0; j < VecSize; j++ {
				expected += buf[j]
			}
		}
	})

	execEngine.AddModule(module)
	addr, err := execEngine.Lookup("sum_float64")
	if err != nil {
		panic(err)
	}

	vecsize := unsafe.Pointer(&VecSize)
	var actual float64
	var v uint64
	execEngine.RunFunctionAddressWithArgPtrs(addr, vecsize, data)
	b.Run("jit", func(b *testing.B) {
		b.ResetTimer()
		for i := 0; i < b.N; i++ {
			v = execEngine.RunFunctionAddressWithArgPtrs(addr, vecsize, data)
		}
	})

	fmt.Println("v", v)
	actual = castUint64AsFloat64(v)
	fmt.Println("actual", actual)

	if expected != actual {
		fmt.Println("expected, actual", expected, actual)
		panic("jit fail")
	}
}

func initPassManagerBuilder() llvm.PassManagerBuilder {
	pmb := llvm.NewPassManagerBuilder()
	pmb.SetOptLevel(2)
	pmb.SetSizeLevel(1)
	return pmb
}
