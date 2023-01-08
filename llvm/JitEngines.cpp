#include "JitEngines.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Orc/ObjectLinkingLayer.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"

#include "llvm-c/TargetMachine.h"
#include "llvm/IR/Operator.h"
#include "llvm-c/LLJIT.h"

using namespace llvm;
using namespace llvm::orc;

DEFINE_SIMPLE_CONVERSION_FUNCTIONS(TargetMachine, LLVMTargetMachineRef);
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(GenericValue, LLVMGenericValueRef);

LLVMBool LLVMCreateMCJITCompilerWithTMForModule(LLVMExecutionEngineRef *OutJIT,
                                                LLVMModuleRef M,
                                                LLVMTargetMachineRef TM,
                                                const char **OutError) {
    llvm::EngineBuilder eb(std::unique_ptr<llvm::Module>(unwrap(M)));
    std::string err;
    eb.setErrorStr(&err);
    eb.setEngineKind(llvm::EngineKind::JIT);
    eb.setOptLevel(CodeGenOpt::Aggressive);

    /* EngineBuilder::create loads the current process symbols */
    llvm::ExecutionEngine *engine = eb.create(unwrap(TM));

    if (engine) {
        *OutJIT = llvm::wrap(engine);
        return 0;
    }
    *OutError = strdup(err.c_str());
    return 1;
}

DEFINE_SIMPLE_CONVERSION_FUNCTIONS(LLJIT, LLVMOrcLLJITRef)

LLVMErrorRef LLVMCreateOrcLLJITCppImpl(LLVMOrcLLJITRef *OutJIT, LLVMContextRef C) {
    auto triple = Triple(Twine("x86_64-apple-macosx12.0.0"));
    auto JTMB = new JITTargetMachineBuilder(triple);
    JTMB->setCPU("skylake");
    JTMB->setCodeGenOptLevel(CodeGenOpt::Default);

    auto builder = LLJITBuilder();
    auto J = builder
        .setJITTargetMachineBuilder(*JTMB)
        // .setObjectLinkingLayerCreator(
        //       [&](ExecutionSession &ES, const Triple &TT) {
        //         return std::make_unique<llvm::orc::ObjectLinkingLayer>(
        //             ES, std::make_unique<llvm::jitlink::InProcessMemoryManager>());
        //       })
        .create();

    if (!J) {
        OutJIT = 0;
        return wrap(J.takeError());
    }

    auto JJ = J->release();
    JJ->getMainJITDylib().addGenerator(
        cantFail(DynamicLibrarySearchGenerator::GetForCurrentProcess(
            JJ->getDataLayout().getGlobalPrefix())));

    *OutJIT = wrap(JJ);
    return LLVMErrorSuccess;
}

LLVMBool LLVMMCJITEmitMCObject(LLVMExecutionEngineRef EE,
                               LLVMModuleRef M,
                               LLVMMemoryBufferRef *OutMemBuf) {
    auto TM = unwrap(EE)->getTargetMachine();
    legacy::PassManager PM;
    SmallVector<char, 4096> ObjBufferSV;
    raw_svector_ostream ObjStream(ObjBufferSV);
    MCContext *Ctx(nullptr);
    if (TM->addPassesToEmitMC(PM, Ctx, ObjStream, true)) {
        return 1;
    }

    PM.run(*unwrap(M));

    StringRef Data = ObjStream.str();
    *OutMemBuf = LLVMCreateMemoryBufferWithMemoryRangeCopy(Data.data(), Data.size(), "");

    return 0;
}

LLVMBool LLVMTMEmitMCObject(LLVMTargetMachineRef TM,
                            LLVMModuleRef M,
                            LLVMMemoryBufferRef *OutMemBuf) {
    legacy::PassManager PM;
    SmallVector<char, 4096> ObjBufferSV;
    raw_svector_ostream ObjStream(ObjBufferSV);
    MCContext *Ctx(nullptr);
    auto t = unwrap(TM);
    if (t->addPassesToEmitMC(PM, Ctx, ObjStream, true)) {
        return 1;
    }

    PM.run(*unwrap(M));

    StringRef Data = ObjStream.str();
    *OutMemBuf = LLVMCreateMemoryBufferWithMemoryRangeCopy(Data.data(), Data.size(), "");

    return 0;
}

char* LLVMGenericValueToString(LLVMGenericValueRef GenValRef) {
    GenericValue *GenVal = unwrap(GenValRef);
    void * datum = (void *)GenVal->IntVal.getSExtValue();
    return (char*) datum;
}

void* LLVMGenericValueToVoidPointer(LLVMGenericValueRef GenValRef) {
    GenericValue *GenVal = unwrap(GenValRef);
    return (void *)GenVal->IntVal.getSExtValue();
}

uint64_t LLVMRunFunctionAddress(uint64_t addr) {
    uint64_t (*FP)() = (uint64_t (*)())(intptr_t)addr;
    uint64_t res = FP();
    return res;
}

uint64_t LLVMRunFunctionAddress1Arg(uint64_t addr, void* arg) {
    uint64_t (*FP)(void*) = (uint64_t (*)(void*))(intptr_t)addr;
    uint64_t res = FP((void*)arg);
    return res;
}

uint64_t LLVMRunFunctionAddress2Arg(uint64_t addr, void* arg1, void* arg2) {
    uint64_t (*FP)(void*, void*) = (uint64_t (*)(void*, void*))(intptr_t)addr;
    uint64_t res = FP((void*)arg1, (void*)arg2);
    return res;
}

void LLVMLoadLibraryPermanentlyNull() {
    llvm::sys::DynamicLibrary::LoadLibraryPermanently(nullptr);
}
