# 替换LLVM_BINPATH为你当前llvm编译的bin位置
LLVM_BINPATH = /Users/king/go/src/llvm.org/llvm/bindings/go/llvm/workdir/llvm_build/bin
CLANG = $(LLVM_BINPATH)/clang
BITCODE_CFLAGS =  -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument -O3 -mavx2 -ffast-math

CPPFLAGS =  -D_GNU_SOURCE -I/usr/include/libxml2 -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -I/Users/king/go/src/llvm.org/llvm/include -I/Users/king/go/src/llvm.org/llvm/bindings/go/llvm/workdir/llvm_build/include

COMPILE.c = $(CLANG) -Wno-ignored-attributes $(BITCODE_CFLAGS) $(CPPFLAGS) -flto=full -emit-llvm -c

LLVM_DIS = $(LLVM_BINPATH)/llvm-dis


sum: sum.c
	$(COMPILE.c) -o sum.bc sum.c

sumll: sum.bc
	$(LLVM_DIS) sum.bc -o sum.ll