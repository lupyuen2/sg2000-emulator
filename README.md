# Emulate Sophgo SG2000 SoC / Milk-V Duo S SBC with TinyEMU RISC-V Emulator

TODO

[Update RAM Base Addr, CLINT Addr, PLIC Addr](https://github.com/lupyuen2/sg2000-emulator/commit/d36190c63c1db116a206a26f3bc27dfacf5c8298)

```bash
spawn /Users/Luppy/sg2000/sg2000-emulator/temu root-riscv64.cfg
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

0xffffffff80200000 looks sus, it seems related to RAM Base Address 0x80200000. We check the TinyEMU Boot Code...

```c
q = (uint32_t *)(ram_ptr + 0x1000);
q[0] = 0x297 + RAM_BASE_ADDR - 0x1000; /* auipc t0, jump_addr */
```

Maybe auipc has a problem? We run the RISC-V Online Assembler: https://riscvasm.lucasteske.dev/#

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

So we load 0x80200000 into Register t0 in another way

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
spawn /Users/Luppy/sg2000/sg2000-emulator/temu root-riscv64.cfg
TinyEMU Emulator for Sophgo SG2000 SoC
virtio_console_init
Patched DCACHE.IALL (Invalidate all Page Table Entries in the D-Cache) at 0x80200a28
Patched SYNC.S (Ensure that all Cache Operations are completed) at 0x80200a2c
Found ECALL (Start System Timer) at 0x8020b2c6
Patched RDTIME (Read System Time) at 0x8020b2cc
elf_len=0
virtio_console_resize_event
```

We fix the UART Output Registers: [Update UART Output Register and UART Status Register](https://github.com/lupyuen2/sg2000-emulator/commit/fd6e5333ef6f89b452901d6e580d8387e9da2573)

Now we see NSH Shell yay!

```bash
$ $HOME/sg2000/sg2000-emulator/temu root-riscv64.cfg 
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
$ $HOME/sg2000/sg2000-emulator/temu root-riscv64.cfg 
...
NuttShell (NSH) NuttX-12.5.1
nsh> irq_unexpected_isr: ERROR irq: 45
_assert: Current Version: NuttX  12.5.1 218ccd843a Jun 18 2024 22:14:46 risc-v
_assert: Assertion failed panic: at file: irq/irq_unexpectedisr.c:54 task: Idle_Task process: Kernel 0x8020110c
up_dump_register: EPC: 000000008021432a
```

TODO: Fix UART Input and UART Interrupt

```bash
CONFIG_16550_UART0_IRQ=69
```

NuttX IRQ Offset is 25, so Actual RISC-V IRQ is 69 - 25 = 44

```c
#define VIRTIO_IRQ       44  // UART0 IRQ
```

When we press a key: TinyEMU crashes with a Segmentation Fault...

```bash
$ $HOME/sg2000/sg2000-emulator/temu root-riscv64.cfg    
...
NuttShell (NSH) NuttX-12.5.1
nsh> [1]    94499 segmentation fault  $HOME/sg2000/sg2000-emulator/temu root-riscv64.cfg
```

We debug with `lldb` (because `gdb` is not available for macOS Arm64)...

```bash
$ lldb $HOME/sg2000/sg2000-emulator/temu root-riscv64.cfg 
(lldb) target create "/Users/luppy/sg2000/sg2000-emulator/temu"
Current executable set to '/Users/luppy/sg2000/sg2000-emulator/temu' (arm64).
(lldb) settings set -- target.run-args  "root-riscv64.cfg"
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

TODO: Why did TinyEMU crash?

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
