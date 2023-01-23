; ModuleID = 'sum.bc'
source_filename = "sum.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx12.0.0"

; Function Attrs: nofree norecurse nosync nounwind readonly ssp uwtable
define i64 @sum_int64(i64* nocapture noundef readonly %a, i32 noundef %count) local_unnamed_addr #0 {
entry:
  %cmp6 = icmp sgt i32 %count, 0
  br i1 %cmp6, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = zext i32 %count to i64
  %min.iters.check = icmp ult i32 %count, 16
  br i1 %min.iters.check, label %for.body.preheader18, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %n.vec = and i64 %wide.trip.count, 4294967280
  %0 = add nsw i64 %n.vec, -16
  %1 = lshr exact i64 %0, 4
  %2 = add nuw nsw i64 %1, 1
  %xtraiter = and i64 %2, 1
  %3 = icmp eq i64 %0, 0
  br i1 %3, label %middle.block.unr-lcssa, label %vector.ph.new

vector.ph.new:                                    ; preds = %vector.ph
  %unroll_iter = and i64 %2, 2305843009213693950
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph.new
  %index = phi i64 [ 0, %vector.ph.new ], [ %index.next.1, %vector.body ]
  %vec.phi = phi <4 x i64> [ zeroinitializer, %vector.ph.new ], [ %24, %vector.body ]
  %vec.phi10 = phi <4 x i64> [ zeroinitializer, %vector.ph.new ], [ %25, %vector.body ]
  %vec.phi11 = phi <4 x i64> [ zeroinitializer, %vector.ph.new ], [ %26, %vector.body ]
  %vec.phi12 = phi <4 x i64> [ zeroinitializer, %vector.ph.new ], [ %27, %vector.body ]
  %niter = phi i64 [ 0, %vector.ph.new ], [ %niter.next.1, %vector.body ]
  %4 = getelementptr i64, i64* %a, i64 %index
  %5 = bitcast i64* %4 to <4 x i64>*
  %wide.load = load <4 x i64>, <4 x i64>* %5, align 8
  %6 = getelementptr i64, i64* %4, i64 4
  %7 = bitcast i64* %6 to <4 x i64>*
  %wide.load13 = load <4 x i64>, <4 x i64>* %7, align 8
  %8 = getelementptr i64, i64* %4, i64 8
  %9 = bitcast i64* %8 to <4 x i64>*
  %wide.load14 = load <4 x i64>, <4 x i64>* %9, align 8
  %10 = getelementptr i64, i64* %4, i64 12
  %11 = bitcast i64* %10 to <4 x i64>*
  %wide.load15 = load <4 x i64>, <4 x i64>* %11, align 8
  %12 = add <4 x i64> %wide.load, %vec.phi
  %13 = add <4 x i64> %wide.load13, %vec.phi10
  %14 = add <4 x i64> %wide.load14, %vec.phi11
  %15 = add <4 x i64> %wide.load15, %vec.phi12
  %index.next = or i64 %index, 16
  %16 = getelementptr i64, i64* %a, i64 %index.next
  %17 = bitcast i64* %16 to <4 x i64>*
  %wide.load.1 = load <4 x i64>, <4 x i64>* %17, align 8
  %18 = getelementptr i64, i64* %16, i64 4
  %19 = bitcast i64* %18 to <4 x i64>*
  %wide.load13.1 = load <4 x i64>, <4 x i64>* %19, align 8
  %20 = getelementptr i64, i64* %16, i64 8
  %21 = bitcast i64* %20 to <4 x i64>*
  %wide.load14.1 = load <4 x i64>, <4 x i64>* %21, align 8
  %22 = getelementptr i64, i64* %16, i64 12
  %23 = bitcast i64* %22 to <4 x i64>*
  %wide.load15.1 = load <4 x i64>, <4 x i64>* %23, align 8
  %24 = add <4 x i64> %wide.load.1, %12
  %25 = add <4 x i64> %wide.load13.1, %13
  %26 = add <4 x i64> %wide.load14.1, %14
  %27 = add <4 x i64> %wide.load15.1, %15
  %index.next.1 = add nuw i64 %index, 32
  %niter.next.1 = add i64 %niter, 2
  %niter.ncmp.1 = icmp eq i64 %niter.next.1, %unroll_iter
  br i1 %niter.ncmp.1, label %middle.block.unr-lcssa, label %vector.body, !llvm.loop !5

middle.block.unr-lcssa:                           ; preds = %vector.body, %vector.ph
  %.lcssa21.ph = phi <4 x i64> [ undef, %vector.ph ], [ %24, %vector.body ]
  %.lcssa20.ph = phi <4 x i64> [ undef, %vector.ph ], [ %25, %vector.body ]
  %.lcssa19.ph = phi <4 x i64> [ undef, %vector.ph ], [ %26, %vector.body ]
  %.lcssa.ph = phi <4 x i64> [ undef, %vector.ph ], [ %27, %vector.body ]
  %index.unr = phi i64 [ 0, %vector.ph ], [ %index.next.1, %vector.body ]
  %vec.phi.unr = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %24, %vector.body ]
  %vec.phi10.unr = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %25, %vector.body ]
  %vec.phi11.unr = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %26, %vector.body ]
  %vec.phi12.unr = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %27, %vector.body ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %middle.block, label %vector.body.epil

vector.body.epil:                                 ; preds = %middle.block.unr-lcssa
  %28 = getelementptr i64, i64* %a, i64 %index.unr
  %29 = bitcast i64* %28 to <4 x i64>*
  %wide.load.epil = load <4 x i64>, <4 x i64>* %29, align 8
  %30 = getelementptr i64, i64* %28, i64 4
  %31 = bitcast i64* %30 to <4 x i64>*
  %wide.load13.epil = load <4 x i64>, <4 x i64>* %31, align 8
  %32 = getelementptr i64, i64* %28, i64 8
  %33 = bitcast i64* %32 to <4 x i64>*
  %wide.load14.epil = load <4 x i64>, <4 x i64>* %33, align 8
  %34 = getelementptr i64, i64* %28, i64 12
  %35 = bitcast i64* %34 to <4 x i64>*
  %wide.load15.epil = load <4 x i64>, <4 x i64>* %35, align 8
  %36 = add <4 x i64> %wide.load.epil, %vec.phi.unr
  %37 = add <4 x i64> %wide.load13.epil, %vec.phi10.unr
  %38 = add <4 x i64> %wide.load14.epil, %vec.phi11.unr
  %39 = add <4 x i64> %wide.load15.epil, %vec.phi12.unr
  br label %middle.block

middle.block:                                     ; preds = %vector.body.epil, %middle.block.unr-lcssa
  %.lcssa21 = phi <4 x i64> [ %.lcssa21.ph, %middle.block.unr-lcssa ], [ %36, %vector.body.epil ]
  %.lcssa20 = phi <4 x i64> [ %.lcssa20.ph, %middle.block.unr-lcssa ], [ %37, %vector.body.epil ]
  %.lcssa19 = phi <4 x i64> [ %.lcssa19.ph, %middle.block.unr-lcssa ], [ %38, %vector.body.epil ]
  %.lcssa = phi <4 x i64> [ %.lcssa.ph, %middle.block.unr-lcssa ], [ %39, %vector.body.epil ]
  %bin.rdx = add <4 x i64> %.lcssa20, %.lcssa21
  %bin.rdx16 = add <4 x i64> %.lcssa19, %bin.rdx
  %bin.rdx17 = add <4 x i64> %.lcssa, %bin.rdx16
  %40 = call i64 @llvm.vector.reduce.add.v4i64(<4 x i64> %bin.rdx17)
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader18

for.body.preheader18:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %res.07.ph = phi i64 [ 0, %for.body.preheader ], [ %40, %middle.block ]
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  %res.0.lcssa = phi i64 [ 0, %entry ], [ %40, %middle.block ], [ %add, %for.body ]
  ret i64 %res.0.lcssa

for.body:                                         ; preds = %for.body, %for.body.preheader18
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ %indvars.iv.ph, %for.body.preheader18 ]
  %res.07 = phi i64 [ %add, %for.body ], [ %res.07.ph, %for.body.preheader18 ]
  %arrayidx = getelementptr i64, i64* %a, i64 %indvars.iv
  %41 = load i64, i64* %arrayidx, align 8
  %add = add i64 %41, %res.07
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !8
}

; Function Attrs: nofree norecurse nosync nounwind readonly ssp uwtable
define double @sum_float64(double* nocapture noundef readonly %a, i32 noundef %count) local_unnamed_addr #0 {
entry:
  %cmp6 = icmp sgt i32 %count, 0
  br i1 %cmp6, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = zext i32 %count to i64
  %min.iters.check = icmp ult i32 %count, 16
  br i1 %min.iters.check, label %for.body.preheader18, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %n.vec = and i64 %wide.trip.count, 4294967280
  %0 = add nsw i64 %n.vec, -16
  %1 = lshr exact i64 %0, 4
  %2 = add nuw nsw i64 %1, 1
  %xtraiter = and i64 %2, 1
  %3 = icmp eq i64 %0, 0
  br i1 %3, label %middle.block.unr-lcssa, label %vector.ph.new

vector.ph.new:                                    ; preds = %vector.ph
  %unroll_iter = and i64 %2, 2305843009213693950
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph.new
  %index = phi i64 [ 0, %vector.ph.new ], [ %index.next.1, %vector.body ]
  %vec.phi = phi <4 x double> [ zeroinitializer, %vector.ph.new ], [ %24, %vector.body ]
  %vec.phi10 = phi <4 x double> [ zeroinitializer, %vector.ph.new ], [ %25, %vector.body ]
  %vec.phi11 = phi <4 x double> [ zeroinitializer, %vector.ph.new ], [ %26, %vector.body ]
  %vec.phi12 = phi <4 x double> [ zeroinitializer, %vector.ph.new ], [ %27, %vector.body ]
  %niter = phi i64 [ 0, %vector.ph.new ], [ %niter.next.1, %vector.body ]
  %4 = getelementptr double, double* %a, i64 %index
  %5 = bitcast double* %4 to <4 x double>*
  %wide.load = load <4 x double>, <4 x double>* %5, align 8
  %6 = getelementptr double, double* %4, i64 4
  %7 = bitcast double* %6 to <4 x double>*
  %wide.load13 = load <4 x double>, <4 x double>* %7, align 8
  %8 = getelementptr double, double* %4, i64 8
  %9 = bitcast double* %8 to <4 x double>*
  %wide.load14 = load <4 x double>, <4 x double>* %9, align 8
  %10 = getelementptr double, double* %4, i64 12
  %11 = bitcast double* %10 to <4 x double>*
  %wide.load15 = load <4 x double>, <4 x double>* %11, align 8
  %12 = fadd fast <4 x double> %wide.load, %vec.phi
  %13 = fadd fast <4 x double> %wide.load13, %vec.phi10
  %14 = fadd fast <4 x double> %wide.load14, %vec.phi11
  %15 = fadd fast <4 x double> %wide.load15, %vec.phi12
  %index.next = or i64 %index, 16
  %16 = getelementptr double, double* %a, i64 %index.next
  %17 = bitcast double* %16 to <4 x double>*
  %wide.load.1 = load <4 x double>, <4 x double>* %17, align 8
  %18 = getelementptr double, double* %16, i64 4
  %19 = bitcast double* %18 to <4 x double>*
  %wide.load13.1 = load <4 x double>, <4 x double>* %19, align 8
  %20 = getelementptr double, double* %16, i64 8
  %21 = bitcast double* %20 to <4 x double>*
  %wide.load14.1 = load <4 x double>, <4 x double>* %21, align 8
  %22 = getelementptr double, double* %16, i64 12
  %23 = bitcast double* %22 to <4 x double>*
  %wide.load15.1 = load <4 x double>, <4 x double>* %23, align 8
  %24 = fadd fast <4 x double> %wide.load.1, %12
  %25 = fadd fast <4 x double> %wide.load13.1, %13
  %26 = fadd fast <4 x double> %wide.load14.1, %14
  %27 = fadd fast <4 x double> %wide.load15.1, %15
  %index.next.1 = add nuw i64 %index, 32
  %niter.next.1 = add i64 %niter, 2
  %niter.ncmp.1 = icmp eq i64 %niter.next.1, %unroll_iter
  br i1 %niter.ncmp.1, label %middle.block.unr-lcssa, label %vector.body, !llvm.loop !10

middle.block.unr-lcssa:                           ; preds = %vector.body, %vector.ph
  %.lcssa21.ph = phi <4 x double> [ undef, %vector.ph ], [ %24, %vector.body ]
  %.lcssa20.ph = phi <4 x double> [ undef, %vector.ph ], [ %25, %vector.body ]
  %.lcssa19.ph = phi <4 x double> [ undef, %vector.ph ], [ %26, %vector.body ]
  %.lcssa.ph = phi <4 x double> [ undef, %vector.ph ], [ %27, %vector.body ]
  %index.unr = phi i64 [ 0, %vector.ph ], [ %index.next.1, %vector.body ]
  %vec.phi.unr = phi <4 x double> [ zeroinitializer, %vector.ph ], [ %24, %vector.body ]
  %vec.phi10.unr = phi <4 x double> [ zeroinitializer, %vector.ph ], [ %25, %vector.body ]
  %vec.phi11.unr = phi <4 x double> [ zeroinitializer, %vector.ph ], [ %26, %vector.body ]
  %vec.phi12.unr = phi <4 x double> [ zeroinitializer, %vector.ph ], [ %27, %vector.body ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %middle.block, label %vector.body.epil

vector.body.epil:                                 ; preds = %middle.block.unr-lcssa
  %28 = getelementptr double, double* %a, i64 %index.unr
  %29 = bitcast double* %28 to <4 x double>*
  %wide.load.epil = load <4 x double>, <4 x double>* %29, align 8
  %30 = getelementptr double, double* %28, i64 4
  %31 = bitcast double* %30 to <4 x double>*
  %wide.load13.epil = load <4 x double>, <4 x double>* %31, align 8
  %32 = getelementptr double, double* %28, i64 8
  %33 = bitcast double* %32 to <4 x double>*
  %wide.load14.epil = load <4 x double>, <4 x double>* %33, align 8
  %34 = getelementptr double, double* %28, i64 12
  %35 = bitcast double* %34 to <4 x double>*
  %wide.load15.epil = load <4 x double>, <4 x double>* %35, align 8
  %36 = fadd fast <4 x double> %wide.load.epil, %vec.phi.unr
  %37 = fadd fast <4 x double> %wide.load13.epil, %vec.phi10.unr
  %38 = fadd fast <4 x double> %wide.load14.epil, %vec.phi11.unr
  %39 = fadd fast <4 x double> %wide.load15.epil, %vec.phi12.unr
  br label %middle.block

middle.block:                                     ; preds = %vector.body.epil, %middle.block.unr-lcssa
  %.lcssa21 = phi <4 x double> [ %.lcssa21.ph, %middle.block.unr-lcssa ], [ %36, %vector.body.epil ]
  %.lcssa20 = phi <4 x double> [ %.lcssa20.ph, %middle.block.unr-lcssa ], [ %37, %vector.body.epil ]
  %.lcssa19 = phi <4 x double> [ %.lcssa19.ph, %middle.block.unr-lcssa ], [ %38, %vector.body.epil ]
  %.lcssa = phi <4 x double> [ %.lcssa.ph, %middle.block.unr-lcssa ], [ %39, %vector.body.epil ]
  %bin.rdx = fadd fast <4 x double> %.lcssa20, %.lcssa21
  %bin.rdx16 = fadd fast <4 x double> %.lcssa19, %bin.rdx
  %bin.rdx17 = fadd fast <4 x double> %.lcssa, %bin.rdx16
  %40 = call fast double @llvm.vector.reduce.fadd.v4f64(double -0.000000e+00, <4 x double> %bin.rdx17)
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader18

for.body.preheader18:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %res.07.ph = phi double [ 0.000000e+00, %for.body.preheader ], [ %40, %middle.block ]
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  %res.0.lcssa = phi double [ 0.000000e+00, %entry ], [ %40, %middle.block ], [ %add, %for.body ]
  ret double %res.0.lcssa

for.body:                                         ; preds = %for.body, %for.body.preheader18
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ %indvars.iv.ph, %for.body.preheader18 ]
  %res.07 = phi double [ %add, %for.body ], [ %res.07.ph, %for.body.preheader18 ]
  %arrayidx = getelementptr double, double* %a, i64 %indvars.iv
  %41 = load double, double* %arrayidx, align 8
  %add = fadd fast double %41, %res.07
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind readonly ssp uwtable willreturn
define i64 @sum_int64_1(i64* nocapture noundef readonly %a, i64* nocapture noundef readonly %b) local_unnamed_addr #1 {
entry:
  %0 = load i64, i64* %a, align 8
  %1 = load i64, i64* %b, align 8
  %arrayidx2 = getelementptr i64, i64* %a, i64 1
  %2 = load i64, i64* %arrayidx2, align 8
  %arrayidx3 = getelementptr i64, i64* %b, i64 1
  %3 = load i64, i64* %arrayidx3, align 8
  %arrayidx5 = getelementptr i64, i64* %a, i64 2
  %4 = load i64, i64* %arrayidx5, align 8
  %arrayidx6 = getelementptr i64, i64* %b, i64 2
  %5 = load i64, i64* %arrayidx6, align 8
  %arrayidx8 = getelementptr i64, i64* %a, i64 3
  %6 = load i64, i64* %arrayidx8, align 8
  %arrayidx9 = getelementptr i64, i64* %b, i64 3
  %7 = load i64, i64* %arrayidx9, align 8
  %arrayidx11 = getelementptr i64, i64* %a, i64 4
  %8 = load i64, i64* %arrayidx11, align 8
  %arrayidx12 = getelementptr i64, i64* %b, i64 4
  %9 = load i64, i64* %arrayidx12, align 8
  %arrayidx14 = getelementptr i64, i64* %a, i64 5
  %10 = load i64, i64* %arrayidx14, align 8
  %arrayidx15 = getelementptr i64, i64* %b, i64 5
  %11 = load i64, i64* %arrayidx15, align 8
  %arrayidx17 = getelementptr i64, i64* %a, i64 6
  %12 = load i64, i64* %arrayidx17, align 8
  %arrayidx18 = getelementptr i64, i64* %b, i64 6
  %13 = load i64, i64* %arrayidx18, align 8
  %arrayidx20 = getelementptr i64, i64* %a, i64 7
  %14 = load i64, i64* %arrayidx20, align 8
  %arrayidx21 = getelementptr i64, i64* %b, i64 7
  %15 = load i64, i64* %arrayidx21, align 8
  %add22 = add i64 %1, %0
  %add19 = add i64 %add22, %2
  %add16 = add i64 %add19, %3
  %add13 = add i64 %add16, %4
  %add10 = add i64 %add13, %5
  %add7 = add i64 %add10, %6
  %add4 = add i64 %add7, %7
  %add = add i64 %add4, %8
  %add23 = add i64 %add, %9
  %add24 = add i64 %add23, %10
  %add25 = add i64 %add24, %11
  %add26 = add i64 %add25, %12
  %add27 = add i64 %add26, %13
  %add28 = add i64 %add27, %14
  %add29 = add i64 %add28, %15
  ret i64 %add29
}

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i64 @llvm.vector.reduce.add.v4i64(<4 x i64>) #2

; Function Attrs: nofree nosync nounwind readnone willreturn
declare double @llvm.vector.reduce.fadd.v4f64(double, <4 x double>) #2

attributes #0 = { nofree norecurse nosync nounwind readonly ssp uwtable "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+avx,+avx2,+crc32,+cx16,+cx8,+fxsr,+mmx,+popcnt,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" "unsafe-fp-math"="true" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind readonly ssp uwtable willreturn "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+avx,+avx2,+crc32,+cx16,+cx8,+fxsr,+mmx,+popcnt,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" "unsafe-fp-math"="true" }
attributes #2 = { nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"clang version 14.0.1"}
!5 = distinct !{!5, !6, !7}
!6 = !{!"llvm.loop.mustprogress"}
!7 = !{!"llvm.loop.isvectorized", i32 1}
!8 = distinct !{!8, !6, !9, !7}
!9 = !{!"llvm.loop.unroll.runtime.disable"}
!10 = distinct !{!10, !6, !7}
!11 = distinct !{!11, !6, !9, !7}
