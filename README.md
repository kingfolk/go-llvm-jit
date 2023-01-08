# go llvm jit

此llvm例子项目，可以结合文章https://zhuanlan.zhihu.com/p/597540136

开发的llvm版本为llvm 14，其他的llvm版本可能会出现问题。

主要存放一些go使用llvm的例子，llvm目录为llvm version 11的官方go bindings，经历了迁移到llvm 14的binding修改，和其他增加了一些额外的binding，该目录下的binding是比较脏且没有经过完全测试的，很可能部分api是有问题的。

## 怎么运行例子

本地编译llvm，可以参考gocaml的编译，gocaml因为是使用go binding开发llvm的，编译llvm时，会生成有意义的llvm_config。

- https://github.com/rhysd/gocaml/blob/master/scripts/install_llvmgo.sh

编译得到的llvm_config.go替换llvm目录下的llvm_config.go。可能出现动态链接库缺失的情况，如出现，则再参考此repo里的llvm_config.go中的LDFLAGS，因为编译的makefile可能并没有将所有需要的动态链接库加到LDFLAGS里。

因为此repo主要为一下简陋的llvm example，而编译llvm很重，所有如上的编译步骤也很简陋。理想的使用方式是，各位开发者已经有编译好的llvm和自己维护的go binding，如本项目例子里对各位有额外的帮助，则直接摘抄即可。
