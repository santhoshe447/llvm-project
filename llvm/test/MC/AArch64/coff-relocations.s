// RUN: llvm-mc -triple aarch64-windows -filetype obj -o %t.obj %s
// RUN: llvm-mc -triple arm64ec-windows -filetype obj -o %t-ec.obj %s
// RUN: llvm-readobj -r %t.obj | FileCheck %s --check-prefixes=CHECK,CHECK-ARM64
// RUN: llvm-readobj -r %t-ec.obj | FileCheck %s --check-prefixes=CHECK,CHECK-ARM64EC
// RUN: llvm-objdump --no-print-imm-hex -d %t.obj | FileCheck %s --check-prefix=DISASM
// RUN: llvm-objdump --no-print-imm-hex -d %t-ec.obj | FileCheck %s --check-prefix=DISASM
// RUN: llvm-objdump -s %t.obj | FileCheck %s --check-prefix=DATA
// RUN: llvm-objdump -s %t-ec.obj | FileCheck %s --check-prefix=DATA

# RUN: not llvm-mc -triple=aarch64-windows -filetype=obj %s --defsym ERR=1 -o /dev/null 2>&1 | FileCheck %s --check-prefix=ERR --implicit-check-not=error:

// IMAGE_REL_ARM64_ADDR32
.Linfo_foo:
  .asciz "foo"
  .long foo

// IMAGE_REL_ARM64_ADDR32NB
.long func@IMGREL

// IMAGE_REL_ARM64_ADDR64
.globl struc
struc:
  .quad arr

// IMAGE_REL_ARM64_BRANCH26
b target

// IMAGE_REL_ARM64_PAGEBASE_REL21
adrp x0, foo

// IMAGE_REL_ARM64_PAGEOFFSET_12A
add x0, x0, :lo12:foo

// IMAGE_REL_ARM64_PAGEOFFSET_12L
ldr x0, [x0, :lo12:foo]

// IMAGE_REL_ARM64_PAGEBASE_REL21, even if the symbol offset is known
adrp x0, bar
bar:

// IMAGE_REL_ARM64_SECREL
.secrel32 .Linfo_bar
.Linfo_bar:

// IMAGE_REL_ARM64_SECTION
.secidx func

.align 2
adrp x0, baz + 0x12345
baz:
add x0, x0, :lo12:foo + 0x12345
ldrb w0, [x0, :lo12:foo + 0x12345]
ldr x0, [x0, :lo12:foo + 0x12348]

// IMAGE_REL_ARM64_SECREL_LOW12A
add x0, x0, :secrel_lo12:foo
// IMAGE_REL_ARM64_SECREL_HIGH12A
add x0, x0, :secrel_hi12:foo
// IMAGE_REL_ARM64_SECREL_LOW12L
ldr x0, [x0, :secrel_lo12:foo]

// IMAGE_REL_ARM64_REL21
adr x0, foo + 0x12345

// IMAGE_REL_ARM64_BRANCH19
bne target

// IMAGE_REL_ARM64_BRANCH14
tbz x0, #0, target

.section .rdata, "dr"
.Ltable:
.word .Linfo_bar - .Ltable
.word .Linfo_foo - .Ltable

// As an extension, we allow 64-bit label differences. They lower to
// IMAGE_REL_ARM64_REL32 because IMAGE_REL_ARM64_REL64 does not exist.
.xword .Linfo_foo - .Ltable

// CHECK-ARM64: Format: COFF-ARM64
// CHECK-ARM64EC: Format: COFF-ARM64EC
// CHECK-ARM64: Arch: aarch64
// CHECK-ARM64EC: Arch: aarch64
// CHECK: AddressSize: 64bit
// CHECK: Relocations [
// CHECK:   Section (1) .text {
// CHECK: 0x4 IMAGE_REL_ARM64_ADDR32 foo
// CHECK: 0x8 IMAGE_REL_ARM64_ADDR32NB func
// CHECK: 0xC IMAGE_REL_ARM64_ADDR64 arr
// CHECK: 0x14 IMAGE_REL_ARM64_BRANCH26 target
// CHECK: 0x18 IMAGE_REL_ARM64_PAGEBASE_REL21 foo
// CHECK: 0x1C IMAGE_REL_ARM64_PAGEOFFSET_12A foo
// CHECK: 0x20 IMAGE_REL_ARM64_PAGEOFFSET_12L foo
// CHECK: 0x24 IMAGE_REL_ARM64_PAGEBASE_REL21 bar
// CHECK: 0x28 IMAGE_REL_ARM64_SECREL .text
// CHECK: 0x2C IMAGE_REL_ARM64_SECTION func
// CHECK: 0x30 IMAGE_REL_ARM64_PAGEBASE_REL21 baz
// CHECK: 0x34 IMAGE_REL_ARM64_PAGEOFFSET_12A foo
// CHECK: 0x38 IMAGE_REL_ARM64_PAGEOFFSET_12L foo
// CHECK: 0x3C IMAGE_REL_ARM64_PAGEOFFSET_12L foo
// CHECK: 0x40 IMAGE_REL_ARM64_SECREL_LOW12A foo
// CHECK: 0x44 IMAGE_REL_ARM64_SECREL_HIGH12A foo
// CHECK: 0x48 IMAGE_REL_ARM64_SECREL_LOW12L foo
// CHECK: 0x4C IMAGE_REL_ARM64_REL21 foo
// CHECK: 0x50 IMAGE_REL_ARM64_BRANCH19 target
// CHECK: 0x54 IMAGE_REL_ARM64_BRANCH14 target
// CHECK:   }
// CHECK:   Section (4) .rdata {
// CHECK: 0x0 IMAGE_REL_ARM64_REL32 .text
// CHECK: 0x4 IMAGE_REL_ARM64_REL32 .text
// CHECK: 0x8 IMAGE_REL_ARM64_REL32 .text
// CHECK:   }
// CHECK: ]

// DISASM: 30:       b0091a20     adrp    x0, 0x12345000
// DISASM: 34:       910d1400     add     x0, x0, #837
// DISASM: 38:       394d1400     ldrb    w0, [x0, #837]
// DISASM: 3c:       f941a400     ldr     x0, [x0, #840]
// DISASM: 40:       91000000     add     x0, x0, #0
// DISASM: 44:       91400000     add     x0, x0, #0, lsl #12
// DISASM: 48:       f9400000     ldr     x0, [x0]
// DISASM: 4c:       30091a20     adr     x0, 0x12391

// DATA: Contents of section .rdata:
// DATA-NEXT:  0000 30000000 08000000

.ifdef ERR
# ERR: [[#@LINE+1]]:12: error: invalid variant 'plt'
.long func@plt
.endif
