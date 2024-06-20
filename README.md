# Emulate Sophgo SG2000 SoC / Milk-V Duo S SBC with TinyEMU RISC-V Emulator

Let's create a Software Emulator for Sophgo SG2000 SoC and Milk-V Duo S SBC!

We begin with the [TinyEMU RISC-V Emulator](https://lupyuen.github.io/articles/tinyemu3) for Ox64 BL808 SBC. And we tweak it for SG2000.

We update the System Memory Map for SG2000...

[Update RAM Base Addr, CLINT Addr, PLIC Addr](https://github.com/lupyuen2/sg2000-emulator/commit/d36190c63c1db116a206a26f3bc27dfacf5c8298)

```c
#define RAM_BASE_ADDR  0x80200000ul
#define CLINT_BASE_ADDR 0x74000000ul  // TODO: Unused
#define PLIC_BASE_ADDR 0x70000000ul
```

Then build and run TinyEMU...

```bash
## Build TinyEMU for macOS
## For Linux: See https://github.com/lupyuen/nuttx-sg2000/blob/main/.github/workflows/sg2000-test.yml#L29-L45
cd $HOME/sg2000-emulator/
make clean
make \
  CFLAGS="-I$(brew --prefix)/opt/openssl/include -I$(brew --prefix)/opt/sdl2/include" \
  LDFLAGS="-L$(brew --prefix)/opt/openssl/lib -L$(brew --prefix)/opt/sdl2/lib" \
  CONFIG_MACOS=y

## Build NuttX for SG2000
## https://lupyuen.github.io/articles/sg2000#appendix-build-nuttx-for-sg2000
cd $HOME/nuttx
tools/configure.sh milkv_duos:nsh
make
## Omitted: Create the `Image` file for SG2000 NuttX

## Boot TinyEMU with NuttX for SG2000
cd $HOME/nuttx
wget https://raw.githubusercontent.com/lupyuen/nuttx-sg2000/main/nuttx.cfg
$HOME/sg2000/sg2000-emulator/temu nuttx.cfg
```

# `auipc` Overflow in Boot Code

When we boot TinyEMU with SG2000 NuttX, it crashes...

```bash
$ sg2000-emulator/temu nuttx.cfg
TinyEMU Emulator for Sophgo SG2000 SoC
virtio_console_init
Patched DCACHE.IALL (Invalidate all Page Table Entries in the D-Cache) at 0x80200a28
Patched SYNC.S (Ensure that all Cache Operations are completed) at 0x80200a2c
Found ECALL (Start System Timer) at 0x8020b2c6
Patched RDTIME (Read System Time) at 0x8020b2cc
elf_len=0
virtio_console_resize_event
raise_exception2: cause=1, tval=0xffffffff80200000, pc=0xffffffff80200000
pc =ffffffff80200000 ra =0000000000000000 sp =0000000000000000 gp =0000000000000000
tp =0000000000000000 t0 =ffffffff80200000 t1 =0000000000000000 t2 =0000000000000000
s0 =0000000000000000 s1 =0000000000000000 a0 =0000000000000000 a1 =0000000000001040
a2 =0000000000000000 a3 =0000000000000000 a4 =0000000000000000 a5 =0000000000040800
a6 =0000000000000000 a7 =0000000000000000 s2 =0000000000000000 s3 =0000000000000000
s4 =0000000000000000 s5 =0000000000000000 s6 =0000000000000000 s7 =0000000000000000
s8 =0000000000000000 s9 =0000000000000000 s10=0000000000000000 s11=0000000000000000
t3 =0000000000000000 t4 =0000000000000000 t5 =0000000000000000 t6 =0000000000000000
priv=S mstatus=0000000a00040080 cycles=19
 mideleg=0000000000000222 mie=0000000000000000 mip=00000000000000a0
tinyemu: Illegal instruction, quitting: pc=0x0, instruction=0x0
```

0xffffffff80200000 looks sus, it seems related to RAM Base Address 0x80200000. We check the TinyEMU Boot Code: [riscv_machine.c](https://github.com/lupyuen2/sg2000-emulator/blob/main/riscv_machine.c#L967-L970)

```c
static void copy_bios(...) {
...
  // TinyEMU Boot Code
  q = (uint32_t *)(ram_ptr + 0x1000);

  // Load RAM Base Address into Register T0:
  // auipc t0, RAM_BASE_ADDR
  q[0] = 0x297 + RAM_BASE_ADDR - 0x1000;
```

Maybe auipc has a problem? We run the [RISC-V Online Assembler](https://riscvasm.lucasteske.dev/#)

We try to assemble the TinyEMU Boot Code (for loading the RAM Base Address 0x80200000)...

```bash
auipc t0, 0x80200000
```

But it produces this error...

```bash
file.s: Assembler messages:
file.s:3: Error: lui expression not in range 0..1048575
file.s:3: Error: value of 0000080200000000 too large for field of 4 bytes at 0000000000000000
```

0x80200000 is too big to assemble into the auipc address!

# Change `auipc` to `li` in Boot Code

So we load 0x80200000 into Register t0 in another way: `li`

```bash
li  t0, 0x80200000
```

[RISC-V Online Assembler](https://riscvasm.lucasteske.dev/#) produces...

```bash
   0:	4010029b          	addiw	t0,zero,1025
   4:	01529293          	slli	t0,t0,0x15
```

We copy this into our TinyEMU Boot Code...

[Change auipc t0, 0x80200000 to li t0, 0x80200000](https://github.com/lupyuen2/sg2000-emulator/commit/b2d5cf63c5d6d1d0d4eafa5d400216d1f76a6e21)

```c
// `li  t0, 0x80200000` gets assembled to:
// 4010029b addiw t0,zero,1025
// 01529293 slli  t0,t0,0x15
q[pc++] = 0x4010029b; // addiw t0,zero,1025
q[pc++] = 0x01529293; // slli  t0,t0,0x15

// Previously: q[pc++] = 0x297 + RAM_BASE_ADDR - 0x1000; /* auipc t0, jump_addr */
// Which fails because RAM_BASE_ADDR is too big for auipc
```

And it hangs (instead of crashing). Some progress!

```bash
$ sg2000-emulator/temu nuttx.cfg
TinyEMU Emulator for Sophgo SG2000 SoC
virtio_console_init
Patched DCACHE.IALL (Invalidate all Page Table Entries in the D-Cache) at 0x80200a28
Patched SYNC.S (Ensure that all Cache Operations are completed) at 0x80200a2c
Found ECALL (Start System Timer) at 0x8020b2c6
Patched RDTIME (Read System Time) at 0x8020b2cc
elf_len=0
virtio_console_resize_event
```

# Fix the UART Output

We fix the UART Output Registers: [Update UART Output Register and UART Status Register](https://github.com/lupyuen2/sg2000-emulator/commit/fd6e5333ef6f89b452901d6e580d8387e9da2573)

Now we see NSH Shell yay!

```bash
$ $HOME/sg2000/sg2000-emulator/temu nuttx.cfg 
...
TinyEMU Emulator for Sophgo SG2000 SoC
virtio_console_init
Patched DCACHE.IALL (Invalidate all Page Table Entries in the D-Cache) at 0x80200a28
Patched SYNC.S (Ensure that all Cache Operations are completed) at 0x80200a2c
Found ECALL (Start System Timer) at 0x8020b2c6
Patched RDTIME (Read System Time) at 0x8020b2cc
elf_len=0
virtio_console_resize_event
ABC
NuttShell (NSH) NuttX-12.5.1
nsh>
```

When we press a key, NuttX triggers an expected interrupt...

```bash
$ $HOME/sg2000/sg2000-emulator/temu nuttx.cfg 
...
NuttShell (NSH) NuttX-12.5.1
nsh> irq_unexpected_isr: ERROR irq: 45
_assert: Current Version: NuttX  12.5.1 218ccd843a Jun 18 2024 22:14:46 risc-v
_assert: Assertion failed panic: at file: irq/irq_unexpectedisr.c:54 task: Idle_Task process: Kernel 0x8020110c
up_dump_register: EPC: 000000008021432a
```

# Fix the UART Interrupt

Now we fix the UART Input and UART Interrupt. Based on the NuttX Config...

```bash
CONFIG_16550_UART0_IRQ=69
```

Since NuttX IRQ Offset is 25, so Actual RISC-V IRQ is 69 - 25 = 44 (as confirmed by the SG2000 Reference Manual)...

[Set VIRTIO_IRQ to 44](https://github.com/lupyuen2/sg2000-emulator/commit/643c25cada46289539e31579616e7afbf108c3ae)

```c
#define VIRTIO_IRQ       44  // UART0 IRQ
```

But when we press a key: TinyEMU crashes with a Segmentation Fault...

```bash
$ $HOME/sg2000/sg2000-emulator/temu nuttx.cfg    
...
NuttShell (NSH) NuttX-12.5.1
nsh> [1]    94499 segmentation fault  $HOME/sg2000/sg2000-emulator/temu nuttx.cfg
```

# UART Input causes Segmentation Fault

We debug with `lldb` (because `gdb` is not available for macOS Arm64)...

```bash
$ lldb $HOME/sg2000/sg2000-emulator/temu nuttx.cfg 
(lldb) target create "/Users/luppy/sg2000/sg2000-emulator/temu"
Current executable set to '/Users/luppy/sg2000/sg2000-emulator/temu' (arm64).
(lldb) settings set -- target.run-args  "nuttx.cfg"
(lldb) r
Process 90245 launched: '/Users/luppy/sg2000/sg2000-emulator/temu' (arm64)
...
NuttShell (NSH) NuttX-12.5.1
Process 90245 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
    frame #0: 0x0000000000000000
error: memory read failed for 0x0
Target 0: (temu) stopped.
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
  * frame #0: 0x0000000000000000
    frame #1: 0x000000010000b978 temu`virt_machine_run(m=0x000000013461b2a0) at temu.c:598:17 [opt]
    frame #2: 0x000000010000be6c temu`main(argc=<unavailable>, argv=<unavailable>) at temu.c:845:9 [opt]
    frame #3: 0x0000000197a4e0e0 dyld`start + 2360
(lldb) 
```

Which is at...

```c
void virt_machine_run(VirtMachine *m) {
  ...    
  virtio_console_write_data(m->console_dev, buf, ret);
```

Why did TinyEMU crash? This doesn't make sense, `m` is non-null!

Maybe it's already optimised? Let's disable GCC Optimisation...

- [Disable GCC Optimisation](https://github.com/lupyuen2/sg2000-emulator/commit/af768df81fc349562565d638e359aca6127c9267)

Now it makes more sense!

```bash
$ lldb $HOME/sg2000/sg2000-emulator/temu nuttx.cfg 
...
NuttShell (NSH) NuttX-12.5.1
Process 1595 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
    frame #0: 0x0000000000000000
error: memory read failed for 0x0
Target 0: (temu) stopped.
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
  * frame #0: 0x0000000000000000
    frame #1: 0x0000000100002604 temu`set_irq(irq=0x000000013a607b08, level=1) at iomem.h:145:5
    frame #2: 0x00000001000025a4 temu`virtio_console_write_data(s=0x000000013d604080, buf="a", buf_len=1) at virtio.c:1346:5
    frame #3: 0x000000010000fd2c temu`virt_machine_run(m=0x000000013a607680) at temu.c:598:17
    frame #4: 0x00000001000105cc temu`main(argc=2, argv=0x000000016fdff080) at temu.c:845:9
    frame #5: 0x0000000197a4e0e0 dyld`start + 2360
```

Which crashes here...

```c
static inline void set_irq(IRQSignal *irq, int level) {
  irq->set_irq(irq->opaque, irq->irq_num, level);
}
```

Which means `irq->set_irq` is null! (Rightfully it should be set to `plic_set_irq`)

# IRQ Isn't Initialised

_Why is `irq->set_irq` set to null?_

We verify with an Assertion Check: [irq->set_irq is null!](https://github.com/lupyuen2/sg2000-emulator/commit/4a8652a70ff16b85ab16108686916a75505e4ef6)

```bash
NuttShell (NSH) NuttX-12.5.1
nsh> Assertion failed: (irq->set_irq != NULL), function set_irq, file iomem.h, line 145.
Process 15262 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = hit program assert
    frame #4: 0x000000010000249c temu`set_irq(irq=0x000000014271a478, level=1) at iomem.h:145:5
   142 
   143  static inline void set_irq(IRQSignal *irq, int level)
   144  {
-> 145      assert(irq->set_irq != NULL); //// TODO
   146      irq->set_irq(irq->opaque, irq->irq_num, level);
   147  }
   148 
Target 0: (temu) stopped.
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = hit program assert
    frame #0: 0x0000000197d9ea60 libsystem_kernel.dylib`__pthread_kill + 8
    frame #1: 0x0000000197dd6c20 libsystem_pthread.dylib`pthread_kill + 288
    frame #2: 0x0000000197ce3a30 libsystem_c.dylib`abort + 180
    frame #3: 0x0000000197ce2d20 libsystem_c.dylib`__assert_rtn + 284
  * frame #4: 0x000000010000249c temu`set_irq(irq=0x000000014271a478, level=1) at iomem.h:145:5
    frame #5: 0x0000000100002418 temu`virtio_console_write_data(s=0x0000000142719980, buf="a\xc0\xedE", buf_len=1) at virtio.c:1346:5
    frame #6: 0x000000010000fc30 temu`virt_machine_run(m=0x0000000142719ff0) at temu.c:598:17
    frame #7: 0x00000001000104d0 temu`main(argc=2, argv=0x000000016fdff080) at temu.c:845:9
    frame #8: 0x0000000197a4e0e0 dyld`start + 2360
```

We [inspect the variables](https://lldb.llvm.org/use/map.html) in LLDB...

```bash
frame #4: 0x000000010000249c temu`set_irq(irq=0x000000014271a478, level=1) at iomem.h:145:5
   142 
   143  static inline void set_irq(IRQSignal *irq, int level)
   144  {
-> 145      assert(irq->set_irq != NULL); //// TODO
   146      irq->set_irq(irq->opaque, irq->irq_num, level);
   147  }
   148 
(lldb) frame variable
(IRQSignal *) irq = 0x000000014271a478
(int) level = 1
(lldb) p *irq
(IRQSignal) {
  set_irq = 0x0000000000000000
  opaque = 0x0000000000000000
  irq_num = 0
}
```

`irq` is all empty! Where does `irq` come from? We step up the Call Stack...

```bash
(lldb) up
frame #5: 0x0000000100002418 temu`virtio_console_write_data(s=0x0000000142719980, buf="a\xc0\xedE", buf_len=1) at virtio.c:1346:5
   1343     _info("[%c]\n", buf[0]); ////
   1344     set_input(buf[0]);
   1345     s->int_status |= 1;
-> 1346     set_irq(s->irq, 1);
   1347
   1348 #ifdef NOTUSED
   1349     int queue_idx = 0;
(lldb) frame variable
(VIRTIODevice *) s = 0x0000000142719980
(const uint8_t *) buf = 0x000000016fdfeae8 "a\xc0\xedE"
(int) buf_len = 1

(lldb) p *s
(VIRTIODevice) {
  mem_map = 0x000000014380fc00
  mem_range = 0x000000014380fe60
  pci_dev = NULL
  irq = 0x000000014271a478
  get_ram_ptr = 0x00000001000065dc (temu`virtio_mmio_get_ram_ptr at virtio.c:193)
  debug = 0
  int_status = 1
  status = 0
  device_features_sel = 0
  queue_sel = 0
  queue = {
    [0] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = YES
    }
    [1] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [2] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [3] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [4] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [5] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [6] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
    [7] = {
      ready = 0
      num = 16
      last_avail_idx = 0
      desc_addr = 0
      avail_addr = 0
      used_addr = 0
      manual_recv = NO
    }
  }
  device_id = 3
  vendor_id = 65535
  device_features = 1
  device_recv = 0x00000001000025cc (temu`virtio_console_recv_request at virtio.c:1278)
  config_write = 0x0000000000000000
  config_space_size = 4
  config_space = "P\0\U00000019"
}
```

This says that `s` is a `virtio_console`.

# TinyEMU Supports only 32 IRQs

Why is `s->irq` empty? We step up the Call Stack...

```bash
(lldb) up
frame #6: 0x000000010000fc30 temu`virt_machine_run(m=0x0000000142719ff0) at temu.c:598:17
   595              len = min_int(len, sizeof(buf));
   596              ret = m->console->read_data(m->console->opaque, buf, len);
   597              if (ret > 0) {
-> 598                  virtio_console_write_data(m->console_dev, buf, ret);
   599              }
   600          }
   601  #endif
(lldb) p *m
(VirtMachine) {
  vmc = 0x0000000100080620
  net = NULL
  console_dev = 0x0000000142719980
  console = 0x0000000142719510
  fb_dev = NULL
}
```

`s->irq` comes from `m->console_dev`.

_Why is `console_dev` not properly inited?_

From earlier: UART0 is at RISC-V IRQ 44. But we discover that TinyEMU supports only 32 IRQs!

```c
static VirtMachine *riscv_machine_init(const VirtMachineParams *p) {
  for(i = 1; i < 32; i++) {
    irq_init(&s->plic_irq[i], plic_set_irq, s, i);
  }
```

# Increase TinyEMU IRQs from 32 to 64

So we increase the IRQs from 32 to 256: [Increase the IRQs from 32 to 256](https://github.com/lupyuen2/sg2000-emulator/commit/c6ce6bdbbdaf7585ce18f77b2b2f25a2317914be)

(256 IRQs is too many, as we shall soon see)

Now we see something different when we press a key!

```bash
NuttShell (NSH) NuttX-12.5.1
nsh> irq_unexpected_isr: ERROR irq: 37
_assert: Current Version: NuttX  12.5.1 218ccd843a Jun 18 2024 22:14:46 risc-v
_assert: Assertion failed panic: at file: irq/irq_unexpectedisr.c:54 task: Idle_Task process: Kernel 0x8020110c
up_dump_register: EPC: 000000008021432a
```

_What is NuttX IRQ 37? (RISC-V IRQ 12) Shouldn't it be RISC-V IRQ 44 for UART Input?_

Seems the RISC-V IRQs wrap around at 32? So RISC-V IRQ 44 becomes IRQ 12?

```bash
NuttShell (NSH) NuttX-12.5.1
nsh> plic_set_irq: irq_num=44, state=1
plic_pending_irq=0x800, plic_served_irq=0x0, mask=0x800
plic_update_mip: set_mip, pending=0x800, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x800, served=0x800
plic_read: pending irq=0xc
plic_pending_irq=0x800, plic_served_irq=0x800, mask=0x800
irq_unexpected_isr: ERROR irq: 37
```

So we fix the IRQ Size: [Increase the Pending IRQ Size and Served IRQ Size from 32-bit to 64-bit](https://github.com/lupyuen2/sg2000-emulator/commit/78ac3ad75f1ec0b54f5bee10488731c7a21fb9ea)

Now we see the correct Pending IRQ!

```bash
NuttShell (NSH) NuttX-12.5.1
nsh> plic_set_irq: irq_num=44, state=1
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c
plic_write: offset=0x201004, val=0x2c
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c
plic_write: offset=0x201004, val=0x2c
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c
plic_write: offset=0x201004, val=0x2c
```

# Pending IRQ Loops Forever

_Why does Pending IRQ loop forever? Maybe because we haven't cleared the UART Interrupt?_

To find out why, we trace the reads and writes to UART Registers: [Log the invalid memory accesses](https://github.com/lupyuen2/sg2000-emulator/commit/1f4b79bc9d276e1ca6371e60d0c9d25a53f7fa80)

```bash
NuttShell (NSH) NuttX-12.5.1
target_write_slow: invalid physical address 0x0000000004140004
User ECALL: pc=0xc0001998
target_write_slow: invalid physical address 0x0000000004140004
target_write_slow: invalid physical address 0x0000000004140004
nsh> target_write_slow: invalid physical address 0x0000000004140004
User ECALL: pc=0xc0001998
target_write_slow: invalid physical address 0x0000000004140004
target_write_slow: invalid physical address 0x0000000004140004
target_write_slow: invalid physical address 0x0000000004140004
User ECALL: pc=0xc000aa0e
target_write_slow: invalid physical address 0x0000000004140004
target_write_slow: invalid physical address 0x0000000004140004
plic_set_irq: irq_num=44, state=1
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c
target_read_slow: invalid physical address 0x0000000004140008
target_read_slow: invalid physical address 0x0000000004140008
target_read_slow: invalid physical address 0x0000000004140018
target_read_slow: invalid physical address 0x0000000004140008
target_read_slow: invalid physical address 0x0000000004140018
target_read_slow: invalid physical address 0x0000000004140008
target_read_slow: invalid physical address 0x0000000004140018
```

_What are UART Registers 0x4140008 and 0x4140018? Why are they read when we press a key?_

We look up the UART Registers...

```c
// UART Registers from https://github.com/apache/nuttx/blob/master/include/nuttx/serial/uart_16550.h
#define UART0_BASE_ADDR 0x04140000
#define CONFIG_16550_REGINCR 4
#define UART_IIR_INCR          2  /* Interrupt ID Register */
#define UART_FCR_INCR          2  /* FIFO Control Register */
#define UART_MSR_INCR          6  /* Modem Status Register */

// So 0x4140008 is one of these...
#define UART_IIR_OFFSET        (CONFIG_16550_REGINCR*UART_IIR_INCR)
#define UART_FCR_OFFSET        (CONFIG_16550_REGINCR*UART_FCR_INCR)

// And 0x4140018 is...
#define UART_MSR_OFFSET        (CONFIG_16550_REGINCR*UART_MSR_INCR)
```

We check the NuttX 16550 UART Driver for UART_IIR_OFFSET, UART_FCR_OFFSET and UART_MSR_OFFSET. (See the next section)

_What is UART Register 0x4140004? Why is it read when we print to UART?_

We look up the UART Register...

```c
// UART Registers from https://github.com/apache/nuttx/blob/master/include/nuttx/serial/uart_16550.h
#define UART0_BASE_ADDR 0x04140000
#define CONFIG_16550_REGINCR 4
#define UART_DLM_INCR          1  /* (DLAB =1) Divisor Latch MSB */
#define UART_IER_INCR          1  /* (DLAB =0) Interrupt Enable Register */

// So 0x4140004 is one of these...
#define UART_DLM_OFFSET        (CONFIG_16550_REGINCR*UART_DLM_INCR)
#define UART_DLM_OFFSET        (CONFIG_16550_REGINCR*UART_IER_INCR)
```

TODO: Check the NuttX 16550 UART Driver for UART_DLM_OFFSET and UART_DLM_OFFSET

# Emulate the UART Interrupt

_How does the NuttX 16550 UART Driver use UART_IIR_OFFSET, UART_FCR_OFFSET and UART_MSR_OFFSET?_

The NuttX 16550 UART Driver reads UART_IIR_OFFSET and UART_MSR_OFFSET to handle UART Interrupts: [uart_16550.c](https://github.com/apache/nuttx/blob/master/drivers/serial/uart_16550.c#L979-L1082)

```c
static int u16550_interrupt(int irq, FAR void *context, FAR void *arg)
{
  FAR struct uart_dev_s *dev = (struct uart_dev_s *)arg;
  FAR struct u16550_s *priv;
  uint32_t status;
  int passes;

  DEBUGASSERT(dev != NULL && dev->priv != NULL);
  priv = (FAR struct u16550_s *)dev->priv;

  /* Loop until there are no characters to be transferred or,
   * until we have been looping for a long time.
   */

  for (passes = 0; passes < 256; passes++)
    {
      /* Get the current UART status and check for loop
       * termination conditions
       */

      status = u16550_serialin(priv, UART_IIR_OFFSET);

      /* The UART_IIR_INTSTATUS bit should be zero if there are pending
       * interrupts
       */

      if ((status & UART_IIR_INTSTATUS) != 0)
        {
          /* Break out of the loop when there is no longer a
           * pending interrupt
           */

          break;
        }

      /* Handle the interrupt by its interrupt ID field */

      switch (status & UART_IIR_INTID_MASK)
        {
          /* Handle incoming, receive bytes (with or without timeout) */

          case UART_IIR_INTID_RDA:
          case UART_IIR_INTID_CTI:
            {
              uart_recvchars(dev);
              break;
            }

          /* Handle outgoing, transmit bytes */

          case UART_IIR_INTID_THRE:
            {
              uart_xmitchars(dev);
              break;
            }

          /* Just clear modem status interrupts (UART1 only) */

          case UART_IIR_INTID_MSI:
            {
              /* Read the modem status register (MSR) to clear */

              status = u16550_serialin(priv, UART_MSR_OFFSET);
              sinfo("MSR: %02"PRIx32"\n", status);
              break;
            }

          /* Just clear any line status interrupts */

          case UART_IIR_INTID_RLS:
            {
              /* Read the line status register (LSR) to clear */

              status = u16550_serialin(priv, UART_LSR_OFFSET);
              sinfo("LSR: %02"PRIx32"\n", status);
              break;
            }

          /* There should be no other values */

          default:
            {
              serr("ERROR: Unexpected IIR: %02"PRIx32"\n", status);
              break;
            }
        }
    }

  return OK;
}
```

Thus we need to emulate the UART Interrupt. To Receive Data...

- UART Register UART_IIR: Should return UART_IIR_INTID_RDA (data available)

  Then it should return UART_IIR_INTSTATUS (no more data)

- UART Register UART_LSR: Should return UART_LSR_DR (data available)

  Then it should return 0 (no more data)

- UART Register UART_RBR: Should return the input data

We emulate the UART Interrupt like this: [Emulate UART Interrupt: UART_LSR, UART_IIR, UART_RBR](https://github.com/lupyuen2/sg2000-emulator/commit/ce3562e4d7efe53b52a1b945850f08d93630d4d2)

Now we see...

```bash
plic_set_irq: irq_num=44, state=1
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c

read UART_IIR_OFFSET
read UART_RBR_OFFSET
read UART_IIR_OFFSET

plic_write: offset=0x201004, val=0x2c
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c

read UART_IIR_OFFSET
plic_write: offset=0x201004, val=0x2c
plic_update_mip: set_mip, pending=0x80000000000, served=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000000000, served=0x80000000000
plic_read: pending irq=0x2c
read UART_IIR_OFFSET
```

# Clear the UART Interrupt

_Why is pending IRQ looping forever?_

That's because we forgot to clear the UART Interrupt duh!

- [Clear the UART Interrupt](https://github.com/lupyuen2/sg2000-emulator/commit/2d10b7699378525a3cf4282d2eaf9da051726638)

Finally it works OK yay! [(We disabled logging)](https://github.com/lupyuen2/sg2000-emulator/commit/ba2e9e09df18e7feed38e67a1ca678348f0c2d2a)

```bash
$ sg2000-emulator/temu nuttx.cfg
TinyEMU Emulator for Sophgo SG2000 SoC
virtio_console_init
Patched DCACHE.IALL (Invalidate all Page Table Entries in the D-Cache) at 0x80200a28
Patched SYNC.S (Ensure that all Cache Operations are completed) at 0x80200a2c
Found ECALL (Start System Timer) at 0x8020b2c6
Patched RDTIME (Read System Time) at 0x8020b2cc
elf_len=0
virtio_console_resize_event
ABC
NuttShell (NSH) NuttX-12.5.1
nsh> uname -a
NuttX 12.5.1 50fadb93f2 Jun 18 2024 09:20:31 risc-v milkv_duos
nsh> 
```

[OSTest works OK too!](https://gist.github.com/lupyuen/ac80b426f67ad38f6a59ae563b0ecb9f)

# TinyEMU

[![Build](https://github.com/lupyuen/TinyEMU/workflows/Build/badge.svg)][GitHub Actions]

This is a modified version of [Fabrice Bellard's TinyEMU][TinyEMU].

[GitHub Actions]: https://github.com/fernandotcl/TinyEMU/actions?query=workflow%3ABuild
[TinyEMU]: https://bellard.org/tinyemu/

## Features

- 32/64/128-bit RISC-V emulation.
- VirtIO console, network, block device, input and 9P filesystem.
- Framebuffer emulation through SDL.
- Remote HTTP block device and filesystem.
- Small code, easy to modify, no external dependencies.

Changes from Fabrice Bellard's 2019-02-10 release:

- macOS and [iOS][TinyEMU-iOS] support.
- Support for loading ELF images.
- Support for loading initrd images or compressed initramfs archives.
- Framebuffer support through SDL 2 instead of 1.2.

[TinyEMU-iOS]: https://github.com/fernandotcl/TinyEMU-iOS

## Usage

Use the VM images available from Fabrice Bellard's [jslinux][] (no need to download them):

```
$ temu https://bellard.org/jslinux/buildroot-riscv64.cfg

Welcome to JS/Linux (riscv64)

Use 'vflogin username' to connect to your account.
You can create a new account at https://vfsync.org/signup .
Use 'export_file filename' to export a file to your computer.
Imported files are written to the home directory.

[root@localhost ~]# uname -a
Linux localhost 4.15.0-00049-ga3b1e7a-dirty #11 Thu Nov 8 20:30:26 CET 2018 riscv64 GNU/Linux
[root@localhost ~]#
```

Use `C-a x` to exit the emulator.

You can also use TinyEMU with local configuration and disks. You can find more information in Fabrice Bellard's [documentation for TinyEMU][tinyemu-readme].

[jslinux]: https://bellard.org/jslinux
[tinyemu-readme]: https://bellard.org/tinyemu/readme.txt

## Installing

The easiest way to install TinyEMU is through [Homebrew][]. There is a formula for TinyEMU in [my Homebrew tap][tap].

[homebrew]: https://brew.sh
[tap]: https://github.com/fernandotcl/homebrew-fernandotcl

If you're compiling from source, you'll need:

- [OpenSSL][] (optional)
- [SDL 2.0][sdl] (optional)

[openssl]: https://www.openssl.org
[sdl]: https://www.libsdl.org

Make sure to disable `CONFIG_INT128` for 32-bit hosts.

## Credits

TinyEMU was created by [Fabrice Bellard][fabrice]. This port is maintained by [Fernando Tarlá Cardoso Lemos][fernando].

[fabrice]: https://bellard.org
[fernando]: mailto:fernandotcl@gmail.com

## License

Unless otherwise specified in individual files, TinyEMU is available under the MIT license.

The SLIRP library has its own license (two-clause BSD license).
