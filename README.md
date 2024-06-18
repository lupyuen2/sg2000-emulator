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

https://riscvasm.lucasteske.dev/#

```text
auipc t0, 0x80200000
```

Produces this error...

```text
file.s: Assembler messages:
file.s:3: Error: lui expression not in range 0..1048575
file.s:3: Error: value of 0000080200000000 too large for field of 4 bytes at 0000000000000000
```

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
