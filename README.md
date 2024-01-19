![Ox64 BL808 Emulator with TinyEMU RISC-V Emulator and Apache NuttX RTOS](https://lupyuen.github.io/images/tinyemu2-title.png)

[_(Live Demo of Ox64 BL808 Emulator)_](https://lupyuen.github.io/nuttx-tinyemu/ox64)

# Emulate Ox64 BL808 SBC in the Web Browser with TinyEMU RISC-V Emulator <br><br> WIP: Start NuttX Kernel in Supervisor Mode

(Instead of Machine Mode)

[NuttX Start Code for 64-bit RISC-V Kernel Mode (rv-virt:knsh64)](https://gist.github.com/lupyuen/368744ef01b7feba10c022cd4f4c5ef2)

See https://github.com/lupyuen/nuttx-tinyemu

# TODO

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

Source:

```text
/Users/Luppy/ox64/nuttx/arch/risc-v/src/chip/bl808_head.S:124
2:
  /* Disable all interrupts (i.e. timer, external) in sie */
  csrw	sie, zero
    50200074:	10401073          	csrw	sie,zero
```

Why is `csrw sie,zero` invalid? Are we in Supervisor Mode?

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
