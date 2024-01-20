![Ox64 BL808 Emulator with TinyEMU RISC-V Emulator and Apache NuttX RTOS](https://lupyuen.github.io/images/tinyemu2-title.png)

[_(Live Demo of Ox64 BL808 Emulator)_](https://lupyuen.github.io/nuttx-tinyemu/ox64)

# Emulate Ox64 BL808 SBC in the Web Browser with TinyEMU RISC-V Emulator <br><br> WIP: Start NuttX Kernel in Supervisor Mode

(Instead of Machine Mode)

See https://github.com/lupyuen/nuttx-tinyemu

# Start NuttX Kernel in Supervisor Mode

Based on [NuttX Start Code for 64-bit RISC-V Kernel Mode (rv-virt:knsh64)](https://gist.github.com/lupyuen/368744ef01b7feba10c022cd4f4c5ef2)...

We [MRET to Supervisor Mode](https://github.com/lupyuen/ox64-tinyemu/commit/e62d49f1a8b27002871f712e80b1785442e23393) and [dump MCAUSE 2: Illegal Instruction](https://github.com/lupyuen/ox64-tinyemu/commit/37c2d1169706a56afbd2d7d2a13624b58269e1ef#diff-2080434ac7de762b1948a6bc493874b21b9e3df3de8b9e52de23bfdcec354abd)...

```text
TinyEMU Emulator for Ox64 BL808 RISC-V SBC
virtio_console_init
csr_write: csr=0x341 val=0x0000000050200000
raise_exception2: cause=2, tval=0x10401073
pc =0000000050200074 ra =0000000000000000 sp =0000000050407c00 gp =0000000000000000
tp =0000000000000000 t0 =0000000050200000 t1 =0000000000000000 t2 =0000000000000000
s0 =0000000000000000 s1 =0000000000000000 a0 =0000000000000000 a1 =0000000000001040
a2 =0000000000000000 a3 =0000000000000000 a4 =0000000000000000 a5 =0000000000000000
a6 =0000000000000000 a7 =0000000000000000 s2 =0000000000000000 s3 =0000000000000000
s4 =fffffffffffffff3 s5 =0000000000000000 s6 =0000000000000000 s7 =0000000000000000
s8 =0000000000000000 s9 =0000000000000000 s10=0000000000000000 s11=0000000000000000
t3 =0000000000000000 t4 =0000000000000000 t5 =0000000000000000 t6 =0000000000000000
priv=U mstatus=0000000a00000080 cycles=13
 mideleg=0000000000000000 mie=0000000000000000 mip=0000000000000080
raise_exception2: cause=2, tval=0x0
pc =0000000000000000 ra =0000000000000000 sp =0000000050407c00 gp = 
```

Which comes from...

```text
nuttx/arch/risc-v/src/chip/bl808_head.S:124
2:
  /* Disable all interrupts (i.e. timer, external) in sie */
  csrw	sie, zero
    50200074:	10401073          	csrw	sie,zero
```

`csrw sie,zero` is invalid because we're in User Mode (`priv=U`), not Supervisor Mode.

So we [set mstatus to S-mode and enable SUM](https://github.com/lupyuen/ox64-tinyemu/commit/d379d92bfe544681e0560306a1aad96f5792da9e)...

```text
TinyEMU Emulator for Ox64 BL808 RISC-V SBC
virtio_console_init
raise_exception2: cause=2, tval=0x879b0000
pc =0000000000001012 ra =0000000000000000 sp =0000000000000000 gp =0000000000000000
tp =0000000000000000 t0 =0000000050200000 t1 =0000000000000000 t2 =0000000000000000
s0 =0000000000000000 s1 =0000000000000000 a0 =0000000000000000 a1 =0000000000001040
a2 =0000000000000000 a3 =0000000000000000 a4 =0000000000000000 a5 =ffffffffffffe000
a6 =0000000000000000 a7 =0000000000000000 s2 =0000000000000000 s3 =0000000000000000
s4 =0000000000000000 s5 =0000000000000000 s6 =0000000000000000 s7 =0000000000000000
s8 =0000000000000000 s9 =0000000000000000 s10=0000000000000000 s11=0000000000000000
t3 =0000000000000000 t4 =0000000000000000 t5 =0000000000000000 t6 =0000000000000000
priv=M mstatus=0000000a00000000 cycles=4
 mideleg=0000000000000000 mie=0000000000000000 mip=0000000000000080
tinyemu: Unknown mcause 2, quitting
```

We hit an Illegal Instruction caused by an unpadded 16-bit instruction.

So we [insert NOP to pad 16-bit RISC-V Instructions to 32-bit](https://github.com/lupyuen/ox64-tinyemu/commit/23a36478cf03561d40f357f876284c09722ce455)...

```text
work_start_lowpri: Starting low-priority kernel worker thread(s)
nx_start_application: Starting init task: /system/bin/init
up_exit: TCB=0x504098d0 exiting

raise_exception2: cause=8, tval=0x0
pc =00000000800019c6 ra =0000000080000086 sp =0000000080202bc0 gp =0000000000000000
tp =0000000000000000 t0 =0000000000000000 t1 =0000000000000000 t2 =0000000000000000
s0 =0000000000000001 s1 =0000000080202010 a0 =000000000000000d a1 =0000000000000000
a2 =0000000080202bc8 a3 =0000000080202010 a4 =0000000080000030 a5 =0000000000000000
a6 =0000000000000101 a7 =0000000000000000 s2 =0000000000000000 s3 =0000000000000000
s4 =0000000000000000 s5 =0000000000000000 s6 =0000000000000000 s7 =0000000000000000
s8 =0000000000000000 s9 =0000000000000000 s10=0000000000000000 s11=0000000000000000
t3 =0000000000000000 t4 =0000000000000000 t5 =0000000000000000 t6 =0000000000000000
priv=U mstatus=0000000a000400a1 cycles=79648442
 mideleg=0000000000000000 mie=0000000000000000 mip=0000000000000080

raise_exception2: cause=2, tval=0x0
pc =0000000000000000 ra =0000000080000086 sp =0000000080202bc0 gp =0000000000000000
tp =0000000000000000 t0 =0000000000000000 t1 =0000000000000000 t2 =0000000000000000
s0 =0000000000000001 s1 =0000000080202010 a0 =000000000000000d a1 =0000000000000000
a2 =0000000080202bc8 a3 =0000000080202010 a4 =0000000080000030 a5 =0000000000000000
a6 =0000000000000101 a7 =0000000000000000 s2 =0000000000000000 s3 =0000000000000000
s4 =0000000000000000 s5 =0000000000000000 s6 =0000000000000000 s7 =0000000000000000
s8 =0000000000000000 s9 =0000000000000000 s10=0000000000000000 s11=0000000000000000
t3 =0000000000000000 t4 =0000000000000000 t5 =0000000000000000 t6 =0000000000000000
priv=M mstatus=0000000a000400a1 cycles=79648467
 mideleg=0000000000000000 mie=0000000000000000 mip=0000000000000080
tinyemu: Unknown mcause 2, quitting
```

But the ECALL goes from User Mode (`priv=U`) to Machine Mode (`priv=M`), not Supervisor Mode!

We [set exception and interrupt delegation for S-mode](https://github.com/lupyuen/ox64-tinyemu/commit/9536e86217bcccbe15272dc4450eac9fab173b03)...

```text
work_start_lowpri: Starting low-priority kernel worker thread(s)
nx_start_application: Starting init task: /system/bin/init
up_exit: TCB=0x504098d0 exiting
NuttShell (NSH) NuttX-12.4.0
nsh>
nx_start: CPU0: Beginning Idle Loop
```

Finally NuttX Shell starts OK yay!

Try the demo: https://lupyuen.github.io/nuttx-tinyemu/smode/

Up Next: Emulate UART Interrupts for Console Input

# Emulate UART Interrupts for Console Input

TODO

[Set VirtIO IRQ to UART3 IRQ](https://github.com/lupyuen/ox64-tinyemu/commit/6841e7fe90f2826b54751e4fff2fe9ab3872bd99)

[Disable Console Resize event because it crashes VM Guest at startup](https://github.com/lupyuen/ox64-tinyemu/commit/dc869fe6a9a726d413e8a83c56cf40f271c6fe3c)

[We always allow VirtIO Write Data](https://github.com/lupyuen/ox64-tinyemu/commit/93cd86a7311986e5063cb0c8e368f89cdae73e27)

[Always ready for VirtIO Writes](https://github.com/lupyuen/ox64-tinyemu/commit/b893255b42a8aaa443f7264dc06537b96326b414)

[Handle a keypress](https://github.com/lupyuen/ox64-tinyemu/commit/a3d029e6e08d1ee3147f41536df76dc3986cb23e)

[To handle a keypress, we trigger the UART3 Interrupt](https://github.com/lupyuen/ox64-tinyemu/commit/3deaef2a5d5ca3ad8a4339c21be3b054fba4fda2)

```text
nx_start: CPU0: Beginning Idle Loop
[a]
plic_set_irq: irq_num=20, state=1
plic_update_mip: set_mip, pending=0x80000, served=0x0
raise_exception: cause=-2147483639
raise_exception: sleep
raise_exception2: cause=-2147483639, tval=0x0

## Claim Interrupt
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000, served=0x80000

## Handle Interrupt
target_read_slow: invalid physical address 0x0000000030002020
target_read_slow: invalid physical address 0x0000000030002024

## Complete Interrupt
plic_write: offset=0x201004, val=0x14

## Loop Again
plic_update_mip: set_mip, pending=0x80000, served=0x0
raise_exception: cause=-2147483639
raise_exception: sleep
raise_exception2: cause=-2147483639, tval=0x0
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000, served=0x80000
target_read_slow: invalid physical address 0x0000000030002020
target_read_slow: invalid physical address 0x0000000030002024
plic_write: offset=0x201004, val=0x14
```

https://github.com/lupyuen2/wip-pinephone-nuttx/blob/tinyemu4/arch/risc-v/src/bl808/bl808_serial.c#L166-L224

```c
static int __uart_interrupt(int irq, void *context, void *arg) {
  // 0x000020  /* UART interrupt status */
  int_status = getreg32(BL808_UART_INT_STS(uart_idx));

  // 0x000024  /* UART interrupt mask */
  int_mask = getreg32(BL808_UART_INT_MASK(uart_idx));

  /* Length of uart rx data transfer arrived interrupt */
  if ((int_status & UART_INT_STS_URX_END_INT) &&
      !(int_mask & UART_INT_MASK_CR_URX_END_MASK))
    {
      // 0x000028  /* UART interrupt clear */
      putreg32(UART_INT_CLEAR_CR_URX_END_CLR,
               BL808_UART_INT_CLEAR(uart_idx));
      /* Receive Data ready */
      uart_recvchars(dev);
    }
```

[BL808_UART_INT_STS (0x30002020) must return UART_INT_STS_URX_END_INT (1 << 1)](https://github.com/lupyuen/ox64-tinyemu/commit/074f8c30cb4a39a0d2d0dfd195be31858c5c9e52)

[BL808_UART_INT_MASK (0x30002024) must NOT return UART_INT_MASK_CR_URX_END_MASK (1 << 1)](https://github.com/lupyuen/ox64-tinyemu/commit/074f8c30cb4a39a0d2d0dfd195be31858c5c9e52)

To prevent looping: [Clear the interrupt after setting BL808_UART_INT_CLEAR (0x30002028)](https://github.com/lupyuen/ox64-tinyemu/commit/f9c1841d7699ecc04f9ce4499f1c081ae50aa225)

```text
nx_start: CPU0: Beginning Idle Loop
[a]
plic_set_irq: irq_num=20, state=1
plic_update_mip: set_mip, pending=0x80000, served=0x0
raise_exception: cause=-2147483639
raise_exception2: cause=-2147483639, tval=0x0

## Claim Interrupt
plic_read: offset=0x201004
plic_update_mip: reset_mip, pending=0x80000, served=0x80000

## Handle Interrupt
virtio_ack_irq
plic_set_irq: irq_num=20, state=0
plic_update_mip: reset_mip, pending=0x0, served=0x80000

## Complete Interrupt
plic_write: offset=0x201004, val=0x14
plic_update_mip: reset_mip, pending=0x0, served=0x0
```

[BL808_UART_FIFO_RDATA_OFFSET (0x3000208c) returns the Input Char](https://github.com/lupyuen/ox64-tinyemu/commit/63cba6275c850b668598120355240f5d485c4538)

Console Input works OK yay!

Try the demo: https://lupyuen.github.io/nuttx-tinyemu/smode/

```text
Loading...
TinyEMU Emulator for Ox64 BL808 RISC-V SBC
ABCnx_start: Entry
uart_register: Registering /dev/console
work_start_lowpri: Starting low-priority kernel worker thread(s)
nx_start_application: Starting init task: /system/bin/init
up_exit: TCB=0x504098d0 exiting
 
NuttShell (NSH) NuttX-12.4.0
nsh> nx_start: CPU0: Beginning Idle Loop
 
nsh> ls
posix_spawn: pid=0x80202978 path=ls file_actions=0x80202980 attr=0x80202988 argv
=0x80202a28
nxposix_spawn_exec: ERROR: exec failed: 2
/:
 dev/
 proc/
 system/
nsh> uname -a
posix_spawn: pid=0x80202978 path=uname file_actions=0x80202980 attr=0x80202988 a
rgv=0x80202a28
nxposix_spawn_exec: ERROR: exec failed: 2
NuttX 12.4.0 96c2707 Jan 18 2024 12:07:28 risc-v ox64
```

# Emulate OpenSBI for System Timer

[Emulate OpenSBI for System Timer](https://github.com/lupyuen/ox64-tinyemu/commit/ab58cd2dc6a1d94b9bd13faa0f402a7ada4b270d)

[Patch the RDTTIME (Read System Timer) with NOP for now. We will support later.](https://github.com/lupyuen/ox64-tinyemu/commit/5cb2fb4e263b9e965777f567b053a0914f3cf368)

Latest NuttX Build works OK yay!

Try the demo: https://lupyuen.github.io/nuttx-tinyemu/smode/

```text
Loading...
TinyEMU Emulator for Ox64 BL808 RISC-V SBC
ABC
NuttShell (NSH) NuttX-12.4.0-RC0
nsh> uname -a
NuttX 12.4.0-RC0 4c41d84d21 Jan 20 2024 00:10:33 risc-v ox64
nsh> help
help usage:  help [-v] [<cmd>]
 
    .           cp          exit        mkrd        set         unset
    [           cmp         false       mount       sleep       uptime
    ?           dirname     fdinfo      mv          source      usleep
    alias       dd          free        pidof       test        xd
    unalias     df          help        printf      time
    basename    dmesg       hexdump     ps          true
    break       echo        kill        pwd         truncate
    cat         env         ls          rm          uname
    cd          exec        mkdir       rmdir       umount
nsh>
```

# Emulate BL808 GPIO to Blink an LED

TODO

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
