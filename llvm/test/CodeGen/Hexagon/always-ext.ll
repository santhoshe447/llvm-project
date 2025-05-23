; RUN: llc -mtriple=hexagon < %s | FileCheck %s

; Check that we don't generate an invalid packet with too many instructions
; due to a store that has a must-extend operand.

; CHECK: CuSuiteAdd.exit.us
; CHECK: {
; CHECK-NOT: call abort
; CHECK: memw(##0)
; CHECK: memw(r{{[0-9+]}}<<#2+##4)
; CHECK: }

%struct.CuTest.1.28.31.37.40.43.52.55.67.85.111 = type { ptr, ptr, i32, i32, ptr, ptr }
%struct.CuSuite.2.29.32.38.41.44.53.56.68.86.112 = type { i32, [1024 x ptr], i32 }

@__func__.CuSuiteAdd = external unnamed_addr constant [11 x i8], align 8
@.str24 = external unnamed_addr constant [140 x i8], align 8

declare void @_Assert()

define void @CuSuiteAddSuite() nounwind null_pointer_is_valid {
entry:
  br i1 undef, label %for.body.us, label %for.end

for.body.us:                                      ; preds = %entry
  %0 = load ptr, ptr null, align 4
  %1 = load i32, ptr undef, align 4
  %cmp.i.us = icmp slt i32 %1, 1024
  br i1 %cmp.i.us, label %CuSuiteAdd.exit.us, label %cond.false6.i.us

cond.false6.i.us:                                 ; preds = %for.body.us
  tail call void @_Assert() nounwind
  unreachable

CuSuiteAdd.exit.us:                               ; preds = %for.body.us
  %arrayidx.i.us = getelementptr inbounds %struct.CuSuite.2.29.32.38.41.44.53.56.68.86.112, ptr null, i32 0, i32 1, i32 %1
  store ptr %0, ptr %arrayidx.i.us, align 4
  call void @llvm.trap()
  unreachable

for.end:                                          ; preds = %entry
  ret void
}

declare void @llvm.trap() noreturn nounwind
