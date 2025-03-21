; Test the MSA intrinsics that are encoded with the 3R instruction format.
; There are lots of these so this covers those beginning with 'p'

; RUN: llc -mtriple=mips-elf -mattr=+msa,+fp64,+mips32r2 < %s | FileCheck %s
; RUN: llc -mtriple=mipsel-elf -mattr=+msa,+fp64,+mips32r2 < %s | FileCheck %s

@llvm_mips_pckev_b_ARG1 = global <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>, align 16
@llvm_mips_pckev_b_ARG2 = global <16 x i8> <i8 16, i8 17, i8 18, i8 19, i8 20, i8 21, i8 22, i8 23, i8 24, i8 25, i8 26, i8 27, i8 28, i8 29, i8 30, i8 31>, align 16
@llvm_mips_pckev_b_RES  = global <16 x i8> <i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0>, align 16

define void @llvm_mips_pckev_b_test() nounwind {
entry:
  %0 = load <16 x i8>, ptr @llvm_mips_pckev_b_ARG1
  %1 = load <16 x i8>, ptr @llvm_mips_pckev_b_ARG2
  %2 = tail call <16 x i8> @llvm.mips.pckev.b(<16 x i8> %0, <16 x i8> %1)
  store <16 x i8> %2, ptr @llvm_mips_pckev_b_RES
  ret void
}

declare <16 x i8> @llvm.mips.pckev.b(<16 x i8>, <16 x i8>) nounwind

; CHECK: llvm_mips_pckev_b_test:
; CHECK: ld.b
; CHECK: ld.b
; CHECK: pckev.b
; CHECK: st.b
; CHECK: .size llvm_mips_pckev_b_test
;
@llvm_mips_pckev_h_ARG1 = global <8 x i16> <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7>, align 16
@llvm_mips_pckev_h_ARG2 = global <8 x i16> <i16 8, i16 9, i16 10, i16 11, i16 12, i16 13, i16 14, i16 15>, align 16
@llvm_mips_pckev_h_RES  = global <8 x i16> <i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0>, align 16

define void @llvm_mips_pckev_h_test() nounwind {
entry:
  %0 = load <8 x i16>, ptr @llvm_mips_pckev_h_ARG1
  %1 = load <8 x i16>, ptr @llvm_mips_pckev_h_ARG2
  %2 = tail call <8 x i16> @llvm.mips.pckev.h(<8 x i16> %0, <8 x i16> %1)
  store <8 x i16> %2, ptr @llvm_mips_pckev_h_RES
  ret void
}

declare <8 x i16> @llvm.mips.pckev.h(<8 x i16>, <8 x i16>) nounwind

; CHECK: llvm_mips_pckev_h_test:
; CHECK: ld.h
; CHECK: ld.h
; CHECK: pckev.h
; CHECK: st.h
; CHECK: .size llvm_mips_pckev_h_test
;
@llvm_mips_pckev_w_ARG1 = global <4 x i32> <i32 0, i32 1, i32 2, i32 3>, align 16
@llvm_mips_pckev_w_ARG2 = global <4 x i32> <i32 4, i32 5, i32 6, i32 7>, align 16
@llvm_mips_pckev_w_RES  = global <4 x i32> <i32 0, i32 0, i32 0, i32 0>, align 16

define void @llvm_mips_pckev_w_test() nounwind {
entry:
  %0 = load <4 x i32>, ptr @llvm_mips_pckev_w_ARG1
  %1 = load <4 x i32>, ptr @llvm_mips_pckev_w_ARG2
  %2 = tail call <4 x i32> @llvm.mips.pckev.w(<4 x i32> %0, <4 x i32> %1)
  store <4 x i32> %2, ptr @llvm_mips_pckev_w_RES
  ret void
}

declare <4 x i32> @llvm.mips.pckev.w(<4 x i32>, <4 x i32>) nounwind

; CHECK: llvm_mips_pckev_w_test:
; CHECK: ld.w
; CHECK: ld.w
; CHECK: pckev.w
; CHECK: st.w
; CHECK: .size llvm_mips_pckev_w_test
;
@llvm_mips_pckev_d_ARG1 = global <2 x i64> <i64 0, i64 1>, align 16
@llvm_mips_pckev_d_ARG2 = global <2 x i64> <i64 2, i64 3>, align 16
@llvm_mips_pckev_d_RES  = global <2 x i64> <i64 0, i64 0>, align 16

define void @llvm_mips_pckev_d_test() nounwind {
entry:
  %0 = load <2 x i64>, ptr @llvm_mips_pckev_d_ARG1
  %1 = load <2 x i64>, ptr @llvm_mips_pckev_d_ARG2
  %2 = tail call <2 x i64> @llvm.mips.pckev.d(<2 x i64> %0, <2 x i64> %1)
  store <2 x i64> %2, ptr @llvm_mips_pckev_d_RES
  ret void
}

declare <2 x i64> @llvm.mips.pckev.d(<2 x i64>, <2 x i64>) nounwind

; CHECK: llvm_mips_pckev_d_test:
; CHECK: ld.d
; CHECK: ld.d
; CHECK: pckev.d
; CHECK: st.d
; CHECK: .size llvm_mips_pckev_d_test
;
@llvm_mips_pckod_b_ARG1 = global <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>, align 16
@llvm_mips_pckod_b_ARG2 = global <16 x i8> <i8 16, i8 17, i8 18, i8 19, i8 20, i8 21, i8 22, i8 23, i8 24, i8 25, i8 26, i8 27, i8 28, i8 29, i8 30, i8 31>, align 16
@llvm_mips_pckod_b_RES  = global <16 x i8> <i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0>, align 16

define void @llvm_mips_pckod_b_test() nounwind {
entry:
  %0 = load <16 x i8>, ptr @llvm_mips_pckod_b_ARG1
  %1 = load <16 x i8>, ptr @llvm_mips_pckod_b_ARG2
  %2 = tail call <16 x i8> @llvm.mips.pckod.b(<16 x i8> %0, <16 x i8> %1)
  store <16 x i8> %2, ptr @llvm_mips_pckod_b_RES
  ret void
}

declare <16 x i8> @llvm.mips.pckod.b(<16 x i8>, <16 x i8>) nounwind

; CHECK: llvm_mips_pckod_b_test:
; CHECK: ld.b
; CHECK: ld.b
; CHECK: pckod.b
; CHECK: st.b
; CHECK: .size llvm_mips_pckod_b_test
;
@llvm_mips_pckod_h_ARG1 = global <8 x i16> <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7>, align 16
@llvm_mips_pckod_h_ARG2 = global <8 x i16> <i16 8, i16 9, i16 10, i16 11, i16 12, i16 13, i16 14, i16 15>, align 16
@llvm_mips_pckod_h_RES  = global <8 x i16> <i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0>, align 16

define void @llvm_mips_pckod_h_test() nounwind {
entry:
  %0 = load <8 x i16>, ptr @llvm_mips_pckod_h_ARG1
  %1 = load <8 x i16>, ptr @llvm_mips_pckod_h_ARG2
  %2 = tail call <8 x i16> @llvm.mips.pckod.h(<8 x i16> %0, <8 x i16> %1)
  store <8 x i16> %2, ptr @llvm_mips_pckod_h_RES
  ret void
}

declare <8 x i16> @llvm.mips.pckod.h(<8 x i16>, <8 x i16>) nounwind

; CHECK: llvm_mips_pckod_h_test:
; CHECK: ld.h
; CHECK: ld.h
; CHECK: pckod.h
; CHECK: st.h
; CHECK: .size llvm_mips_pckod_h_test
;
@llvm_mips_pckod_w_ARG1 = global <4 x i32> <i32 0, i32 1, i32 2, i32 3>, align 16
@llvm_mips_pckod_w_ARG2 = global <4 x i32> <i32 4, i32 5, i32 6, i32 7>, align 16
@llvm_mips_pckod_w_RES  = global <4 x i32> <i32 0, i32 0, i32 0, i32 0>, align 16

define void @llvm_mips_pckod_w_test() nounwind {
entry:
  %0 = load <4 x i32>, ptr @llvm_mips_pckod_w_ARG1
  %1 = load <4 x i32>, ptr @llvm_mips_pckod_w_ARG2
  %2 = tail call <4 x i32> @llvm.mips.pckod.w(<4 x i32> %0, <4 x i32> %1)
  store <4 x i32> %2, ptr @llvm_mips_pckod_w_RES
  ret void
}

declare <4 x i32> @llvm.mips.pckod.w(<4 x i32>, <4 x i32>) nounwind

; CHECK: llvm_mips_pckod_w_test:
; CHECK: ld.w
; CHECK: ld.w
; CHECK: pckod.w
; CHECK: st.w
; CHECK: .size llvm_mips_pckod_w_test
;
@llvm_mips_pckod_d_ARG1 = global <2 x i64> <i64 0, i64 1>, align 16
@llvm_mips_pckod_d_ARG2 = global <2 x i64> <i64 2, i64 3>, align 16
@llvm_mips_pckod_d_RES  = global <2 x i64> <i64 0, i64 0>, align 16

define void @llvm_mips_pckod_d_test() nounwind {
entry:
  %0 = load <2 x i64>, ptr @llvm_mips_pckod_d_ARG1
  %1 = load <2 x i64>, ptr @llvm_mips_pckod_d_ARG2
  %2 = tail call <2 x i64> @llvm.mips.pckod.d(<2 x i64> %0, <2 x i64> %1)
  store <2 x i64> %2, ptr @llvm_mips_pckod_d_RES
  ret void
}

declare <2 x i64> @llvm.mips.pckod.d(<2 x i64>, <2 x i64>) nounwind

; CHECK: llvm_mips_pckod_d_test:
; CHECK: ld.d
; CHECK: ld.d
; CHECK: pckod.d
; CHECK: st.d
; CHECK: .size llvm_mips_pckod_d_test
;
