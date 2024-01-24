/* Apache NuttX RTOS: Start Code for 64-bit RISC-V Kernel Mode (rv-virt:knsh64) */

Disassembly of section .text:

0000000080000000 <__kflash_start>:
__kflash_start():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:47
__start:

  /* Preserve a1 as it contains the pointer to DTB */
  /* Load mhartid (cpuid) */

  csrr a0, mhartid
    80000000:	f1402573          	csrr	a0,mhartid
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:51

  /* Set stack pointer to the idle thread stack */

  bnez a0, 1f
    80000004:	e511                	bnez	a0,80000010 <__kflash_start+0x10>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:52
  la   sp, QEMU_RV_IDLESTACK_TOP
    80000006:	00207117          	auipc	sp,0x207
    8000000a:	bfa10113          	addi	sp,sp,-1030 # 80206c00 <_ebss+0xc00>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:53
  j    2f
    8000000e:	a02d                	j	80000038 <__kflash_start+0x38>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:61
  /* Load the number of CPUs that the kernel supports */

#ifdef CONFIG_SMP
  li   t1, CONFIG_SMP_NCPUS
#else
  li   t1, 1
    80000010:	4305                	li	t1,1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:66
#endif

  /* If a0 (mhartid) >= t1 (the number of CPUs), stop here */

  blt  a0, t1, 3f
    80000012:	00654663          	blt	a0,t1,8000001e <__kflash_start+0x1e>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:67
  csrw mie, zero
    80000016:	30401073          	csrw	mie,zero
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:68
  wfi
    8000001a:	10500073          	wfi
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:73

3:
  /* To get g_cpu_basestack[mhartid], must get g_cpu_basestack first */

  la   t0, g_cpu_basestack
    8000001e:	0002c297          	auipc	t0,0x2c
    80000022:	52a28293          	addi	t0,t0,1322 # 8002c548 <g_cpu_basestack>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:80
  /* Offset = pointer width * hart id */

#ifdef CONFIG_ARCH_RV32
  slli t1, a0, 2
#else
  slli t1, a0, 3
    80000026:	00351313          	slli	t1,a0,0x3
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:82
#endif
  add  t0, t0, t1
    8000002a:	929a                	add	t0,t0,t1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:86

  /* Load idle stack base to sp */

  REGLOAD sp, 0(t0)
    8000002c:	0002b103          	ld	sp,0(t0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:95
   *
   * Note: Reserve some space used by up_initial_state since we are already
   * running and using the per CPU idle stack.
   */

  li   t0, STACK_ALIGN_UP(CONFIG_IDLETHREAD_STACKSIZE - XCPTCONTEXT_SIZE)
    80000030:	6285                	lui	t0,0x1
    80000032:	9f02829b          	addiw	t0,t0,-1552
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:96
  add  sp, sp, t0
    80000036:	9116                	add	sp,sp,t0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:102

2:

  /* Disable all interrupts (i.e. timer, external) in mie */

	csrw	mie, zero
    80000038:	30401073          	csrw	mie,zero
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:104

  la   t0, __trap_vec
    8000003c:	00000297          	auipc	t0,0x0
    80000040:	01428293          	addi	t0,t0,20 # 80000050 <__trap_vec>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:105
  csrw mtvec, t0
    80000044:	30529073          	csrw	mtvec,t0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:109

  /* Jump to qemu_rv_start */

  jal  x1, qemu_rv_start
    80000048:	085000ef          	jal	ra,800008cc <qemu_rv_start>

000000008000004c <_fini>:
_init():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_head.S:121
_init:
_fini:

  /* These don't have to do anything since we use init_array/fini_array. */

  ret
    8000004c:	8082                	ret
	...

0000000080000050 <__trap_vec>:
__trap_vec():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_vectors.S:39
 *   kernel is in S-mode delegated exceptions and interrupts are handled.
 *
 ****************************************************************************/

__trap_vec:
  j    exception_common
    80000050:	0b00006f          	j	80000100 <exception_common>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_vectors.S:40
  nop
    80000054:	0001                	nop
	...

0000000080000100 <exception_common>:
exception_common():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:82
exception_common:

#ifdef CONFIG_ARCH_KERNEL_STACK
  /* Take the kernel stack into use */

  csrrw      a0, CSR_SCRATCH, a0
    80000100:	14051573          	csrrw	a0,sscratch,a0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:83
  REGSTORE   sp, RISCV_PERCPU_USP(a0)
    80000104:	00253c23          	sd	sp,24(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:84
  REGLOAD    sp, RISCV_PERCPU_KSP(a0)
    80000108:	02053103          	ld	sp,32(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:85
  REGSTORE   x0, RISCV_PERCPU_KSP(a0)
    8000010c:	02053023          	sd	zero,32(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:86
  bnez       sp, 1f
    80000110:	00011463          	bnez	sp,80000118 <exception_common+0x18>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:90

  /* No kernel stack, exception comes from kernel */

  REGLOAD    sp, RISCV_PERCPU_USP(a0)
    80000114:	01853103          	ld	sp,24(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:95

1:
  /* Restore the per-cpu structure */

  csrrw      a0, CSR_SCRATCH, a0
    80000118:	14051573          	csrrw	a0,sscratch,a0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:98
#endif

  addi       sp, sp, -XCPTCONTEXT_SIZE
    8000011c:	df010113          	addi	sp,sp,-528
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:99
  save_ctx   sp
    80000120:	e406                	sd	ra,8(sp)
    80000122:	f012                	sd	tp,32(sp)
    80000124:	f416                	sd	t0,40(sp)
    80000126:	f81a                	sd	t1,48(sp)
    80000128:	fc1e                	sd	t2,56(sp)
    8000012a:	e0a2                	sd	s0,64(sp)
    8000012c:	e4a6                	sd	s1,72(sp)
    8000012e:	e8aa                	sd	a0,80(sp)
    80000130:	ecae                	sd	a1,88(sp)
    80000132:	f0b2                	sd	a2,96(sp)
    80000134:	f4b6                	sd	a3,104(sp)
    80000136:	f8ba                	sd	a4,112(sp)
    80000138:	fcbe                	sd	a5,120(sp)
    8000013a:	e142                	sd	a6,128(sp)
    8000013c:	e546                	sd	a7,136(sp)
    8000013e:	e94a                	sd	s2,144(sp)
    80000140:	ed4e                	sd	s3,152(sp)
    80000142:	f152                	sd	s4,160(sp)
    80000144:	f556                	sd	s5,168(sp)
    80000146:	f95a                	sd	s6,176(sp)
    80000148:	fd5e                	sd	s7,184(sp)
    8000014a:	e1e2                	sd	s8,192(sp)
    8000014c:	e5e6                	sd	s9,200(sp)
    8000014e:	e9ea                	sd	s10,208(sp)
    80000150:	edee                	sd	s11,216(sp)
    80000152:	f1f2                	sd	t3,224(sp)
    80000154:	f5f6                	sd	t4,232(sp)
    80000156:	f9fa                	sd	t5,240(sp)
    80000158:	fdfe                	sd	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:101

  csrr       s0, CSR_STATUS
    8000015a:	10002473          	csrr	s0,sstatus
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:102
  REGSTORE   s0, REG_INT_CTX(sp)  /* status */
    8000015e:	e222                	sd	s0,256(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:105

#ifdef CONFIG_ARCH_KERNEL_STACK
  csrr       s0, CSR_SCRATCH
    80000160:	14002473          	csrr	s0,sscratch
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:106
  REGLOAD    s0, RISCV_PERCPU_USP(s0)
    80000164:	6c00                	ld	s0,24(s0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:111
#else
  addi       s0, sp, XCPTCONTEXT_SIZE
#endif

  REGSTORE   s0, REG_X2(sp)       /* original SP */
    80000166:	e822                	sd	s0,16(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:113

  csrr       s0, CSR_EPC
    80000168:	14102473          	csrr	s0,sepc
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:114
  REGSTORE   s0, REG_EPC(sp)      /* exception PC */
    8000016c:	e022                	sd	s0,0(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:118

  /* Setup arg0(exception cause), arg1(context) */

  csrr       a0, CSR_CAUSE        /* exception cause */
    8000016e:	14202573          	csrr	a0,scause
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:119
  mv         a1, sp               /* context = sp */
    80000172:	858a                	mv	a1,sp
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:125

#if CONFIG_ARCH_INTERRUPTSTACK > 15

  /* Switch to interrupt stack */

  setintstack t0, t1
    80000174:	140022f3          	csrr	t0,sscratch
    80000178:	0102b103          	ld	sp,16(t0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:129

  /* Call interrupt handler in C */

  jal        x1, riscv_dispatch_irq
    8000017c:	047000ef          	jal	ra,800009c2 <riscv_dispatch_irq>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:147
  addi       sp, sp, XCPTCONTEXT_SIZE
#endif

  /* If context switch is needed, return a new sp */

  mv         sp, a0
    80000180:	812a                	mv	sp,a0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:149

  REGLOAD    s0, REG_EPC(sp)      /* restore sepc */
    80000182:	6402                	ld	s0,0(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:150
  csrw       CSR_EPC, s0
    80000184:	14141073          	csrw	sepc,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:152

  REGLOAD    s0, REG_INT_CTX(sp)  /* restore sstatus */
    80000188:	6412                	ld	s0,256(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:153
  csrw       CSR_STATUS, s0
    8000018a:	10041073          	csrw	sstatus,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:158

#ifdef CONFIG_ARCH_KERNEL_STACK
  /* Returning to userspace ? */

  li         s1, STATUS_PPP
    8000018e:	10000493          	li	s1,256
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:159
  and        s0, s0, s1
    80000192:	8c65                	and	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:160
  bnez       s0, 1f
    80000194:	e411                	bnez	s0,800001a0 <exception_common+0xa0>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:164

  /* Set the next task's kernel stack to the scratch area */

  jal        x1, riscv_current_ksp
    80000196:	521000ef          	jal	ra,80000eb6 <riscv_current_ksp>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:165
  csrr       s0, CSR_SCRATCH
    8000019a:	14002473          	csrr	s0,sscratch
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:166
  REGSTORE   a0, RISCV_PERCPU_KSP(s0)
    8000019e:	f008                	sd	a0,32(s0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:171

1:
#endif

  load_ctx   sp
    800001a0:	60a2                	ld	ra,8(sp)
    800001a2:	7202                	ld	tp,32(sp)
    800001a4:	72a2                	ld	t0,40(sp)
    800001a6:	7342                	ld	t1,48(sp)
    800001a8:	73e2                	ld	t2,56(sp)
    800001aa:	6406                	ld	s0,64(sp)
    800001ac:	64a6                	ld	s1,72(sp)
    800001ae:	6546                	ld	a0,80(sp)
    800001b0:	65e6                	ld	a1,88(sp)
    800001b2:	7606                	ld	a2,96(sp)
    800001b4:	76a6                	ld	a3,104(sp)
    800001b6:	7746                	ld	a4,112(sp)
    800001b8:	77e6                	ld	a5,120(sp)
    800001ba:	680a                	ld	a6,128(sp)
    800001bc:	68aa                	ld	a7,136(sp)
    800001be:	694a                	ld	s2,144(sp)
    800001c0:	69ea                	ld	s3,152(sp)
    800001c2:	7a0a                	ld	s4,160(sp)
    800001c4:	7aaa                	ld	s5,168(sp)
    800001c6:	7b4a                	ld	s6,176(sp)
    800001c8:	7bea                	ld	s7,184(sp)
    800001ca:	6c0e                	ld	s8,192(sp)
    800001cc:	6cae                	ld	s9,200(sp)
    800001ce:	6d4e                	ld	s10,208(sp)
    800001d0:	6dee                	ld	s11,216(sp)
    800001d2:	7e0e                	ld	t3,224(sp)
    800001d4:	7eae                	ld	t4,232(sp)
    800001d6:	7f4e                	ld	t5,240(sp)
    800001d8:	7fee                	ld	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:173

  REGLOAD    sp, REG_SP(sp)      /* restore original sp */
    800001da:	6142                	ld	sp,16(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_exception_common.S:177

  /* Return from exception */

  ERET
    800001dc:	10200073          	sret
	...

0000000080000202 <riscv_fpuconfig>:
riscv_fpuconfig():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:69
 ****************************************************************************/

    .type        riscv_fpuconfig, function

riscv_fpuconfig:
  li           a0, MSTATUS_FS_INIT
    80000202:	6509                	lui	a0,0x2
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:70
  csrs         CSR_STATUS, a0
    80000204:	10052073          	csrs	sstatus,a0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:72

  fscsr        zero
    80000208:	00301073          	fscsr	zero
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:74

  fence.i
    8000020c:	0000100f          	fence.i
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:75
  ret
    80000210:	8082                	ret

0000000080000212 <riscv_savefpu>:
riscv_savefpu():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:101

    .type         riscv_savefpu, function

riscv_savefpu:

  REGLOAD    t0, REG_INT_CTX(a0)
    80000212:	10053283          	ld	t0,256(a0) # 2100 <__kflash_size-0x1fdf00>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:102
  li         t1, MSTATUS_FS
    80000216:	6319                	lui	t1,0x6
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:103
  and        t2, t0, t1
    80000218:	0062f3b3          	and	t2,t0,t1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:104
  li         t1, MSTATUS_FS_DIRTY
    8000021c:	6319                	lui	t1,0x6
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:108
#ifdef CONFIG_ARCH_LAZYFPU
  bne        t2, t1, 1f
#else
  blt        t2, t1, 1f
    8000021e:	0863c763          	blt	t2,t1,800002ac <riscv_savefpu+0x9a>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:110
#endif
  li         t1, ~MSTATUS_FS
    80000222:	7369                	lui	t1,0xffffa
    80000224:	337d                	addiw	t1,t1,-1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:111
  and        t0, t0, t1
    80000226:	0062f2b3          	and	t0,t0,t1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:112
  li         t1, MSTATUS_FS_CLEAN
    8000022a:	6311                	lui	t1,0x4
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:113
  or         t0, t0, t1
    8000022c:	0062e2b3          	or	t0,t0,t1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:114
  REGSTORE   t0, REG_INT_CTX(a0)
    80000230:	10553023          	sd	t0,256(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:116

  riscv_savefpu a1
    80000234:	0005b027          	fsd	ft0,0(a1)
    80000238:	0015b427          	fsd	ft1,8(a1)
    8000023c:	0025b827          	fsd	ft2,16(a1)
    80000240:	0035bc27          	fsd	ft3,24(a1)
    80000244:	0245b027          	fsd	ft4,32(a1)
    80000248:	0255b427          	fsd	ft5,40(a1)
    8000024c:	0265b827          	fsd	ft6,48(a1)
    80000250:	0275bc27          	fsd	ft7,56(a1)
    80000254:	a1a0                	fsd	fs0,64(a1)
    80000256:	a5a4                	fsd	fs1,72(a1)
    80000258:	a9a8                	fsd	fa0,80(a1)
    8000025a:	adac                	fsd	fa1,88(a1)
    8000025c:	b1b0                	fsd	fa2,96(a1)
    8000025e:	b5b4                	fsd	fa3,104(a1)
    80000260:	b9b8                	fsd	fa4,112(a1)
    80000262:	bdbc                	fsd	fa5,120(a1)
    80000264:	0905b027          	fsd	fa6,128(a1)
    80000268:	0915b427          	fsd	fa7,136(a1)
    8000026c:	0925b827          	fsd	fs2,144(a1)
    80000270:	0935bc27          	fsd	fs3,152(a1)
    80000274:	0b45b027          	fsd	fs4,160(a1)
    80000278:	0b55b427          	fsd	fs5,168(a1)
    8000027c:	0b65b827          	fsd	fs6,176(a1)
    80000280:	0b75bc27          	fsd	fs7,184(a1)
    80000284:	0d85b027          	fsd	fs8,192(a1)
    80000288:	0d95b427          	fsd	fs9,200(a1)
    8000028c:	0da5b827          	fsd	fs10,208(a1)
    80000290:	0db5bc27          	fsd	fs11,216(a1)
    80000294:	0fc5b027          	fsd	ft8,224(a1)
    80000298:	0fd5b427          	fsd	ft9,232(a1)
    8000029c:	0fe5b827          	fsd	ft10,240(a1)
    800002a0:	0ff5bc27          	fsd	ft11,248(a1)
    800002a4:	003022f3          	frcsr	t0
    800002a8:	1055b023          	sd	t0,256(a1)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:119

1:
  ret
    800002ac:	8082                	ret

00000000800002ae <riscv_restorefpu>:
riscv_restorefpu():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:147

    .type        riscv_restorefpu, function

riscv_restorefpu:

  REGLOAD      t0, REG_INT_CTX(a0)
    800002ae:	10053283          	ld	t0,256(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:148
  li           t1, MSTATUS_FS
    800002b2:	6319                	lui	t1,0x6
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:149
  and          t2, t0, t1
    800002b4:	0062f3b3          	and	t2,t0,t1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:150
  li           t1, MSTATUS_FS_INIT
    800002b8:	6309                	lui	t1,0x2
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:151
  ble          t2, t1, 1f
    800002ba:	06735e63          	bge	t1,t2,80000336 <riscv_restorefpu+0x88>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:153

  riscv_loadfpu a1
    800002be:	0005b007          	fld	ft0,0(a1)
    800002c2:	0085b087          	fld	ft1,8(a1)
    800002c6:	0105b107          	fld	ft2,16(a1)
    800002ca:	0185b187          	fld	ft3,24(a1)
    800002ce:	0205b207          	fld	ft4,32(a1)
    800002d2:	0285b287          	fld	ft5,40(a1)
    800002d6:	0305b307          	fld	ft6,48(a1)
    800002da:	0385b387          	fld	ft7,56(a1)
    800002de:	21a0                	fld	fs0,64(a1)
    800002e0:	25a4                	fld	fs1,72(a1)
    800002e2:	29a8                	fld	fa0,80(a1)
    800002e4:	2dac                	fld	fa1,88(a1)
    800002e6:	31b0                	fld	fa2,96(a1)
    800002e8:	35b4                	fld	fa3,104(a1)
    800002ea:	39b8                	fld	fa4,112(a1)
    800002ec:	3dbc                	fld	fa5,120(a1)
    800002ee:	0805b807          	fld	fa6,128(a1)
    800002f2:	0885b887          	fld	fa7,136(a1)
    800002f6:	0905b907          	fld	fs2,144(a1)
    800002fa:	0985b987          	fld	fs3,152(a1)
    800002fe:	0a05ba07          	fld	fs4,160(a1)
    80000302:	0a85ba87          	fld	fs5,168(a1)
    80000306:	0b05bb07          	fld	fs6,176(a1)
    8000030a:	0b85bb87          	fld	fs7,184(a1)
    8000030e:	0c05bc07          	fld	fs8,192(a1)
    80000312:	0c85bc87          	fld	fs9,200(a1)
    80000316:	0d05bd07          	fld	fs10,208(a1)
    8000031a:	0d85bd87          	fld	fs11,216(a1)
    8000031e:	0e05be07          	fld	ft8,224(a1)
    80000322:	0e85be87          	fld	ft9,232(a1)
    80000326:	0f05bf07          	fld	ft10,240(a1)
    8000032a:	0f85bf87          	fld	ft11,248(a1)
    8000032e:	1005b283          	ld	t0,256(a1)
    80000332:	00329073          	fscsr	t0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_fpu.S:156

1:
  ret
    80000336:	8082                	ret
	...

0000000080000400 <__trap_vec_m>:
__trap_vec_m():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:65
 *   kernel is in S-mode delegated exceptions and interrupts are handled.
 *
 ****************************************************************************/

__trap_vec_m:
  j    exception_m
    80000400:	a201                	j	80000500 <exception_m>
    80000402:	0001                	nop
    80000404:	00000013          	nop
    80000408:	00000013          	nop
    8000040c:	00000013          	nop
    80000410:	00000013          	nop
    80000414:	00000013          	nop
    80000418:	00000013          	nop
    8000041c:	00000013          	nop
    80000420:	00000013          	nop
    80000424:	00000013          	nop
    80000428:	00000013          	nop
    8000042c:	00000013          	nop
    80000430:	00000013          	nop
    80000434:	00000013          	nop
    80000438:	00000013          	nop
    8000043c:	00000013          	nop
    80000440:	00000013          	nop
    80000444:	00000013          	nop
    80000448:	00000013          	nop
    8000044c:	00000013          	nop
    80000450:	00000013          	nop
    80000454:	00000013          	nop
    80000458:	00000013          	nop
    8000045c:	00000013          	nop
    80000460:	00000013          	nop
    80000464:	00000013          	nop
    80000468:	00000013          	nop
    8000046c:	00000013          	nop
    80000470:	00000013          	nop
    80000474:	00000013          	nop
    80000478:	00000013          	nop
    8000047c:	00000013          	nop
    80000480:	00000013          	nop
    80000484:	00000013          	nop
    80000488:	00000013          	nop
    8000048c:	00000013          	nop
    80000490:	00000013          	nop
    80000494:	00000013          	nop
    80000498:	00000013          	nop
    8000049c:	00000013          	nop
    800004a0:	00000013          	nop
    800004a4:	00000013          	nop
    800004a8:	00000013          	nop
    800004ac:	00000013          	nop
    800004b0:	00000013          	nop
    800004b4:	00000013          	nop
    800004b8:	00000013          	nop
    800004bc:	00000013          	nop
    800004c0:	00000013          	nop
    800004c4:	00000013          	nop
    800004c8:	00000013          	nop
    800004cc:	00000013          	nop
    800004d0:	00000013          	nop
    800004d4:	00000013          	nop
    800004d8:	00000013          	nop
    800004dc:	00000013          	nop
    800004e0:	00000013          	nop
    800004e4:	00000013          	nop
    800004e8:	00000013          	nop
    800004ec:	00000013          	nop
    800004f0:	00000013          	nop
    800004f4:	00000013          	nop
    800004f8:	00000013          	nop
    800004fc:	00000013          	nop

0000000080000500 <exception_m>:
exception_m():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:84
exception_m:

  /* Swap mscratch with sp */
  /* NOTE: mscratch has been set in up_mtimer_initialize() */

  csrrw     sp, mscratch, sp
    80000500:	34011173          	csrrw	sp,mscratch,sp
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:88

  /* Save the context */

  save_ctx  sp
    80000504:	e406                	sd	ra,8(sp)
    80000506:	f012                	sd	tp,32(sp)
    80000508:	f416                	sd	t0,40(sp)
    8000050a:	f81a                	sd	t1,48(sp)
    8000050c:	fc1e                	sd	t2,56(sp)
    8000050e:	e0a2                	sd	s0,64(sp)
    80000510:	e4a6                	sd	s1,72(sp)
    80000512:	e8aa                	sd	a0,80(sp)
    80000514:	ecae                	sd	a1,88(sp)
    80000516:	f0b2                	sd	a2,96(sp)
    80000518:	f4b6                	sd	a3,104(sp)
    8000051a:	f8ba                	sd	a4,112(sp)
    8000051c:	fcbe                	sd	a5,120(sp)
    8000051e:	e142                	sd	a6,128(sp)
    80000520:	e546                	sd	a7,136(sp)
    80000522:	e94a                	sd	s2,144(sp)
    80000524:	ed4e                	sd	s3,152(sp)
    80000526:	f152                	sd	s4,160(sp)
    80000528:	f556                	sd	s5,168(sp)
    8000052a:	f95a                	sd	s6,176(sp)
    8000052c:	fd5e                	sd	s7,184(sp)
    8000052e:	e1e2                	sd	s8,192(sp)
    80000530:	e5e6                	sd	s9,200(sp)
    80000532:	e9ea                	sd	s10,208(sp)
    80000534:	edee                	sd	s11,216(sp)
    80000536:	f1f2                	sd	t3,224(sp)
    80000538:	f5f6                	sd	t4,232(sp)
    8000053a:	f9fa                	sd	t5,240(sp)
    8000053c:	fdfe                	sd	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:93

  /* Handle the mtimer interrupt */
  /* NOTE: we assume exception/interrupt only happens for mtimer */

  jal       ra, qemu_rv_mtimer_interrupt
    8000053e:	532000ef          	jal	ra,80000a70 <qemu_rv_mtimer_interrupt>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:97

  /* Restore the context */

  load_ctx  sp
    80000542:	60a2                	ld	ra,8(sp)
    80000544:	7202                	ld	tp,32(sp)
    80000546:	72a2                	ld	t0,40(sp)
    80000548:	7342                	ld	t1,48(sp)
    8000054a:	73e2                	ld	t2,56(sp)
    8000054c:	6406                	ld	s0,64(sp)
    8000054e:	64a6                	ld	s1,72(sp)
    80000550:	6546                	ld	a0,80(sp)
    80000552:	65e6                	ld	a1,88(sp)
    80000554:	7606                	ld	a2,96(sp)
    80000556:	76a6                	ld	a3,104(sp)
    80000558:	7746                	ld	a4,112(sp)
    8000055a:	77e6                	ld	a5,120(sp)
    8000055c:	680a                	ld	a6,128(sp)
    8000055e:	68aa                	ld	a7,136(sp)
    80000560:	694a                	ld	s2,144(sp)
    80000562:	69ea                	ld	s3,152(sp)
    80000564:	7a0a                	ld	s4,160(sp)
    80000566:	7aaa                	ld	s5,168(sp)
    80000568:	7b4a                	ld	s6,176(sp)
    8000056a:	7bea                	ld	s7,184(sp)
    8000056c:	6c0e                	ld	s8,192(sp)
    8000056e:	6cae                	ld	s9,200(sp)
    80000570:	6d4e                	ld	s10,208(sp)
    80000572:	6dee                	ld	s11,216(sp)
    80000574:	7e0e                	ld	t3,224(sp)
    80000576:	7eae                	ld	t4,232(sp)
    80000578:	7f4e                	ld	t5,240(sp)
    8000057a:	7fee                	ld	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:101

  /* Swap mscratch with sp */

  csrrw     sp, mscratch, sp
    8000057c:	34011173          	csrrw	sp,mscratch,sp
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_exception_m.S:105

  /* Return from exception */

  mret
    80000580:	30200073          	mret
	...

00000000800005fa <sys_call0>:
sys_call3():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:86
sys_call3:
sys_call4:
sys_call5:
sys_call6:

  addi       sp, sp, -XCPTCONTEXT_SIZE /* make room */
    800005fa:	df010113          	addi	sp,sp,-528
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:87
  save_ctx   sp                        /* save current context */
    800005fe:	e406                	sd	ra,8(sp)
    80000600:	f012                	sd	tp,32(sp)
    80000602:	f416                	sd	t0,40(sp)
    80000604:	f81a                	sd	t1,48(sp)
    80000606:	fc1e                	sd	t2,56(sp)
    80000608:	e0a2                	sd	s0,64(sp)
    8000060a:	e4a6                	sd	s1,72(sp)
    8000060c:	e8aa                	sd	a0,80(sp)
    8000060e:	ecae                	sd	a1,88(sp)
    80000610:	f0b2                	sd	a2,96(sp)
    80000612:	f4b6                	sd	a3,104(sp)
    80000614:	f8ba                	sd	a4,112(sp)
    80000616:	fcbe                	sd	a5,120(sp)
    80000618:	e142                	sd	a6,128(sp)
    8000061a:	e546                	sd	a7,136(sp)
    8000061c:	e94a                	sd	s2,144(sp)
    8000061e:	ed4e                	sd	s3,152(sp)
    80000620:	f152                	sd	s4,160(sp)
    80000622:	f556                	sd	s5,168(sp)
    80000624:	f95a                	sd	s6,176(sp)
    80000626:	fd5e                	sd	s7,184(sp)
    80000628:	e1e2                	sd	s8,192(sp)
    8000062a:	e5e6                	sd	s9,200(sp)
    8000062c:	e9ea                	sd	s10,208(sp)
    8000062e:	edee                	sd	s11,216(sp)
    80000630:	f1f2                	sd	t3,224(sp)
    80000632:	f5f6                	sd	t4,232(sp)
    80000634:	f9fa                	sd	t5,240(sp)
    80000636:	fdfe                	sd	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:91

  /* Mask interrupts and store the status register to context */

  li         s1, STATUS_IE             /* move IE -> PIE */
    80000638:	4489                	li	s1,2
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:92
  csrrc      s0, CSR_STATUS, s1
    8000063a:	1004b473          	csrrc	s0,sstatus,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:93
  and        s1, s0, s1                /* if (STATUS & IE) */
    8000063e:	8ce1                	and	s1,s1,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:94
  beqz       s1, 1f
    80000640:	c491                	beqz	s1,8000064c <sys_call0+0x52>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:95
  li         s1, ~STATUS_IE            /* clear IE */
    80000642:	54f5                	li	s1,-3
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:96
  and        s0, s0, s1
    80000644:	8c65                	and	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:97
  li         s1, STATUS_PIE            /* set PIE */
    80000646:	02000493          	li	s1,32
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:98
  or         s0, s0, s1
    8000064a:	8c45                	or	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:103

 1:
  /* Set previous privilege, we are in privileged mode now */

  li         s1, STATUS_PPP            /* set previous privilege */
    8000064c:	10000493          	li	s1,256
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:104
  or         s0, s0, s1
    80000650:	8c45                	or	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:105
  REGSTORE   s0, REG_INT_CTX(sp)       /* store status to context */
    80000652:	e222                	sd	s0,256(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:107

  REGSTORE   x1, REG_EPC(sp)           /* save ra to epc */
    80000654:	e006                	sd	ra,0(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:109

  addi       s0, sp, XCPTCONTEXT_SIZE
    80000656:	0c00                	addi	s0,sp,528
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:110
  REGSTORE   s0, REG_SP(sp)            /* original SP */
    80000658:	e822                	sd	s0,16(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:112

  mv         a0, sp                    /* a0 = context */
    8000065a:	850a                	mv	a0,sp
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:117

#if CONFIG_ARCH_INTERRUPTSTACK > 15
  /* Switch to interrupt stack */

  setintstack t0, t1
    8000065c:	140022f3          	csrr	t0,sscratch
    80000660:	0102b103          	ld	sp,16(t0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:122
#endif

  /* Run the handler */

  jal        x1, riscv_perform_syscall
    80000664:	026010ef          	jal	ra,8000168a <riscv_perform_syscall>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:126

  /* Restore (potentially new) context */

  mv         sp, a0                    /* use sp, as a0 gets wiped */
    80000668:	812a                	mv	sp,a0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:128

  REGLOAD    s0, REG_EPC(sp)           /* restore epc */
    8000066a:	6402                	ld	s0,0(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:129
  csrw       CSR_EPC, s0
    8000066c:	14141073          	csrw	sepc,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:133

  /* Restore status register, but don't enable interrupts yet */

  REGLOAD    s0, REG_INT_CTX(sp)       /* restore status */
    80000670:	6412                	ld	s0,256(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:134
  li         s1, STATUS_IE             /* move IE -> PIE */
    80000672:	4489                	li	s1,2
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:135
  and        s1, s0, s1                /* if (STATUS & IE) */
    80000674:	8ce1                	and	s1,s1,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:136
  beqz       s1, 1f
    80000676:	c491                	beqz	s1,80000682 <sys_call0+0x88>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:137
  li         s1, ~STATUS_IE            /* clear IE */
    80000678:	54f5                	li	s1,-3
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:138
  and        s0, s0, s1
    8000067a:	8c65                	and	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:139
  li         s1, STATUS_PIE            /* set PIE */
    8000067c:	02000493          	li	s1,32
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:140
  or         s0, s0, s1
    80000680:	8c45                	or	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:143

1:
  csrw       CSR_STATUS, s0
    80000682:	10041073          	csrw	sstatus,s0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:148

#ifdef CONFIG_ARCH_KERNEL_STACK
  /* Returning to userspace ? */

  li         s1, STATUS_PPP
    80000686:	10000493          	li	s1,256
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:149
  and        s0, s0, s1
    8000068a:	8c65                	and	s0,s0,s1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:150
  bnez       s0, 1f
    8000068c:	e411                	bnez	s0,80000698 <sys_call0+0x9e>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:154

  /* Set the next task's kernel stack to the scratch area */

  jal        x1, riscv_current_ksp
    8000068e:	029000ef          	jal	ra,80000eb6 <riscv_current_ksp>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:155
  csrr       s0, CSR_SCRATCH
    80000692:	14002473          	csrr	s0,sscratch
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:156
  REGSTORE   a0, RISCV_PERCPU_KSP(s0)
    80000696:	f008                	sd	a0,32(s0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:161

1:
#endif

  load_ctx   sp
    80000698:	60a2                	ld	ra,8(sp)
    8000069a:	7202                	ld	tp,32(sp)
    8000069c:	72a2                	ld	t0,40(sp)
    8000069e:	7342                	ld	t1,48(sp)
    800006a0:	73e2                	ld	t2,56(sp)
    800006a2:	6406                	ld	s0,64(sp)
    800006a4:	64a6                	ld	s1,72(sp)
    800006a6:	6546                	ld	a0,80(sp)
    800006a8:	65e6                	ld	a1,88(sp)
    800006aa:	7606                	ld	a2,96(sp)
    800006ac:	76a6                	ld	a3,104(sp)
    800006ae:	7746                	ld	a4,112(sp)
    800006b0:	77e6                	ld	a5,120(sp)
    800006b2:	680a                	ld	a6,128(sp)
    800006b4:	68aa                	ld	a7,136(sp)
    800006b6:	694a                	ld	s2,144(sp)
    800006b8:	69ea                	ld	s3,152(sp)
    800006ba:	7a0a                	ld	s4,160(sp)
    800006bc:	7aaa                	ld	s5,168(sp)
    800006be:	7b4a                	ld	s6,176(sp)
    800006c0:	7bea                	ld	s7,184(sp)
    800006c2:	6c0e                	ld	s8,192(sp)
    800006c4:	6cae                	ld	s9,200(sp)
    800006c6:	6d4e                	ld	s10,208(sp)
    800006c8:	6dee                	ld	s11,216(sp)
    800006ca:	7e0e                	ld	t3,224(sp)
    800006cc:	7eae                	ld	t4,232(sp)
    800006ce:	7f4e                	ld	t5,240(sp)
    800006d0:	7fee                	ld	t6,248(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:163

  REGLOAD    sp, REG_SP(sp)            /* restore original sp */
    800006d2:	6142                	ld	sp,16(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/supervisor/riscv_syscall.S:167

  /* return from exception, which updates the status register */

  ERET
    800006d4:	10200073          	sret
	...

0000000080000700 <up_saveusercontext>:
up_saveusercontext():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:51
  .global up_saveusercontext
  .align  8

up_saveusercontext:

  save_ctx   a0
    80000700:	00153423          	sd	ra,8(a0)
    80000704:	02453023          	sd	tp,32(a0)
    80000708:	02553423          	sd	t0,40(a0)
    8000070c:	02653823          	sd	t1,48(a0)
    80000710:	02753c23          	sd	t2,56(a0)
    80000714:	e120                	sd	s0,64(a0)
    80000716:	e524                	sd	s1,72(a0)
    80000718:	e928                	sd	a0,80(a0)
    8000071a:	ed2c                	sd	a1,88(a0)
    8000071c:	f130                	sd	a2,96(a0)
    8000071e:	f534                	sd	a3,104(a0)
    80000720:	f938                	sd	a4,112(a0)
    80000722:	fd3c                	sd	a5,120(a0)
    80000724:	09053023          	sd	a6,128(a0)
    80000728:	09153423          	sd	a7,136(a0)
    8000072c:	09253823          	sd	s2,144(a0)
    80000730:	09353c23          	sd	s3,152(a0)
    80000734:	0b453023          	sd	s4,160(a0)
    80000738:	0b553423          	sd	s5,168(a0)
    8000073c:	0b653823          	sd	s6,176(a0)
    80000740:	0b753c23          	sd	s7,184(a0)
    80000744:	0d853023          	sd	s8,192(a0)
    80000748:	0d953423          	sd	s9,200(a0)
    8000074c:	0da53823          	sd	s10,208(a0)
    80000750:	0db53c23          	sd	s11,216(a0)
    80000754:	0fc53023          	sd	t3,224(a0)
    80000758:	0fd53423          	sd	t4,232(a0)
    8000075c:	0fe53823          	sd	t5,240(a0)
    80000760:	0ff53c23          	sd	t6,248(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:53

  csrr       a1, CSR_STATUS
    80000764:	100025f3          	csrr	a1,sstatus
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:54
  REGSTORE   a1, REG_INT_CTX(a0)  /* status */
    80000768:	10b53023          	sd	a1,256(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:56

  REGSTORE   sp, REG_X2(a0)       /* original SP */
    8000076c:	00253823          	sd	sp,16(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:57
  REGSTORE   x1, REG_EPC(a0)
    80000770:	00153023          	sd	ra,0(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:60

#ifdef CONFIG_ARCH_FPU
  addi       a0, a0, INT_XCPT_SIZE /* Save FPU after integer regs */
    80000774:	10850513          	addi	a0,a0,264
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:61
  riscv_savefpu a0
    80000778:	00053027          	fsd	ft0,0(a0)
    8000077c:	00153427          	fsd	ft1,8(a0)
    80000780:	00253827          	fsd	ft2,16(a0)
    80000784:	00353c27          	fsd	ft3,24(a0)
    80000788:	02453027          	fsd	ft4,32(a0)
    8000078c:	02553427          	fsd	ft5,40(a0)
    80000790:	02653827          	fsd	ft6,48(a0)
    80000794:	02753c27          	fsd	ft7,56(a0)
    80000798:	a120                	fsd	fs0,64(a0)
    8000079a:	a524                	fsd	fs1,72(a0)
    8000079c:	a928                	fsd	fa0,80(a0)
    8000079e:	ad2c                	fsd	fa1,88(a0)
    800007a0:	b130                	fsd	fa2,96(a0)
    800007a2:	b534                	fsd	fa3,104(a0)
    800007a4:	b938                	fsd	fa4,112(a0)
    800007a6:	bd3c                	fsd	fa5,120(a0)
    800007a8:	09053027          	fsd	fa6,128(a0)
    800007ac:	09153427          	fsd	fa7,136(a0)
    800007b0:	09253827          	fsd	fs2,144(a0)
    800007b4:	09353c27          	fsd	fs3,152(a0)
    800007b8:	0b453027          	fsd	fs4,160(a0)
    800007bc:	0b553427          	fsd	fs5,168(a0)
    800007c0:	0b653827          	fsd	fs6,176(a0)
    800007c4:	0b753c27          	fsd	fs7,184(a0)
    800007c8:	0d853027          	fsd	fs8,192(a0)
    800007cc:	0d953427          	fsd	fs9,200(a0)
    800007d0:	0da53827          	fsd	fs10,208(a0)
    800007d4:	0db53c27          	fsd	fs11,216(a0)
    800007d8:	0fc53027          	fsd	ft8,224(a0)
    800007dc:	0fd53427          	fsd	ft9,232(a0)
    800007e0:	0fe53827          	fsd	ft10,240(a0)
    800007e4:	0ff53c27          	fsd	ft11,248(a0)
    800007e8:	003022f3          	frcsr	t0
    800007ec:	10553023          	sd	t0,256(a0)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:64
#endif

  li         a0, 0
    800007f0:	4501                	li	a0,0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_saveusercontext.S:65
  jr         ra
    800007f2:	8082                	ret
	...

0000000080000802 <up_fork>:
up_fork():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:95
.type up_fork, function

up_fork:
  /* Create a stack frame */

  addi        sp, sp, -FORK_SIZEOF
    80000802:	7155                	addi	sp,sp,-208
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:100

  /* CPU registers */
  /* Save the volatile registers */

  REGSTORE    s1, FORK_S1_OFFSET(sp)
    80000804:	e426                	sd	s1,8(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:101
  REGSTORE    s2, FORK_S2_OFFSET(sp)
    80000806:	e84a                	sd	s2,16(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:102
  REGSTORE    s3, FORK_S3_OFFSET(sp)
    80000808:	ec4e                	sd	s3,24(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:103
  REGSTORE    s4, FORK_S4_OFFSET(sp)
    8000080a:	f052                	sd	s4,32(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:104
  REGSTORE    s5, FORK_S5_OFFSET(sp)
    8000080c:	f456                	sd	s5,40(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:105
  REGSTORE    s6, FORK_S6_OFFSET(sp)
    8000080e:	f85a                	sd	s6,48(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:106
  REGSTORE    s7, FORK_S7_OFFSET(sp)
    80000810:	fc5e                	sd	s7,56(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:107
  REGSTORE    s8, FORK_S8_OFFSET(sp)
    80000812:	e0e2                	sd	s8,64(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:108
  REGSTORE    s9, FORK_S9_OFFSET(sp)
    80000814:	e4e6                	sd	s9,72(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:109
  REGSTORE    s10, FORK_S10_OFFSET(sp)
    80000816:	e8ea                	sd	s10,80(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:110
  REGSTORE    s11, FORK_S11_OFFSET(sp)
    80000818:	ecee                	sd	s11,88(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:117
  /* Save the frame pointer, stack pointer, and return address */

#ifdef CONFIG_RISCV_FRAMEPOINTER
  REGSTORE    fp, FORK_FP_OFFSET(sp)
#else
  REGSTORE    s0, FORK_S0_OFFSET(sp)
    8000081a:	e022                	sd	s0,0(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:120
#endif

  addi        s0, sp, FORK_SIZEOF
    8000081c:	0980                	addi	s0,sp,208
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:121
  REGSTORE    s0, FORK_SP_OFFSET(sp) /* original SP */
    8000081e:	f0a2                	sd	s0,96(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:122
  REGSTORE    x1, FORK_RA_OFFSET(sp) /* return address */
    80000820:	f486                	sd	ra,104(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:127

  /* Floating point registers */

#ifdef CONFIG_ARCH_FPU
  FSTORE      fs0, FORK_FS0_OFFSET(sp)
    80000822:	b8a2                	fsd	fs0,112(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:128
  FSTORE      fs1, FORK_FS1_OFFSET(sp)
    80000824:	bca6                	fsd	fs1,120(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:129
  FSTORE      fs2, FORK_FS2_OFFSET(sp)
    80000826:	a14a                	fsd	fs2,128(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:130
  FSTORE      fs3, FORK_FS3_OFFSET(sp)
    80000828:	a54e                	fsd	fs3,136(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:131
  FSTORE      fs4, FORK_FS4_OFFSET(sp)
    8000082a:	a952                	fsd	fs4,144(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:132
  FSTORE      fs5, FORK_FS5_OFFSET(sp)
    8000082c:	ad56                	fsd	fs5,152(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:133
  FSTORE      fs6, FORK_FS6_OFFSET(sp)
    8000082e:	b15a                	fsd	fs6,160(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:134
  FSTORE      fs7, FORK_FS7_OFFSET(sp)
    80000830:	b55e                	fsd	fs7,168(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:135
  FSTORE      fs8, FORK_FS8_OFFSET(sp)
    80000832:	b962                	fsd	fs8,176(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:136
  FSTORE      fs9, FORK_FS9_OFFSET(sp)
    80000834:	bd66                	fsd	fs9,184(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:137
  FSTORE      fs10, FORK_FS10_OFFSET(sp)
    80000836:	a1ea                	fsd	fs10,192(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:138
  FSTORE      fs11, FORK_FS11_OFFSET(sp)
    80000838:	a5ee                	fsd	fs11,200(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:143
#endif

  /* Then, call riscv_fork(), passing it a pointer to the stack frame */

  mv          a0, sp
    8000083a:	850a                	mv	a0,sp
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:144
  call        riscv_fork
    8000083c:	37f0b0ef          	jal	ra,8000c3ba <riscv_fork>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:148

  /* Release the stack frame and return the value returned by riscv_fork */

  REGLOAD     x1, FORK_RA_OFFSET(sp)
    80000840:	70a6                	ld	ra,104(sp)
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:149
  addi        sp, sp, FORK_SIZEOF
    80000842:	6169                	addi	sp,sp,208
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/fork.S:150
  ret
    80000844:	8082                	ret
	...

0000000080000850 <smh_call>:
smh_call():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_semihost.S:37
  .global smh_call
  .type smh_call @function

smh_call:

  slli zero, zero, 0x1f
    80000850:	01f01013          	slli	zero,zero,0x1f
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_semihost.S:38
  ebreak
    80000854:	00100073          	ebreak
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_semihost.S:39
  srai zero, zero, 0x7
    80000858:	40705013          	srai	zero,zero,0x7
/Users/Luppy/riscv/nuttx/arch/risc-v/src/common/riscv_semihost.S:40
  ret
    8000085c:	00008067          	ret
    80000860:	0000                	unimp
	...

0000000080000864 <__clzdi2>:
__clzdi2():
/scratch/jenkins/workspace/tpp-freedom-tools/tpp01--build-binary-packages--parameterized/obj/x86_64-apple-darwin/build/riscv64-unknown-elf-gcc/build-gcc-stage2/riscv64-unknown-elf/rv64imafdc/lp64d/libgcc/../../../../../riscv-gcc/libgcc/libgcc2.c:710
    80000864:	03800793          	li	a5,56
/scratch/jenkins/workspace/tpp-freedom-tools/tpp01--build-binary-packages--parameterized/obj/x86_64-apple-darwin/build/riscv64-unknown-elf-gcc/build-gcc-stage2/riscv64-unknown-elf/rv64imafdc/lp64d/libgcc/../../../../../riscv-gcc/libgcc/libgcc2.c:710 (discriminator 20)
    80000868:	00f55733          	srl	a4,a0,a5
    8000086c:	0ff77713          	zext.b	a4,a4
    80000870:	e319                	bnez	a4,80000876 <__clzdi2+0x12>
/scratch/jenkins/workspace/tpp-freedom-tools/tpp01--build-binary-packages--parameterized/obj/x86_64-apple-darwin/build/riscv64-unknown-elf-gcc/build-gcc-stage2/riscv64-unknown-elf/rv64imafdc/lp64d/libgcc/../../../../../riscv-gcc/libgcc/libgcc2.c:710 (discriminator 18)
    80000872:	17e1                	addi	a5,a5,-8
    80000874:	fbf5                	bnez	a5,80000868 <__clzdi2+0x4>
/scratch/jenkins/workspace/tpp-freedom-tools/tpp01--build-binary-packages--parameterized/obj/x86_64-apple-darwin/build/riscv64-unknown-elf-gcc/build-gcc-stage2/riscv64-unknown-elf/rv64imafdc/lp64d/libgcc/../../../../../riscv-gcc/libgcc/libgcc2.c:710 (discriminator 21)
    80000876:	04000713          	li	a4,64
    8000087a:	8f1d                	sub	a4,a4,a5
    8000087c:	00f55533          	srl	a0,a0,a5
    80000880:	0001b797          	auipc	a5,0x1b
    80000884:	e1878793          	addi	a5,a5,-488 # 8001b698 <__clz_tab>
    80000888:	953e                	add	a0,a0,a5
    8000088a:	00054503          	lbu	a0,0(a0)
/scratch/jenkins/workspace/tpp-freedom-tools/tpp01--build-binary-packages--parameterized/obj/x86_64-apple-darwin/build/riscv64-unknown-elf-gcc/build-gcc-stage2/riscv64-unknown-elf/rv64imafdc/lp64d/libgcc/../../../../../riscv-gcc/libgcc/libgcc2.c:713 (discriminator 21)
    8000088e:	40a7053b          	subw	a0,a4,a0
    80000892:	8082                	ret

0000000080000894 <qemu_rv_clear_bss>:
qemu_rv_clear_bss():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:80
   * certain that there are no issues with the state of global variables.
   */

  for (dest = (uint32_t *)_sbss; dest < (uint32_t *)_ebss; )
    {
      *dest++ = 0;
    80000894:	00205797          	auipc	a5,0x205
    80000898:	76c78793          	addi	a5,a5,1900 # 80206000 <_ebss>
    8000089c:	00200717          	auipc	a4,0x200
    800008a0:	a9170713          	addi	a4,a4,-1391 # 8020032d <g_syslog_mask+0x5>
    800008a4:	4601                	li	a2,0
    800008a6:	00e7ec63          	bltu	a5,a4,800008be <qemu_rv_clear_bss+0x2a>
    800008aa:	00200797          	auipc	a5,0x200
    800008ae:	a8678793          	addi	a5,a5,-1402 # 80200330 <g_intstackalloc>
    800008b2:	00205617          	auipc	a2,0x205
    800008b6:	75160613          	addi	a2,a2,1873 # 80206003 <_ebss+0x3>
    800008ba:	8e1d                	sub	a2,a2,a5
    800008bc:	9a71                	andi	a2,a2,-4
    800008be:	4581                	li	a1,0
    800008c0:	00200517          	auipc	a0,0x200
    800008c4:	a7050513          	addi	a0,a0,-1424 # 80200330 <g_intstackalloc>
    800008c8:	0970906f          	j	8000a15e <memset>

00000000800008cc <qemu_rv_start>:
qemu_rv_start():
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:166
/****************************************************************************
 * Name: qemu_rv_start
 ****************************************************************************/

void qemu_rv_start(int mhartid, const char *dtb)
{
    800008cc:	1101                	addi	sp,sp,-32
    800008ce:	e822                	sd	s0,16(sp)
    800008d0:	e426                	sd	s1,8(sp)
    800008d2:	ec06                	sd	ra,24(sp)
    800008d4:	842a                	mv	s0,a0
    800008d6:	84ae                	mv	s1,a1
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:169
  /* NOTE: still in M-mode */

  if (0 == mhartid)
    800008d8:	e511                	bnez	a0,800008e4 <qemu_rv_start+0x18>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:171
    {
      qemu_rv_clear_bss();
    800008da:	fbbff0ef          	jal	ra,80000894 <qemu_rv_clear_bss>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:175

      /* Initialize the per CPU areas */

      riscv_percpu_add_hart(mhartid);
    800008de:	4501                	li	a0,0
    800008e0:	5e8000ef          	jal	ra,80000ec8 <riscv_percpu_add_hart>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:180
    }

  /* Disable MMU and enable PMP */

  WRITE_CSR(satp, 0x0);
    800008e4:	18005073          	csrwi	satp,0
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:181
  WRITE_CSR(pmpaddr0, 0x3fffffffffffffull);
    800008e8:	57fd                	li	a5,-1
    800008ea:	83a9                	srli	a5,a5,0xa
    800008ec:	3b079073          	csrw	pmpaddr0,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:182
  WRITE_CSR(pmpcfg0, 0xf);
    800008f0:	3a07d073          	csrwi	pmpcfg0,15
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:186

  /* Set exception and interrupt delegation for S-mode */

  WRITE_CSR(medeleg, 0xffff);
    800008f4:	67c1                	lui	a5,0x10
    800008f6:	37fd                	addiw	a5,a5,-1
    800008f8:	30279073          	csrw	medeleg,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:187
  WRITE_CSR(mideleg, 0xffff);
    800008fc:	30379073          	csrw	mideleg,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:191

  /* Allow to write satp from S-mode */

  CLEAR_CSR(mstatus, MSTATUS_TVM);
    80000900:	001007b7          	lui	a5,0x100
    80000904:	3007b073          	csrc	mstatus,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:195

  /* Set mstatus to S-mode and enable SUM */

  CLEAR_CSR(mstatus, ~MSTATUS_MPP_MASK);
    80000908:	77f9                	lui	a5,0xffffe
    8000090a:	7ff7879b          	addiw	a5,a5,2047
    8000090e:	3007b073          	csrc	mstatus,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:196
  SET_CSR(mstatus, MSTATUS_MPPS | SSTATUS_SUM);
    80000912:	000417b7          	lui	a5,0x41
    80000916:	8007879b          	addiw	a5,a5,-2048
    8000091a:	3007a073          	csrs	mstatus,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:200

  /* Set the trap vector for S-mode */

  WRITE_CSR(stvec, (uintptr_t)__trap_vec);
    8000091e:	fffff797          	auipc	a5,0xfffff
    80000922:	73278793          	addi	a5,a5,1842 # 80000050 <__trap_vec>
    80000926:	10579073          	csrw	stvec,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:204

  /* Set the trap vector for M-mode */

  WRITE_CSR(mtvec, (uintptr_t)__trap_vec_m);
    8000092a:	00000797          	auipc	a5,0x0
    8000092e:	ad678793          	addi	a5,a5,-1322 # 80000400 <__trap_vec_m>
    80000932:	30579073          	csrw	mtvec,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:206

  if (0 == mhartid)
    80000936:	e019                	bnez	s0,8000093c <qemu_rv_start+0x70>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:212
    {
      /* Only the primary CPU needs to initialize mtimer
       * before entering to S-mode
       */

      up_mtimer_initialize();
    80000938:	10a000ef          	jal	ra,80000a42 <up_mtimer_initialize>
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:217
    }

  /* Set mepc to the entry */

  WRITE_CSR(mepc, (uintptr_t)qemu_rv_start_s);
    8000093c:	00000797          	auipc	a5,0x0
    80000940:	05078793          	addi	a5,a5,80 # 8000098c <qemu_rv_start_s>
    80000944:	34179073          	csrw	mepc,a5
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:221

  /* Set a0 to mhartid and a1 to dtb explicitly and enter to S-mode */

  asm volatile (
    80000948:	8522                	mv	a0,s0
    8000094a:	85a6                	mv	a1,s1
    8000094c:	30200073          	mret
/Users/Luppy/riscv/nuttx/arch/risc-v/src/chip/qemu_rv_start.c:227
      "mv a0, %0 \n"
      "mv a1, %1 \n"
      "mret \n"
      :: "r" (mhartid), "r" (dtb)
  );
}
    80000950:	60e2                	ld	ra,24(sp)
    80000952:	6442                	ld	s0,16(sp)
    80000954:	64a2                	ld	s1,8(sp)
    80000956:	6105                	addi	sp,sp,32
    80000958:	8082                	ret
