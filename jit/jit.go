package jit

import "C"
import (
	"unsafe"

	"github.com/kingfolk/llvm-vectorization/llvm"
)

var intT = llvm.Int64Type()
var doubleT = llvm.DoubleType()

func CodegenSumInt64() llvm.Module {
	module := llvm.NewModule("accum")
	builder := llvm.NewBuilder()
	paramTypes := []llvm.Type{
		llvm.PointerType(intT, 0),
		llvm.PointerType(intT, 0), llvm.PointerType(llvm.Int8Type(), 0),
	}

	funcType := llvm.FunctionType(intT, paramTypes, false)
	theFunction := llvm.AddFunction(module, "sum_int64", funcType)
	if theFunction.IsNil() {
		panic("theFunction.IsNil")
	}

	entry := llvm.AddBasicBlock(theFunction, "0")
	builder.SetInsertPointAtEnd(entry)

	datumPtr := theFunction.Param(1)
	loopEnd := theFunction.Param(0)
	loopEnd = builder.CreateLoad(loopEnd, "")

	accum := builder.CreateAlloca(intT, "")
	builder.CreateStore(llvm.ConstInt(intT, 0, true), accum)

	buildLoop(builder, loopEnd, func(it llvm.Value) {
		v := buildArrLoad(builder, datumPtr, it)
		res := builder.CreateLoad(accum, "")
		res = builder.CreateAdd(res, v, "add")
		builder.CreateStore(res, accum)
	})

	ret := builder.CreateLoad(accum, "")
	builder.CreateRet(ret)

	return module
}

func CodegenSumFloat64() llvm.Module {
	module := llvm.NewModule("accum")
	builder := llvm.NewBuilder()
	paramTypes := []llvm.Type{
		llvm.PointerType(intT, 0),
		llvm.PointerType(doubleT, 0), llvm.PointerType(llvm.Int8Type(), 0),
	}

	funcType := llvm.FunctionType(intT, paramTypes, false)
	theFunction := llvm.AddFunction(module, "sum_float64", funcType)
	if theFunction.IsNil() {
		panic("theFunction.IsNil")
	}

	entry := llvm.AddBasicBlock(theFunction, "0")
	builder.SetInsertPointAtEnd(entry)

	datumPtr := theFunction.Param(1)
	loopEnd := theFunction.Param(0)
	loopEnd = builder.CreateLoad(loopEnd, "")

	accum := builder.CreateAlloca(doubleT, "")
	builder.CreateStore(llvm.ConstFloat(doubleT, 0), accum)

	buildLoop(builder, loopEnd, func(it llvm.Value) {
		v := buildArrLoad(builder, datumPtr, it)
		res := builder.CreateLoad(accum, "")
		res = builder.CreateFAdd(res, v, "fadd")
		res.MarkFastMathFlags()
		builder.CreateStore(res, accum)
	})

	ret := builder.CreateLoad(accum, "")
	ret = builder.CreateBitCast(ret, intT, "")
	builder.CreateRet(ret)

	return module
}

func buildLoop(builder llvm.Builder, end llvm.Value, blockFn func(it llvm.Value)) llvm.Value {
	start := llvm.ConstInt(intT, 0, false)
	if start.IsNil() {
		panic("start is nil")
	}
	if end.IsNil() {
		panic("cond is nil")
	}

	parentFunc := builder.GetInsertBlock().Parent()
	preheaderBlk := builder.GetInsertBlock()
	loopBlk := llvm.AddBasicBlock(parentFunc, "loop")
	afterBlk := llvm.AddBasicBlock(parentFunc, "after")

	builder.CreateBr(loopBlk)
	builder.SetInsertPointAtEnd(loopBlk)

	phiVar := builder.CreatePHI(intT, "")
	phiVar.AddIncoming([]llvm.Value{start}, []llvm.BasicBlock{preheaderBlk})

	blockFn(phiVar)

	nextIt := builder.CreateAdd(phiVar, llvm.ConstInt(intT, uint64(1), true), "step")
	loopEndBlk := builder.GetInsertBlock()
	// TODO 这个比较应该挪到循环开头
	phiVar.AddIncoming([]llvm.Value{nextIt}, []llvm.BasicBlock{loopEndBlk})

	endCond := builder.CreateICmp(llvm.IntSLT, nextIt, end, "<")
	builder.CreateCondBr(endCond, loopBlk, afterBlk)

	builder.SetInsertPointAtEnd(afterBlk)

	return llvm.ConstNull(intT)
}

func buildArrLoad(builder llvm.Builder, arr, idx llvm.Value) llvm.Value {
	elemPtr := builder.CreateInBoundsGEP(arr, []llvm.Value{idx}, "")
	return builder.CreateLoad(elemPtr, "arrload")
}

func castUint64AsFloat64(v uint64) float64 {
	vv := *(*C.double)(unsafe.Pointer(&v))
	return float64(vv)
}
